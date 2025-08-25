# ✨ Resizable Sidebar — shiny and bslib Package

[![Project Status: Prototype](https://img.shields.io/badge/Project%20Status-Active-green)](https://github.com/Ramdhadage/shiny-resizable-sidebar) [![Try it now!](https://img.shields.io/badge/Try%20it-online-blue)](https://ramdhadage.github.io/shiny-resizable-sidebar/)

## 📖 About The Project

A minimal, single-file Shiny prototype that demonstrates a resizable `bslib` sidebar controllable from the server and via a draggable handle in the browser.

* Sidebar width is controlled by a `sliderInput()` (150–500 px) and a draggable handle
* Two simple tabs: Example (interactive histogram) and About (project notes)
* Live client-server contract via custom message `setSidebarWidth` (see `PRD.qmd`)
* Accessible: drag handle is keyboard-focusable (basic Arrow key support)


### 💡 Why this matters

* Customizable sidebars improve usability for dashboards and data apps
* Responsive layouts adapt to any screen size, making content more accessible
* Demonstrates a reusable Shiny ↔ JS messaging pattern for UI control
* Shows how to combine R, Shiny, bslib, and client-side scripting for modern UX
* Problem: many Shiny dashboards assume a fixed sidebar width, which can make content cramped on small screens or waste space on large ones
* Our approach: expose the sidebar width as a CSS variable (`--_sidebar-width`) and update it from the server or via a draggable handle in the client. The result is a responsive, live-resizable layout that keeps data visible and usable

### 🗂️ What you'll find here

- A single-file prototype at `shiny_app/app.R` demonstrating the pattern
- A slider to control sidebar width (150–500 px) that sends a `setSidebarWidth` message to the client
- A draggable handle that resizes the sidebar in real time and can sync back to the Shiny input
* A single-file prototype at `shiny_app/app.R` demonstrating the pattern
* A slider to control sidebar width (150–500 px) that sends a `setSidebarWidth` message to the client
* A draggable handle that resizes the sidebar in real time and can sync back to the Shiny input

### ⚡ Key behavior (short)
* Default width: 250 px. Slider range: 150–500 px. Values are clamped
* Message contract: Server -> Client: `setSidebarWidth` (numeric px). Client updates `.bslib-sidebar-layout` via `--_sidebar-width`

## 🖥 Live Demo
**Try it out:**  
- Adjust the sidebar width using the slider and see the histogram update instantly.
- Drag the vertical handle to resize the sidebar interactively—changes reflect live in the layout.

**Launch the demo in your browser:**  
[https://ramdhadage.github.io/shiny-resizable-sidebar/](https://ramdhadage.github.io/shiny-resizable-sidebar/)

## 🚀 Installation

1. Install dependencies (once):
```r
install.packages(c("shiny", "bslib"))
```

2. Run the app from R:
```r
shiny::runApp("shiny_app")
# or open and run: shiny_app/app.R
```
## Files of interest
* `shiny_app/app.R` — the full prototype (UI, server, CSS, embedded JS)
* `PRD.qmd` — product requirements and engineering contract for the custom message
* `wireframes/` — simple text wireframes documenting intended UX states

## Design notes (engineer quick reference)
* CSS variable: `--_sidebar-width` on `.bslib-sidebar-layout`
* Server call: `session$sendCustomMessage('setSidebarWidth', value)`
* Client handler: `Shiny.addCustomMessageHandler('setSidebarWidth', width => { element.style.setProperty('--_sidebar-width', width + 'px') })`
* Optional client -> server sync: `Shiny.setInputValue('sidebar_width_from_js', width, {priority:'event'})`

## Contributing
* Small prototype — issues and PRs welcome. For local development, open `shiny_app/app.R` and run the app locally

## License
* MIT

