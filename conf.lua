function love.conf(t)
 
  t.console = true
  t.modules.thread = true             -- Enable the thread module (boolean)
  t.window.display = 2                -- Index of the monitor to show the window in (number)
  t.window.width = 1024
  t.window.height = 768
  t.window.fullscreen = true         -- Enable fullscreen (boolean)

  t.window.fullscreentype = "exclusive" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.borderless = false 
end
