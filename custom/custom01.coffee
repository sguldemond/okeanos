fs = require 'fs'
net = require 'net'
Okeanos = require '../'
{exec} = require 'child_process'

$ = new Okeanos

updateTitle = ->
  $.window.active('title').then (win) ->
    exec "echo \"#{ win.title }\" > /tmp/bar.fifo"

# SETTINGS

# Padding around the window edges
gap = 25

# Height of the top bar
top_bar = 20

divide = 0

# Grid settings
config = x: 10, y: 4
gridCache = {}

$.window.active('screen').then (win) ->
  divide = screen.x / 2

settings =
  load: ->

    try
      data = fs.readFileSync __dirname + '/settings.json'
    catch e
      console.log e

    if data
      data = JSON.parse data
      config.x = data.x
      config.y = data.y
      gap = data.gap
      # top_bar = data.top_bar

  timeout: null

  save: ->
    if settings.timeout
      clearTimeout settings.timeout
    settings.timeout = setTimeout settings._save, 5 * 1000

  _save: ->
    data =
      gap: gap
      x: config.x
      y: config.y
    fs.writeFile __dirname + '/settings.json', JSON.stringify(data, null, 2)

settings.load()

###
  Make a grid between two points
  - position (int) : the offset point of the grid, e.g. 0
  - length (int) : the number of pixels in the grid e.g. 1920
  - sections (int) : the number of sections to have
  > returns an object with two arrays
###
createGrid = (offset, length, sections) ->

  a = []
  b = []
  points = []

  size = length / sections

  for i in [0..sections]
    p = i * size

    if p is 0
      a.push gap + offset

    else if p is length
      b.push length - gap + offset

    else
      a.push p + gap / 2 + offset
      b.push p - gap / 2 + offset

  return [a, b, size]

###
  Find the closest value in an array
  - num (int) - the number to match
  - array (int[]) - the numbers to choose from
  > returns the chosen number
###
findClosestPoint = (num, array) ->
  closest = null
  min = Infinity
  for i in array
    diff = Math.abs i - num
    if diff < min
      min = diff
      closest = i
  return closest


###
  Snap a window frame to a grid
  - frame (object) : the window frame
  - grid (object) : the grid
  > returns a new window frame that fits on the grid
###
snapFrameToGrid = (frame, grid) ->
  out = {}
  out.y = findClosestPoint(frame.y, grid.north)
  out.h = findClosestPoint(frame.h + frame.y, grid.south) - out.y
  out.x = findClosestPoint(frame.x, grid.west)
  out.w = findClosestPoint(frame.w + frame.x, grid.east) - out.x
  return out


###
  Generate a grid for a screen
  - screen (Screen) : the screen
  > returns the grid screen grid
###
getGrid = (screen) ->

  if gridCache[screen.id]?
    return then: (fn) -> fn gridCache[screen.id]

  screen.getFrame().then (frame) ->
    grid = gridCache[screen.id] = {}
    [grid.west,  grid.east,  grid.x] = createGrid frame.x, frame.w, config.x
    [grid.north, grid.south, grid.y] = createGrid frame.y + top_bar, frame.h - top_bar, config.y
    return grid


###
  Snap all windows to the grid.
  Only alters windows on the current screen.
###
snapAllWindowsToGrid = ->

  # Get information about the current window
  $.window.active('frame', 'screen', 'otherWindows').then (win) ->

    # Get the grid for the current screen
    getGrid(win.screen).then (grid) ->

      # Snap the current window to the grid
      win.setFrame snapFrameToGrid win.frame, grid

      # Snap all the other windows to the grid
      win.otherWindows.forEach (window) ->
        window.getFrame().then (frame) ->
          return unless frame.h > 26
          window.setFrame snapFrameToGrid frame, grid


###
  Move a window in a direction on the grid
  - direction (string) : 'left', 'right', 'up', 'down'
###
moveWindow = (direction) ->

  $.window.active('frame', 'screen').then (win) ->

    return unless win.frame.h > 26

    getGrid(win.screen).then (grid) ->

      switch direction

        when 'move left'
          win.frame.x -= grid.x
        when 'move right'
          win.frame.x += grid.x
        when 'move down'
          win.frame.y += grid.y
        when 'move up'
          win.frame.y -= grid.y

        when 'push left'
          win.frame.w -= grid.x
        when 'push right'
          win.frame.w += grid.x
        when 'push down'
          win.frame.h += grid.x
        when 'push up'
          win.frame.h -= grid.x

      win.setFrame snapFrameToGrid win.frame, grid

###
  Switch the screen that the window is on
