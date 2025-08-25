
library(shiny)
library(bslib)

css <- "/* Minimal styling for the resizable sidebar layout */
.bslib-sidebar-layout { position: relative; --_sidebar-width: 250px; }
.bslib-sidebar-layout .bslib-sidebar { width: var(--_sidebar-width) !important; min-width: 150px; }
#drag-handle {
  position: absolute;
  left: calc(var(--_sidebar-width));
  top: 0;
  bottom: 0;
  width: 10px;
  margin-left: -5px;
  background: linear-gradient(90deg, rgba(0,0,0,0.03), rgba(0,0,0,0.06));
  cursor: col-resize;
  z-index: 999;
}
#drag-handle:focus { outline: 2px solid #2680C2; }
body.dragging { cursor: col-resize; user-select: none; }
@media (max-width: 600px) {
  .bslib-sidebar-layout .bslib-sidebar { position: relative; width: 100% !important; }
  #drag-handle { display: none; }
}
"

js <- "(function(){
  Shiny.addCustomMessageHandler('setSidebarWidth', function(width){
    if (typeof width !== 'number' && typeof width !== 'string') { console.warn('setSidebarWidth: invalid payload', width); return; }
    var w = Number(width);
    if (isNaN(w)) { console.warn('setSidebarWidth: payload not a number', width); return; }
    var el = document.querySelector('.bslib-sidebar-layout');
    if (!el) { console.warn('setSidebarWidth: target .bslib-sidebar-layout not found'); return; }
    w = Math.max(150, Math.min(500, Math.round(w)));
    el.style.setProperty('--_sidebar-width', w + 'px');
  });

  document.addEventListener('DOMContentLoaded', function(){
    var layout = document.querySelector('.bslib-sidebar-layout');
    if (!layout) return;
    // ensure default CSS var
    layout.style.setProperty('--_sidebar-width', layout.style.getPropertyValue('--_sidebar-width') || '250px');

    var handle = document.getElementById('drag-handle');
    if (!handle) return;
    var dragging = false;

    handle.addEventListener('mousedown', function(e){ dragging = true; document.body.classList.add('dragging'); e.preventDefault(); });
    document.addEventListener('mousemove', function(e){
      if (!dragging) return;
      var rect = layout.getBoundingClientRect();
      var newW = Math.round(e.clientX - rect.left);
      newW = Math.max(150, Math.min(500, newW));
      layout.style.setProperty('--_sidebar-width', newW + 'px');
      Shiny.setInputValue('sidebar_width_from_js', newW, {priority: 'event'});
    });
    document.addEventListener('mouseup', function(e){ if (dragging) { dragging = false; document.body.classList.remove('dragging'); } });

    // touch support
    handle.addEventListener('touchstart', function(e){ dragging = true; });
    document.addEventListener('touchmove', function(e){ if (!dragging) return; var t = e.touches[0]; var rect = layout.getBoundingClientRect(); var newW = Math.round(t.clientX - rect.left); newW = Math.max(150, Math.min(500, newW)); layout.style.setProperty('--_sidebar-width', newW + 'px'); Shiny.setInputValue('sidebar_width_from_js', newW, {priority: 'event'}); e.preventDefault(); }, {passive:false});
    document.addEventListener('touchend', function(e){ dragging = false; });

    // keyboard resize on handle
    handle.addEventListener('keydown', function(e){
      var cur = parseInt(getComputedStyle(layout).getPropertyValue('--_sidebar-width')) || 250;
      if (e.key === 'ArrowLeft') { cur = Math.max(150, cur - 10); layout.style.setProperty('--_sidebar-width', cur + 'px'); Shiny.setInputValue('sidebar_width_from_js', cur, {priority: 'event'}); e.preventDefault(); }
      if (e.key === 'ArrowRight') { cur = Math.min(500, cur + 10); layout.style.setProperty('--_sidebar-width', cur + 'px'); Shiny.setInputValue('sidebar_width_from_js', cur, {priority: 'event'}); e.preventDefault(); }
    });
  });
})();"

ui <- bslib::page_sidebar(
  title = "Resizable Sidebar Prototype",
  theme = bslib::bs_theme(version = 5),
  sidebar = tagList(
    tags$h4("Controls"),
    sliderInput('sidebar_slider', 'Sidebar width (px)', min = 150, max = 500, value = 250),
    checkboxInput('show_density', 'Show density line', value = FALSE),
    verbatimTextOutput('sidebar_width_text')
  ),
  # main content (passed as children)
  tags$div(
    id = 'main-content',
    tabsetPanel(id = 'main_tabs',
     tabPanel('About',
        value = 'about',
        tags$div(
          style = 'padding: 12px; max-width:720px;',
          h3('About this prototype'),
          p('This prototype demonstrates a resizable sidebar using a CSS variable and a custom Shiny message (setSidebarWidth).'),
          p('Server sends: session$sendCustomMessage("setSidebarWidth", value) on slider change.'),
          tags$ul(
            tags$li('Sidebar default width: 250px'),
            tags$li('Slider range: 150–500 px'),
            tags$li('Drag handle and keyboard (arrow keys) supported')
          ),
          p('See repository PRD and wireframes for design notes.')
        )
      ),
      tabPanel('Example',
        value = 'example',
        tags$div(
          style = 'padding: 12px;',
          h3('Resizable Sidebar — Example'),
          p('Move the slider to change the sidebar width and the histogram bins (mapped). You can also drag the handle.') ,
          plotOutput('main_plot', height = '420px'),
          textOutput('plot_info')
        )
      )
    ),
    # drag handle sits inside the layout and is absolutely positioned using CSS var
    tags$div(id = 'drag-handle', tabindex = '0')
  ),
  tags$head(
    tags$style(HTML(css))
  ),
  # JS must be added as a tag inside the UI so it's sent to the client
  tags$script(HTML(js))
)

server <- function(input, output, session){

  # Clamp and forward slider changes to client as custom message
  observeEvent(input$sidebar_slider, {
    val <- as.numeric(input$sidebar_slider)
    if (is.na(val)) return()
    val <- min(500, max(150, round(val)))
    session$sendCustomMessage('setSidebarWidth', val)
  })

  # When client sends back width (from drag), update the slider for parity
  observeEvent(input$sidebar_width_from_js, {
    val <- as.numeric(input$sidebar_width_from_js)
    if (is.na(val)) return()
    val <- min(500, max(150, round(val)))
    # avoid feedback loop by only updating if different
    if (!isTRUE(all.equal(val, input$sidebar_slider))) {
      updateSliderInput(session, 'sidebar_slider', value = val)
    }
  })

  output$sidebar_width_text <- renderText({
    paste0('Current width: ', input$sidebar_slider, ' px')
  })

  output$main_plot <- renderPlot({
    # map sidebar width 150-500 -> bins 5-60
    width <- as.numeric(input$sidebar_slider)
    bins <- round(((width - 150) / (500 - 150)) * 55 + 5)
    data <- faithful$eruptions
    hist(data, breaks = bins, col = '#5BC0EB', border = 'white', 
         main = paste0('Histogram (bins: ', bins, ')'), xlab = 'Value')
    if (isTRUE(input$show_density)){
      dens <- density(data)
      lines(dens, col = '#FDE74C', lwd = 2)
    }
  })

  output$plot_info <- renderText({
    paste('Sidebar width (px):', input$sidebar_slider)
  })
}

shinyApp(ui, server)
