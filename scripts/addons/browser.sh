#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up browser automation via Playwright..."

# Install Playwright
if python3 -c "import playwright" 2>/dev/null; then
  echo "  ✓ Playwright Python already installed"
else
  echo "  Installing Playwright..."
  python3 -m pip install playwright --break-system-packages -q 2>/dev/null || \
    python3 -m pip install playwright -q
fi

# Install Playwright browsers (Chromium is enough, ~150MB)
if python3 -c "from playwright.sync_api import sync_playwright; p=sync_playwright().start(); p.chromium.launch(headless=True).close(); p.stop()" 2>/dev/null; then
  echo "  ✓ Playwright Chromium already installed"
else
  echo "  Installing Playwright Chromium browser..."
  python3 -m playwright install chromium 2>&1 | tail -3
fi

mkdir -p "$HOME/.hermes/bin"

###############################################################################
# 1. Browser automation script — full Playwright control
###############################################################################
cat > "$HOME/.hermes/bin/hermes-browser" << 'PYEOF'
#!/usr/bin/env python3
"""Full browser automation via Playwright on Apple Silicon.

Usage:
  hermes-browser navigate https://example.com
  hermes-browser screenshot https://example.com output.png
  hermes-browser extract https://example.com          # full page text
  hermes-browser search "stock price AAPL"            # google then return results
  hermes-browser pdf https://example.com output.pdf
  hermes-browser script script.py                     # run custom Playwright script
  hermes-browser interactive                          # launch visible browser
"""

import argparse
import sys
import os
import json
from pathlib import Path

def get_browser():
    from playwright.sync_api import sync_playwright
    p = sync_playwright().start()
    browser = p.chromium.launch(
        headless=True,
        args=[
            "--no-sandbox",
            "--disable-setuid-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu",
        ]
    )
    return p, browser

def cmd_navigate(url):
    p, browser = get_browser()
    page = browser.new_page()
    page.goto(url, wait_until="domcontentloaded")
    print(f"Title: {page.title()}")
    print(f"URL: {page.url}")
    browser.close()
    p.stop()

def cmd_screenshot(url, output):
    p, browser = get_browser()
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    page.goto(url, wait_until="networkidle")
    page.screenshot(path=output, full_page=True)
    print(f"  ✓ Screenshot saved to {output}")
    browser.close()
    p.stop()

def cmd_extract(url):
    p, browser = get_browser()
    page = browser.new_page()
    page.goto(url, wait_until="domcontentloaded")
    content = page.inner_text("body")
    # Clean up
    lines = [l.strip() for l in content.split("\n") if l.strip()]
    print("\n".join(lines))
    browser.close()
    p.stop()

def cmd_search(query):
    p, browser = get_browser()
    page = browser.new_page()
    page.goto(f"https://www.google.com/search?q={query}", wait_until="domcontentloaded")
    results = page.query_selector_all("div.g")
    for i, r in enumerate(results[:10], 1):
        title_el = r.query_selector("h3")
        link_el = r.query_selector("a")
        snippet_el = r.query_selector("div[data-sncf]")
        title = title_el.inner_text() if title_el else ""
        link = link_el.get_attribute("href") if link_el else ""
        snippet = snippet_el.inner_text() if snippet_el else ""
        print(f"{i}. {title}")
        print(f"   {link}")
        print(f"   {snippet}")
        print()
    browser.close()
    p.stop()

def cmd_pdf(url, output):
    p, browser = get_browser()
    page = browser.new_page()
    page.goto(url, wait_until="networkidle")
    page.pdf(path=output, format="A4")
    print(f"  ✓ PDF saved to {output}")
    browser.close()
    p.stop()

def cmd_script(script_path):
    """Run a custom Playwright script."""
    script_path = Path(script_path)
    if not script_path.exists():
        print(f"Script not found: {script_path}")
        sys.exit(1)
    
    # Read and execute the script with Playwright imports available
    import importlib.util
    spec = importlib.util.spec_from_file_location("custom_script", script_path)
    mod = importlib.util.module_from_spec(spec)
    # Inject pre-imported modules
    sys.modules[mod.__name__] = mod
    spec.loader.exec_module(mod)

def cmd_interactive():
    """Launch a visible browser window for debugging."""
    p, browser = get_browser()
    browser.close()
    p.stop()
    # Launch with visible window
    from playwright.sync_api import sync_playwright
    p = sync_playwright().start()
    browser = p.chromium.launch(
        headless=False,
        args=["--start-maximized"]
    )
    page = browser.new_page(viewport={"width": 1280, "height": 800})
    page.goto("about:blank")
    print("Interactive browser launched. Press Ctrl+C to close.")
    try:
        import time
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        browser.close()
        p.stop()