###
switchScreen = ->
  $.window.active('screen').then (win) ->
    win.screen.preload('fullFrame', 'nextScreen').then (screen) ->
      screen.nextScreen.getFullFrame().then (nextFrame) ->
        diff = nextFrame.x - screen.fullFrame.x
        win.nudge diff, 0

###
  Move focus to another window
  - direction (string) : The direction to focus to
###
focus = (direction) ->
  $.window.active().then (win) ->
    win.focusTo direction


###
  Minimize the current window
###
minimize = ->
  $.window.active().then (win) ->
    win.minimize()


###
  Snap a window into a position on the screen.
  Does not use the grid.
  - direction (string) : the direction you want to snap
###
snap = (direction) ->
  $.window.active('frame', 'screen').then (win) ->
    win.screen.getFrame().then (screen) ->

      frame =
        x: screen.x + gap
        y: screen.y + gap + top_bar
        w: screen.w - (gap * 2)
        h: screen.h - (gap * 2) - top_bar

      switch direction

        when 'up'
          frame.h = frame.h / 2 - gap / 2

        when 'down'
          frame.y = frame.y + frame.h / 2 + gap / 2
          frame.h = frame.h / 2 - gap / 2

        when 'right'
          frame.x = frame.x + gap / 2 +  frame.w / 2
          frame.w = frame.w / 2 - gap / 2

        when 'left'
          frame.w = frame.w / 2 - gap / 2

      win.setFrame frame

###
  BINDINGS
###

x = 100

left_key = 'j'
right_key = 'l'
down_key = 'k'
up_key = 'i'

# $.bind(left, ['Cmd']).then -> focus 'left'
# $.bind(right, ['Cmd']).then -> focus 'right'
# $.bind(down, ['Cmd']).then -> focus 'down'
# $.bind(up, ['Cmd']).then -> focus 'up'

$.bind(left_key, ['Alt']).then -> moveWindow 'move left'
$.bind(right_key, ['Alt']).then -> moveWindow 'move right'
$.bind(down_key, ['Alt']).then -> moveWindow 'move down'
$.bind(up_key, ['Alt']).then -> moveWindow 'move up'

$.bind(left_key, ['Cmd', 'Alt']).then -> moveWindow 'push left'
$.bind(right_key, ['Cmd', 'Alt']).then -> moveWindow 'push right'
$.bind(down_key, ['Cmd', 'Alt']).then -> moveWindow 'push down'
$.bind(up_key, ['Cmd', 'Alt']).then -> moveWindow 'push up'

$.bind(left_key, ['Cmd', 'Shift']).then -> snap 'left'
$.bind(right_key, ['Cmd', 'Shift']).then -> snap 'right'
$.bind(down_key, ['Cmd', 'Shift']).then -> snap 'down'
$.bind(up_key, ['Cmd', 'Shift']).then -> snap 'up'

$.bind('f', ['Cmd', 'Shift']).then -> snap 'fill'

$.bind('m', ['Cmd', 'Alt']).then -> minimize()

$.bind('m', ['Cmd', 'Shift']).then -> snapAllWindowsToGrid()
$.bind('e', ['Cmd', 'Shift']).then -> switchScreen()

$.bind('=', ['Cmd', 'Alt']).then ->
  gap -= 5
  settings.save()
  gridCache = {}
  snapAllWindowsToGrid()

$.bind('-', ['Cmd', 'Alt']).then ->
  gap += 5
  settings.save()
  gridCache = {}
  snapAllWindowsToGrid()

$.bind('z', ['Cmd', 'Shift', 'Ctrl', 'Alt']).then ->
  config.x -= 1
  settings.save()
  $.util.alert JSON.stringify config
  gridCache = {}
  snapAllWindowsToGrid() snapAllWindowsToGrid()

$.bind('x', ['Cmd', 'Shift', 'Ctrl', 'Alt']).then ->
  config.x += 1
  settings.save()
  $.util.alert JSON.stringify config
  gridCache = {}
  snapAllWindowsToGrid() snapAllWindowsToGrid()

$.bind('a', ['Cmd', 'Shift', 'Ctrl', 'Alt']).then ->
  config.y -= 1
  settings.save()
  $.util.alert JSON.stringify config
  gridCache = {}
  snapAllWindowsToGrid() snapAllWindowsToGrid()

$.bind('r', ['Cmd', 'Shift', 'Ctrl', 'Alt']).then ->
  config.y += 1
  settings.save()
  $.util.alert JSON.stringify config
  gridCache = {}
  snapAllWindowsToGrid() snapAllWindowsToGrid()

$.bind('f', ['Cmd', 'Shift', 'Ctrl', 'Alt']).then ->
  $.listen('focus_changed').then -> updateTitle()
