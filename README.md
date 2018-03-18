# Okeanos
Node.js adapter for [Zephyros](https://github.com/sdegutis/zephyros) - the OS X window manager for hackers.

This is a fork of [`okeanos`](https://github.com/stayradiated/okeanos) by [stayradiated](https://github.com/danielepolencic). I changed around the behavior of the controls and some binds. Also changed some moving behavior since I'm using the Ubersicht nerdbar widget.


## Usage
Include `okeanos` in your script and you're ready to go!

```coffeescript
Okeanos = require 'okeanos'

$ = new Okeanos()

$.bind('h', ['Cmd', 'Shift']).then ->
  $.window.active().then (window) ->
    window.nudge -100, 0

```

## React to events

**bind**
`bind( key<String>, modifier<Array> )`
Listen to a particular key combination and fire the chain every time such
shortcut is triggered.

```coffeescript
$.bind('t', ['Cmd', 'Shift']).then ->
  console.log 'Hey, you pressed t+⌘⌃'
```

**listen**
`listen( event<String> )`
Listen to a particular event and fire the chain every time this event occurs.
A comprehensive list of events is available [here](https://github.com/sdegutis/zephyros/blob/master/Docs/Protocol.md)

```coffeescript
$.listen('window_created').then ->
  console.log 'Hey, you created a new window!'
```

## Preloading

This helps a lot with callback hell.

```coffeescript
$.window.active().then (window) ->
  window.getTitle().then (title) ->
    window.getFrame().then (frame) ->
      window.getScreen().then (screen) ->
        console.log title, frame, screen
```

You can use it by requesting all the info at the same time via `model.preload()`.

```coffeescript
$.window.active().then (window) ->
  window.preload('title', 'frame', 'screen').then ->
    console.log window.title, window.frame, window.screen
```

Even better is that you can use preloading directly on `okeanos.window.*`, `okeanos.screen.*` and `okeanos.app.*` methods.

```coffeescript
$.window.active('title', 'frame', 'screen').then (window) ->
  console.log window.title, window.frame, window.screen
```

## Window

### API

**active**
Return a window object with the `id` of the focused window.

```coffeescript
$.window.active().then (window) ->
  console.log window.id
```

**visible**
Return an array containing a window object for each visible window.

```coffeescript
$.window.visible().then (windows) ->
  for window in windows
    console.log window.id
```

**all**
Return an array containing a window object for all the windows.

```coffeescript
$.window.all().then (windows) ->
  for window in windows
    console.log window.id
```

### Class

**getTitle()**

Returns the window title as a string. Cached as `window.title`.

```coffeescript
$.window.active().then (window) ->
  window.getTitle().then (title) ->
    console.log title
```

**getScreen()**

Returns the screen that the windows is in as a new Screen object. Cached as `window.screen`.

```coffeescript
$.window.active().then (window) ->
  window.getScreen().then (screen) ->
    console.log screen.id
```

**getApp()**

Returns the app that created the window as a new App object. Cached as `window.app`.

```coffeescript
$.window.active().then (window) ->
  window.getApp().then (app) ->
    console.log app.id
```

**getFrame()**

Return the coordinates for the window frame in the format {x, y, w, h}. Cached as `window.frame`.

```coffeescript
$.window.active().then (window) ->
  window.getFrame().then (frame) ->
    console.log frame
```

**setFrame( {x, y, w, h} OR x, y, w, h )**

Set the window frame.

```coffeescript
$.window.active().then (window) ->
  window.getFrame().then (frame) ->
    window.setFrame
      x: frame.x / 2
      y: frame.y / 2
      w: frame.w * 2
      h: frame.h * 2
```

**getSize()**

Return the size of the window as { w: width, h: height }.

```coffeescript
$.window.active().then (window) ->
  window.getSize().then (size) ->
    console.log 'width:', size.w,
    console.log 'height:', size.h
```

**setSize( {w, h} OR w, h )**

Set the width and height of the window frame.

```coffeescript
$.window.active().then (window) ->
  window.setSize
    w: 200
    h: 300
```

**resize( w, h )**

Resize the window by adding onto the current size.

```coffeescript
$.window.active().then (window) ->
  window.resize
    w: -100
    h: 200
  # will shrink the width by 100px and add 200px to the height
```

**getPosition()**

Return the position of the top left corner of the window as { x, y }.

**setPosition( {x, y} OR x, y )**

Set the position of the top left corner of the window.

**nudge( x, y )**

Set the position of the top left corner of the window relative to it's current position.

**maximize()**

Maximize the window.

```coffeescript
$.window.active().then (window) ->
  window.maximize()
```

**minimize()**

Minimize the window.

```coffeescript
$.window.active().then (window) ->
  window.minimize()
```

**unminimize()**

Unminimize the window.

```coffeescript
$.window.active().then (window) ->
  window.unminimize()
```

**focus()**

Focus the current window.

**focusTo( ['up', 'down', 'right', 'left'] )**

Move the focus from this window to the specified direction.

```coffeescript
$.window.active().then (window) ->
  window.focusTo 'right'
```

**getWindowsTo( ['north', 'south', 'east', 'west'] )**

Return an array of window objects for windows located on the {north, south,
east, west} of this window.

```coffeescript
$.window.active().then (window) ->
  window.getWindowsTo('north').then (windows) ->
    for window in windows
      console.log window.id
```

**getOtherWindows()**

Get an array of all the other windows on the same screen. Cached as `allOtherWindows`.

**getAllOtherWindows()**

Get an array of all the other windows on all the screens. Cached as `allOtherWindows`.

**isNormal()**

Check if the window is normal. Not sure what this means yet. Cached as `window.normal`.

**isMinimized()**

Check if the window is minimized. Cached as `window.minimized`

## Screen

### API

**main()**

Return the main screen.

**all()**

Return an array of all the screens.

### Class

**getFrame()**

Get the frame of the *usable* part of the screen -- meaning it doesn't include the dock or menu.

**getFullFrame()**

Get the frame of the entire screen -- including the dock and menu.

**previous()**

Get the previous screen.

**next()**

Get the next screen.

**rotate( [0, 90, 180, 270 ] )**

Rotate the display.


## App

### Api

**all()**

Return an array of all the running applications.

```coffeescript
$.app.all('title').then (apps) ->
  for app in apps
    console.log app.title
```

### Class

**allWindows()**

Get all the windows created by this application. Cached as `app.all`.

```coffeescript
$.window.active('app').then (window) ->
  window.app.allWindows().then (windows) ->
    console.log windows
```

**visibleWindows()**

Get all the *visible* windows created by this application. Cached as `app.visible`.

**getTitle()**

Get the title of the appliation. Cached as `app.title`.

**isHidden()**

Check if the app is hiden. Cached as `app.hidden`.

**show()**

Show the application.

**hide()**

Hide the application.

**kill()**

Kill the application.

**kill9()**

Kill9 the application.

## Util

### Api

**clipboard()**

Return a string with the content of the clipboard

```coffeescript
$.util.clipboard().then (clipboard) ->
  console.log clipboard
```

**updateSettings()**

Trigger an update for Zephyros settings.

```coffeescript
$.util.updateSettings()
```

**relaunch()**

Force a reload of the config file.

```coffeescript
$.util.relaunch()
```

**alert( message, [duration = 1] )**

Prompt an alter.

```coffeescript
$.util.alert 'hello world'    # show for 1 second
$.util.alert 'hello world', 5 # show for 5 seconds
$.util.alert
  message: 'hello world'
  duration: 5
```

**log( message )**

Log a string.

```coffeescript
$.util.log 'hello world'
```

**chooseFrom( list, title, width, height )**

Choose a list of items from a dynamically populated popup.

```coffeescript
$.util.chooseFrom(
  list: ['Banana', 'Pineapple', 'Orange']
  title: 'Fruits'
  height: 10
  width: 30
).then (selected) ->
  console.log selected # index of the array
```

**undo()**

Undo the last action.

```coffeescript
$.window.active().then (window) ->
  window.maximise()
  $.util.undo()
  $.util.redo()
```

**redo()**

Redo the last action.

```coffeescript
$.window.active().then (window) ->
  window.maximise()
  $.util.undo()
  $.util.redo()
```

## Tests
Tests are written in [Mocha](http://visionmedia.github.io/mocha/). Simply run
the test with:

    ~$ npm test