def main():
    parser = argparse.ArgumentParser(description="Playwright browser automation")
    sub = parser.add_subparsers(dest="command")

    p_nav = sub.add_parser("navigate", help="Open a URL")
    p_nav.add_argument("url")

    p_ss = sub.add_parser("screenshot", help="Screenshot a page")
    p_ss.add_argument("url")
    p_ss.add_argument("output")

    p_ext = sub.add_parser("extract", help="Extract text from a page")
    p_ext.add_argument("url")

    p_sr = sub.add_parser("search", help="Google search")
    p_sr.add_argument("query", nargs="+")

    p_pdf = sub.add_parser("pdf", help="Save page as PDF")
    p_pdf.add_argument("url")
    p_pdf.add_argument("output")

    p_sc = sub.add_parser("script", help="Run a custom Playwright script")
    p_sc.add_argument("script")

    p_int = sub.add_parser("interactive", help="Launch visible browser")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    if args.command == "navigate":
        cmd_navigate(args.url)
    elif args.command == "screenshot":
        cmd_screenshot(args.url, args.output)
    elif args.command == "extract":
        cmd_extract(args.url)
    elif args.command == "search":
        cmd_search(" ".join(args.query))
    elif args.command == "pdf":
        cmd_pdf(args.url, args.output)
    elif args.command == "script":
        cmd_script(args.script)
    elif args.command == "interactive":
        cmd_interactive()

if __name__ == "__main__":
    main()
PYEOF
chmod +x "$HOME/.hermes/bin/hermes-browser"
echo "  ✓ Created ~/.hermes/bin/hermes-browser"

###############################################################################
# 2. Hermes-compatible browser skill for Playwright
###############################################################################
SKILL_DIR="$HOME/.hermes/skills/browser-playwright"
mkdir -p "$SKILL_DIR"

cat > "$SKILL_DIR/SKILL.md" << 'SKILLEOF'
---
name: browser-playwright
description: Full browser automation via Playwright on Apple Silicon. Navigate, screenshot, extract text, search Google, save PDFs, and run custom scripts. Uses local Chromium with no cloud dependencies.
version: 1.0.0
platforms: [macos]
metadata:
  hermes:
    tags: [browser, playwright, automation, web-scraping]
    category: web
    fallback_for_toolsets: [browser]
---

# Browser Playwright

Free, local browser automation using Playwright's Python API. Chromium runs on your Mac — no cloud accounts, no API keys.

## When to Use

- `web_search` / `web_extract` can't handle JavaScript-heavy sites
- You need screenshots or PDFs of pages
- You need to interact with forms, logins, or multi-step workflows
- You need to scrape content behind client-side rendering

## Quick Commands

```bash
# Navigate and get page text
hermes-browser extract https://example.com

# Search Google
hermes-browser search "AAPL stock price today"

# Screenshot a page
hermes-browser screenshot https://example.com page.png

# Save as PDF
hermes-browser pdf https://example.com page.pdf
```

## Custom Scripts

Write a Python file and run it:

```python
# myscript.py
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()
    page.goto("https://google.com")
    page.fill("textarea[name=q]", "stock price AAPL")
    page.keyboard.press("Enter")
    page.wait_for_timeout(2000)
    page.screenshot(path="results.png")
    browser.close()
```

```bash
hermes-browser script myscript.py
```

## Notes

- Chromium is installed by Playwright, not system Chrome
- Headless by default; use `hermes-browser interactive` for visible debugging
- Screenshots and PDFs save to current directory
- Max 30s default timeout on page loads
SKILLEOF
echo "  ✓ Created browser-playwright skill"

# Enable the browser-cdp toolset in Hermes config
hermes config set platform_toolsets.cli '["hermes-cli","web","vision","image_gen","tts","browser","browser-cdp","code_execution","delegation","cronjob","skills","memory","session_search","moa","messaging"]' 2>/dev/null || true

# Create a script runner for arbitrary Playwright automation
cat > "$HOME/.hermes/bin/hermes-playwright-run" << 'RNEOF'
#!/usr/bin/env python3
"""Run a Playwright automation script with pre-loaded imports.

Usage:
  hermes-playwright-run script.py
"""

import sys
import runpy

# Make playwright available
import playwright.sync_api
import playwright.async_api

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: hermes-playwright-run script.py")
        sys.exit(1)
    runpy.run_path(sys.argv[1], run_name="__main__")
RNEOF
chmod +x "$HOME/.hermes/bin/hermes-playwright-run"
echo "  ✓ Created ~/.hermes/bin/hermes-playwright-run"

# Verify
if python3 -c "from playwright.sync_api import sync_playwright; p=sync_playwright().start(); b=p.chromium.launch(headless=True); b.close(); p.stop()" 2>/dev/null; then
  echo "  ✓ Playwright + Chromium verified — browser automation ready"
  hermes-browser search "test" 2>/dev/null | head -3 || true
else
  echo "  ! Playwright verification failed — try: python3 -m playwright install chromium"
fi

echo ""
echo "==> Browser automation ready."
echo "  Commands:"
echo "    hermes-browser search 'stock price AAPL'"
echo "    hermes-browser extract https://example.com"
echo "    hermes-browser screenshot https://example.com page.png"
echo "    hermes-browser interactive"
echo "  In Hermes: load the browser-playwright skill via /browser-playwright"
