Okeanos = require '../'

$ = new Okeanos

# settings

s_width = 1920
gap = 30

managed = []

# mixins

setWindows = ->
  managed = []
  $.window.active('otherWindows').then (win) ->
    managed.push win.id
    managed.push window.id for window in win.otherWindows

focus = (direction) ->
  $.window.active().then (win) ->
    win.focusTo direction

resize = (x, y) ->
  $.window.active().then (win) ->

    if x < 0
      win.move x, y, -x, y
      win.getWindowsTo('west').then (windows) ->
        for window in windows when window.id in managed
          window.resize x, y

    else if x > 0
      win.resize x, y
      win.getWindowsTo('east').then (windows) ->
        for window in windows when window.id in managed
          window.move x, y, -x, y



# resize = (w, h) ->
#   $.window.active().then (win) ->
#     win.resize w, h

snap = (direction) ->
  $.window.active('frame', 'screen').then (win) ->
    win.screen.getFrame().then (screen) ->

      frame =
        x: screen.x + gap
        y: screen.y + gap
        w: screen.w - (gap * 2)
        h: screen.h - (gap * 2)

      switch direction

        when 'up'
          frame.x = win.frame.x
          frame.y = frame.y
          frame.w = win.frame.w
          frame.h = frame.h / 2 - gap / 2

        when 'down'
          frame.x = win.frame.x
          frame.y = frame.y + frame.h / 2 + gap / 2
          frame.w = win.frame.w
          frame.h = frame.h / 2 - gap / 2

        when 'right'
          frame.x = frame.x + gap / 2 +  frame.w / 2
          frame.w = frame.w / 2 - gap / 2

        when 'left'
          frame.w = frame.w / 2 - gap / 2

      win.setFrame frame

# bindings

x = 100

$.bind('l', ['Cmd']).then -> focus 'right'
$.bind('h', ['Cmd']).then -> focus 'left'
$.bind('j', ['Cmd']).then -> focus 'down'
$.bind('k', ['Cmd']).then -> focus 'up'

$.bind('h', ['Cmd', 'Shift']).then -> resize -x, 0
$.bind('l', ['Cmd', 'Shift']).then -> resize x, 0
$.bind('j', ['Cmd', 'Shift']).then -> resize 0, x
$.bind('k', ['Cmd', 'Shift']).then -> resize 0, -x

# $.bind('[', ['Cmd', 'Shift']).then -> resize -x, 0
# $.bind(']', ['Cmd', 'Shift']).then -> resize x, 0
# $.bind('-', ['Cmd', 'Shift']).then -> resize 0, -x
# $.bind('=', ['Cmd', 'Shift']).then -> resize 0, x

$.bind('h', ['Cmd', 'Ctrl']).then -> snap 'left'
$.bind('l', ['Cmd', 'Ctrl']).then -> snap 'right'
$.bind('j', ['Cmd', 'Ctrl']).then -> snap 'down'
$.bind('k', ['Cmd', 'Ctrl']).then -> snap 'up'
$.bind('n', ['Cmd', 'Ctrl']).then -> snap 'fill'

$.bind('m', ['Cmd', 'Ctrl']).then -> setWindows()
