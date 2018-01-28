import sdl2
import opengl
import util/util
import globals/globals
import ui/screen
import ui/text
from audio/audio import nil
from input/input import nil
from world/world import nil
from render/renderer import nil

const fullScreen = true

var windowFlags = SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE
if fullScreen:
  windowFlags = SDL_WINDOW_OPENGL or SDL_WINDOW_FULLSCREEN_DESKTOP

discard init(INIT_EVERYTHING)
var window = createWindow("LOST TRANSMISSIONS", 100, 100, 1280, 720, windowFlags)
var context = window.glCreateContext()

proc resize() =
  var width, height: cint
  window.getSize(width, height)
  let aspect = float(width)/float(height)

  screenSize = vec2(float(width), float(height))
  screenWidth = width
  screenHeight = height
  screenAspectRatio = aspect

  renderer.resize()

var
  event: Event = Event(kind:UserEvent)
  runGame = true
  t = getTicks()

proc update() =
  let now = getTicks()
  let dt = float(now - t) * 0.001
  t = now

  input.update(dt)
  world.update(dt)
  currentScreen.update(dt)
  renderer.update(dt)

proc render() =
  renderer.render()
  window.glSwapWindow()

renderer.init()
input.init()
audio.initAudio()
world.init()

while runGame:
  while pollEvent(event):
    case event.kind:
      of QuitEvent:
        runGame = false
        break
      of WindowEvent:
        resize()
      else:
        input.addEvent(event)
  update()
  render()

destroy window
