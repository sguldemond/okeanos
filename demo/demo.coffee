Okeanos = require '../'

$ = new Okeanos

# settings

gap = 25
config = x: 2, y: 2
gridCache = {}

makeGrid = (length, offset, x, grid_a, grid_b) ->

  points = []

  size = length / x
  for i in [0..x]
    p = i * size

    if p is 0
      grid_a.push gap + offset

    else if p is length
      grid_b.push length - gap + offset

    else
      grid_a.push p + gap / 2 + offset
      grid_b.push p - gap / 2 + offset

findClosestPoint = (num, array) ->
  closest = null
  min = Infinity
  for i in array
    diff = Math.abs i - num
    if diff < min
      min = diff
      closest = i
  return closest

snapToGrid = (frame, grid) ->
  out = {}

  out.y = findClosestPoint frame.y, grid.north
  out.h = findClosestPoint frame.h + frame.y, grid.south
  out.h -= out.y

  out.x = findClosestPoint frame.x, grid.west
  out.w = findClosestPoint frame.w + frame.x, grid.east
  out.w -= out.x

  return out


getGrid = (screen) ->

  if gridCache[screen.id]?
    return then: (fn) -> fn gridCache[screen.id]

  screen.getFrame().then (frame) ->

    grid = gridCache[screen.id] =
      north: []
      south: []
      east: []
      west: []

    makeGrid frame.w, frame.x, config.x, grid.west, grid.east
    makeGrid frame.h, frame.y, config.y, grid.north, grid.south

    return grid


shiftGridSnap = (diff, direction) ->

  $.window.active('frame', 'screen', 'otherWindows').then (win) ->

    if diff is 'reset'
      delete gridCache[win.screen.id]

    getGrid(win.screen).then (grid) ->

      if typeof diff is 'number' and diff isnt 0
        switch direction
          when 'x'
            moveGrid diff, grid.west, grid.east
          when 'y'
            moveGrid diff, grid.north, grid.south

      win.otherWindows.forEach (window) ->
        window.getFrame().then (frame) ->
          window.setFrame snapToGrid frame, grid

      win.setFrame snapToGrid win.frame, grid


# Move the points in a grid
moveGrid = (diff, grid_a, grid_b) ->
  # assuming grid_a.length is grid_b.length
  for i in [0...grid_a.length]
    if i isnt 0
      grid_a[i] += diff
    if i isnt grid_a.length - 1
      grid_b[i] += diff

# mixins

focus = (direction) ->
  $.window.active().then (win) ->
    win.focusTo direction

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

$.bind('h', ['Cmd', 'Shift']).then -> shiftGridSnap -x, 'x'
$.bind('l', ['Cmd', 'Shift']).then -> shiftGridSnap  x, 'x'
$.bind('j', ['Cmd', 'Shift']).then -> shiftGridSnap -x, 'y'
$.bind('k', ['Cmd', 'Shift']).then -> shiftGridSnap  x, 'y'

$.bind('h', ['Cmd', 'Ctrl']).then -> snap 'left'
$.bind('l', ['Cmd', 'Ctrl']).then -> snap 'right'
$.bind('j', ['Cmd', 'Ctrl']).then -> snap 'down'
$.bind('k', ['Cmd', 'Ctrl']).then -> snap 'up'
$.bind('n', ['Cmd', 'Ctrl']).then -> snap 'fill'

$.bind('m', ['Cmd', 'Shift']).then -> shiftGridSnap()
$.bind('e', ['Cmd', 'Shift']).then -> shiftGridSnap 'reset'
