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
  numTilesX* = 7
  numTilesY* = 7
  tileSize* = 10.0
  tileOffset* = vec2(0, -10)
  numLevelScreens* = 8
