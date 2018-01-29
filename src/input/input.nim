import sdl2
import sdl2/joystick
import sdl2/gamecontroller
import ../util/util
import queues
import ../ui/text
import tables

var
  leftStickMoveDir*: Vector2
  rightStickMoveDir*: Vector2
  buttonMoveDir: Vector2
  leftTrigger: float
  rightTrigger: float
  controller: GameControllerPtr

type
  Action* = enum
    left, right, up, down, rotateLeft, rotateRight, cycleColor, place, confirm, exit

  Control = ref object
    action: Action
    key: cint
    button: uint8
    down: bool
    pressed: bool
    released: bool

const maxAxisValue = 32768.0
const deadZone = 0.1

var
  controls* = [Control(action: left,  key: K_LEFT,  button: SDL_CONTROLLER_BUTTON_DPAD_LEFT),
               Control(action: right, key: K_RIGHT, button: SDL_CONTROLLER_BUTTON_DPAD_RIGHT),
               Control(action: up,    key: K_UP,    button: SDL_CONTROLLER_BUTTON_DPAD_UP),
               Control(action: down,  key: K_DOWN,  button: SDL_CONTROLLER_BUTTON_DPAD_DOWN),
               Control(action: rotateLeft, key: K_A,  button: SDL_CONTROLLER_BUTTON_A),
               Control(action: rotateRight, key: K_D, button: SDL_CONTROLLER_BUTTON_B),
               Control(action: cycleColor, key: K_S,  button: SDL_CONTROLLER_BUTTON_X),
               Control(action: place, key: K_SPACE,    button: SDL_CONTROLLER_BUTTON_Y),
               Control(action: confirm, key: K_RETURN, button: SDL_CONTROLLER_BUTTON_START),
               Control(action: exit, key: K_ESCAPE, button: SDL_CONTROLLER_BUTTON_MAX)]

  events = initQueue[Event]()
  enteredText*: string

proc addEvent*(event: var Event) =
  events.enqueue(event)

proc handleEvent(event: var Event) =
  case event.kind:
    of ControllerAxisMotion:
      case event.caxis.axis:
        of uint8(SDL_CONTROLLER_AXIS_LEFTX):
          let axisValue = float(event.caxis.value) / maxAxisValue
          leftStickMoveDir.x = if abs(axisValue) > deadZone: axisValue else: 0
        of uint8(SDL_CONTROLLER_AXIS_LEFTY):
          let axisValue = float(event.caxis.value) / maxAxisValue
          leftStickMoveDir.y = if abs(axisValue) > deadZone: -axisValue else: 0
        of uint8(SDL_CONTROLLER_AXIS_RIGHTX):
          let axisValue = float(event.caxis.value) / maxAxisValue
          if axisValue > 0:
            rightStickMoveDir.x = if abs(axisValue) > deadZone: (axisValue - deadZone) / (1 - deadZone) else: 0
          else:
            rightStickMoveDir.x = if abs(axisValue) > deadZone: (axisValue + deadZone) / (1 - deadZone) else: 0
        of uint8(SDL_CONTROLLER_AXIS_RIGHTY):
          let axisValue = float(event.caxis.value) / maxAxisValue
          if axisValue > 0:
            rightStickMoveDir.y = if abs(axisValue) > deadZone: (axisValue - deadZone) / (1 - deadZone) else: 0
          else:
            rightStickMoveDir.y = if abs(axisValue) > deadZone: (axisValue + deadZone) / (1 - deadZone) else: 0

        of uint8(SDL_CONTROLLER_AXIS_TRIGGERLEFT):
          let axisValue = float(event.caxis.value) / maxAxisValue
          leftTrigger = axisValue
        of uint8(SDL_CONTROLLER_AXIS_TRIGGERRIGHT):
          let axisValue = float(event.caxis.value) / maxAxisValue
          rightTrigger = axisValue
        else:
          discard

    of ControllerButtonDown:
      for control in controls:
        if control.button == event.cbutton.button:
          control.pressed = true
          control.down = true

    of ControllerButtonUp:
      for control in controls:
        if control.button == event.cbutton.button:
          control.released = true
          control.down = false

    of KeyDown:
      let sym = event.key.keysym.sym
      if not event.key.repeat:
        for control in controls:
          if control.key == sym:
            control.pressed = true
            control.down = true
      if letters.hasKey(char(sym)) or sym == cint(' ') or sym == cint('\b'):
        enteredText = if char(sym) == '1': "!" elif char(sym) == '/': "?" else: $char(sym)

    of KeyUp:
        for control in controls:
          if control.key == event.key.keysym.sym:
            control.released = true
            control.down = false
    else:
      discard

proc buttonDown*(action: Action): bool =
  result = controls[int(action)].down

proc buttonPressed*(action: Action): bool =
  result = controls[int(action)].pressed

proc buttonReleased*(action: Action): bool =
  result = controls[int(action)].released

proc startText* () =
  startTextInput()

proc stopText* () =
  stopTextInput()

#proc moveDir*(): Vector2 =
#  result = if stickMoveDir == vec2(0, 0): buttonMoveDir else: stickMoveDir.normalize()

proc init*() =
  for i in 0..(numJoysticks() - 1):
    if isGameController(i):
      controller = gameControllerOpen(i)


proc update*(dt: float) =
  for control in controls:
    control.pressed = false
    control.released = false

  enteredText = ""

  while events.len > 0:
    var event = events.dequeue()
    handleEvent(event)

  buttonMoveDir = vec2(0,0)
  if buttonDown(left):
    buttonMoveDir.x -= 1
  if buttonDown(right):
    buttonMoveDir.x += 1
  if buttonDown(up):
    buttonMoveDir.y += 1
  if buttonDown(down):
    buttonMoveDir.y -= 1
