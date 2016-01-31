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
  stateTime*: float

const
  numTilesX* = 8
  numTilesY* = 8
  tileSize* = 10.0
  floorY* = -numTilesY * 0.5 * tileSize
  numLevelScreens* = 8
