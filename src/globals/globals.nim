import ../util/util
import math
import strutils

type
  GameState* {.pure.} = enum
    textEntry, drawing, exploring

var
  screenSize*: Vector2
  screenWidth*, screenHeight*: int
  screenAspectRatio*: float
  crosshairPos*: Vector2
  specialSignalPos*: Vector2

  #OLD STUFF
  pallette*: array[0..2, Color]
  gameState*: GameState
  currentPoem*: seq[string] = @[]
  poemTextEntered*: string = ""
  caption*: string
  stateTime*: float
  startedTalking*: bool
  talkProgress*: float
  timeAfterTalkFinished*: float
  onHubLevel*: bool
  killMusic*: bool

const
  scanAreaWidth* = 16
  scanAreaHeight* = 8
  specialSignalRadius* = 0.125
  measureLength* = 1.5

  #OLD STUFF
  numTilesX* = 8
  numTilesY* = 8
  tileSize* = 10.0
  floorY* = -numTilesY * 0.5 * tileSize
  screenEdge* = tileSize * numTilesX
  numLevelScreens* = 8
  doorSpacing* = 40
  doorsPerScreen* = 4
  wallPadding* = 5.0

var
  exitDoorText*: string
  normalDoorTexts*: array[0..(doorsPerScreen - 1), string]
  
proc getDoorX*(number: int): float =
  return float(number mod doorsPerScreen) * doorSpacing - doorSpacing * float(doorsPerScreen - 1) / 2

proc convertToText*(coord: float, isX: bool): string =
  var translatedCoord = coord;
  if isX:
    translatedCoord += scanAreaWidth / 2
  else:
    translatedCoord += scanAreaHeight / 2
  let scaledCoord = int((translatedCoord / scanAreaWidth) * 1000)
  return intToStr(scaledCoord, 3)

proc convertToSpeakableText*(coord: Vector2): string =
  let hex = convertToText(coord.x, true) & convertToText(coord.y, false)
  result = ""
  for c in hex:
    case c:
      of '2':
        result &= "Tooo. "
      of '8':
        result &= "Ay eet. "
      else:
        result &= c & ". "