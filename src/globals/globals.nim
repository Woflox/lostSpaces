import ../util/util

type
  GameState* {.pure.} = enum
    textEntry, drawing, exploring

var
  screenSize*: Vector2
  screenWidth*, screenHeight*: int
  screenAspectRatio*: float
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