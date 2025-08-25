<!-- prettier-ignore -->
# ✨ Resizable Sidebar — Shiny Prototype

A small, playful, single-file Shiny prototype that demonstrates a resizable `bslib` sidebar you can control from the server and by dragging in the browser.

Status: Prototype — see `ShinyApp/app.R`

Why this project?
- It demonstrates a clear UI contract between Shiny (server) and client JS using a custom message (`setSidebarWidth`).
- Useful as a copy-paste starter for dashboards that need a resizable navigation pane.

Highlights
- 🎛️ Sidebar width controlled by a `sliderInput()` (150–500 px) and a draggable handle.
- 🧭 Two simple tabs: Example (interactive histogram) and About (notes & run instructions).
- 📊 Reactive histogram using the built-in `faithful` dataset — bins map to sidebar width for an immediate visual effect.
- ♿ Basic accessibility: drag handle is keyboard-focusable (Arrow keys adjust width).

Quick start (run locally)

1. Install dependencies (once):

```r
install.packages(c("shiny", "bslib"))
```

2. Run the app from R:

```r
shiny::runApp("ShinyApp")
# or open and run: ShinyApp/app.R
```

What you'll see
- Move the sidebar slider — the server sends a `setSidebarWidth` message and the client updates the CSS variable `--_sidebar-width`.
- Drag the vertical handle between the sidebar and main content to resize live — the new width is optionally synced back to the Shiny input.

Files of interest
- `ShinyApp/app.R` — the single-file prototype (UI, server, CSS, and embedded JS).
- `PRD.qmd` / `PRD.html` — product requirements and acceptance criteria.
- `wireframes/` — low-fidelity text wireframes used for the UI design.
- `.github/copilot-instructions.md` — developer-facing instructions and the PRD + wireframes bundle.

Developer contract (quick)
- Server message: `setSidebarWidth` — payload: numeric width (px).
- Client handler: `Shiny.addCustomMessageHandler('setSidebarWidth', width => { /* set --_sidebar-width */ })`.
- Optional client -> server sync: `Shiny.setInputValue('sidebar_width_from_js', newWidth, {priority:'event'})`.

Tips & notes
- The UI clamps width to the [150, 500] px range to avoid layout breakage.
- The prototype includes keyboard and touch support for the drag handle.
- This project intentionally keeps external resources to a minimum; add badges or CI later as needed.

Contributing
- Fork, make features/fixes, open a PR. Add a short note describing changes.

License
- No license file is included by default. If you plan to publish, add a license (MIT recommended) in the repo root.

Contact
- If you want me to polish the UI, add tests, or wire up localStorage persistence for the sidebar width, tell me which you'd like next.

Enjoy! 🚀
