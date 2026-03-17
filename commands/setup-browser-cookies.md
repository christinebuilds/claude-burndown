---
description: Import browser cookies for authenticated testing. Exports cookies from Chrome, Arc, Brave, or Edge so Playwright can access authenticated pages. Use /setup-browser-cookies before /qa or /qa-design when the app requires login.
---

# Setup Browser Cookies

Import cookies from your browser so Playwright-based testing can access authenticated pages.

## Step 1: Detect Available Browsers

```bash
# Check which browsers have cookie databases
ls ~/Library/Application\ Support/Google/Chrome/Default/Cookies 2>/dev/null && echo "CHROME"
ls ~/Library/Application\ Support/Arc/User\ Data/Default/Cookies 2>/dev/null && echo "ARC"
ls ~/Library/Application\ Support/BraveSoftware/Brave-Browser/Default/Cookies 2>/dev/null && echo "BRAVE"
ls ~/Library/Application\ Support/Microsoft\ Edge/Default/Cookies 2>/dev/null && echo "EDGE"
```

## Step 2: Ask User

Present the detected browsers and ask:
1. Which browser to import from
2. Which domain(s) to import cookies for (e.g., `localhost`, `myapp.com`)

## Step 3: Export Cookies

The cookie databases are SQLite. Export cookies for the specified domain:

```bash
# Close the browser first or copy the DB to avoid locks
cp "<cookie_db_path>" /tmp/cookies_export.db
sqlite3 /tmp/cookies_export.db "SELECT name, value, host_key, path, expires_utc, is_secure, is_httponly FROM cookies WHERE host_key LIKE '%<domain>%';"
```

**Note:** Modern Chrome/Arc/Brave encrypt cookies. If direct SQLite export fails, suggest alternatives:
1. Use browser DevTools → Application → Cookies → copy manually
2. Use a browser extension like "EditThisCookie" to export as JSON
3. For localhost testing: just log in via Playwright directly

## Step 4: Create Playwright Storage State

Write the cookies to a Playwright-compatible storage state file:

```json
{
  "cookies": [
    {
      "name": "<name>",
      "value": "<value>",
      "domain": "<domain>",
      "path": "/",
      "httpOnly": true,
      "secure": true
    }
  ]
}
```

Save to `.playwright/storage-state.json` in the project root. Add to `.gitignore` if not already there.

## Step 5: Verify

Tell the user:
- Storage state saved to `.playwright/storage-state.json`
- Added to `.gitignore` (contains session tokens — never commit)
- `/qa` and `/qa-design` will automatically use this for authenticated testing

## Fallback: Manual Login

If cookie export is too complex, offer the simpler approach:
1. Launch Playwright browser in headed mode
2. User logs in manually
3. Save the resulting storage state

This is often easier than extracting encrypted cookies.

## Security Notes

- **Never commit storage state files** — they contain session tokens
- Cookie files are added to `.gitignore` automatically
- Storage state expires when the session expires — may need to re-run
