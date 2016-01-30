import ../util/util

var
  screenSize*: Vector2
  screenWidth*, screenHeight*: int
  screenAspectRatio*: float
  pallette*: array[0..2, Color]


const
  numTilesX* = 8
  numTilesY* = 8
  tileSize* = 10.0
  minTileX* = -numTilesX div 2
  maxTileX* = numTilesX div 2
  minTileY* = -numTilesY div 2
  maxTileY* = numTilesY div 2
  tileOffset* = vec2(0, -10)
