import ../util/util

var
  screenSize*: Vector2
  screenWidth*, screenHeight*: int
  screenAspectRatio*: float
  pallette*: array[0..3, Color]


const
  numTilesX* = 10
  numTilesY* = 10
  tileSize* = 10.0
  tileOffset* = vec2(-50, -60)
