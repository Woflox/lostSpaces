import ../util/util
import ../util/noise
import ../globals/globals
import opengl
import entity
import math
import ../geometry/shape

const lineRelativeVertices =
  [[vec2(-0.5, -0.5), vec2(-0.5, 0.5)],
  [vec2(-0.5, -0.5), vec2(0.5, 0.5)],
  [vec2(-0.5, 0.5), vec2(0.5, 0.5)],
  [vec2(-0.5, 0.5), vec2(0.5, -0.5)],
  [vec2(0.5, -0.5), vec2(0.5, 0.5)],
  [vec2(-0.5, -0.5), vec2(0.5, 0.5)],
  [vec2(-0.5, -0.5), vec2(0.5, -0.5)],
  [vec2(-0.5, 0.5), vec2(0.5, -0.5)]]

const solidRelativeVertices =
  [[vec2(-0.5, -0.5), vec2(-0.5, 0.5), vec2(0.5, 1.5), vec2(0.5, -1.5)],
  [vec2(-0.5, -0.5), vec2(0.5, 0.5), vec2(1.5, 0.5), vec2(-0.5, -1.5)],
  [vec2(-0.5, 0.5), vec2(0.5, 0.5), vec2(1.5, -0.5), vec2(-1.5, -0.5)],
  [vec2(-0.5, 0.5), vec2(0.5, -0.5), vec2(0.5, -1.5), vec2(-1.5, 0.5)],
  [vec2(0.5, -0.5), vec2(0.5, 0.5), vec2(-0.5, 1.5), vec2(-0.5, -1.5)],
  [vec2(-0.5, -0.5), vec2(0.5, 0.5), vec2(0.5, 1.5), vec2(-1.5, -0.5)],
  [vec2(-0.5, -0.5), vec2(0.5, -0.5), vec2(1.5, 0.5), vec2(-1.5, 0.5)],
  [vec2(-0.5, 0.5), vec2(0.5, -0.5), vec2(1.5, -0.5), vec2(-0.5, 1.5)]]

proc getTilePos(x,y: int): Vector2 =
  result = vec2((float(x) - (numTilesX - 1) * 0.5) * tileSize, (float(y) - (numTilesY - 1) * 0.5) * tileSize)

type
  RotateDirection* {.pure.} = enum
    clockwise, counterClockwise
  TileObject* = ref object of Entity
    x*, y*: int
  LineObject* = ref object of TileObject
    tileRotation*, palletteIndex*: int
  LineGroup* = ref object
    tiles* : seq[LineObject]

proc newLineObject* (x, y, tileRotation, palletteIndex: int): LineObject =
  result = LineObject(drawable: true, x:x, y:y, tileRotation: tileRotation, palletteIndex: palletteIndex)

  let lineShape = createShape(vertices = @[vec2(0,0),vec2(0,0)],
                                drawStyle = DrawStyle.line)
  let solidShape = createShape(vertices = @[vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0)],
                               drawStyle = DrawStyle.solid)
  let floorLineShape = createShape(vertices = @[vec2(0,0),vec2(0,0)],
                                drawStyle = DrawStyle.line)
  let bloomShape = createShape(vertices = @[vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0)],
                               drawStyle = DrawStyle.solid)
  result.shapes = @[lineShape, solidShape, floorLineShape, bloomShape]
  result.init()

proc newLineObject* (): LineObject =
  result = newLineObject(0, 0, 0, 0)

method update(self: LineObject, dt: float) =

  let tilePos = getTilePos(self.x, self.y)
  for i in 0..1:
    self.shapes[0].vertices[i] = lineRelativeVertices[self.tileRotation][i] * tileSize + tilePos
  for i in 0..3:
    self.shapes[1].vertices[i] = solidRelativeVertices[self.tileRotation][i] * tileSize + tilePos

  let floorLineIntensity = 0.5 / (float(self.y) + 2)
  let floorLineSize = 1.5 + float(self.y) * 0.5

  self.shapes[2].vertices[0] = vec2(tilePos.x - floorLineSize * tileSize, floorY)
  self.shapes[2].vertices[1] = vec2(tilePos.x + floorLineSize * tileSize, floorY)

  let color = pallette[self.palletteIndex]
  self.shapes[0].lineColor = color
  self.shapes[1].fillColor = color * 0.125
  self.shapes[2].lineColor = color * floorLineIntensity


proc newLineGroup* (tiles: seq[LineObject]): LineGroup =
  result = LineGroup(tiles: tiles)

proc cycleColor* (self: LineObject) =
  self.palletteIndex = (self.palletteIndex + 1) mod 2

proc rotate* (self: LineObject, direction: RotateDirection) =
  case direction:
    of RotateDirection.clockwise:
      self.tileRotation = (self.tileRotation + 1) mod 8
    of RotateDirection.counterClockwise:
      self.tileRotation = (self.tileRotation + 7) mod 8

proc translate* (self: LineObject, x, y: int) =
  self.x += x
  self.y += y

proc keepInBounds* (self: LineGroup) =
  var minX = numTilesX
  var maxX = 0
  var minY = numTilesY
  var maxY = 0

  for line in self.tiles:
    minX = min(minX, line.x)
    maxX = max(maxX, line.x)
    minY = min(minY, line.y)
    maxY = max(maxY, line.y)

  var toMoveX = 0
  var toMoveY = 0

  if maxX > numTilesX - 1:
    toMoveX = (numTilesX - 1) - maxX
  if minX < 0:
    toMoveX = -minX
  if maxY >= numTilesY - 1:
    toMoveY = (numTilesY - 1) - maxY
  if minY < 0:
    toMoveY = -minY

  for tile in self.tiles:
    tile.translate(toMoveX, toMoveY)


proc translate* (self: LineGroup, x, y: int) =
  for line in self.tiles:
    line.translate(x, y)

  self.keepInBounds()


proc rotate* (self: LineGroup, direction: RotateDirection) =
  if self.tiles.len == 1:
    self.tiles[0].rotate(direction)
    return

  for tile in self.tiles:
    tile.rotate(direction)
    tile.rotate(direction)

  var minX = numTilesX
  var maxX = 0
  var minY = numTilesY
  var maxY = 0

  for line in self.tiles:
    minX = min(minX, line.x)
    maxX = max(maxX, line.x)
    minY = min(minY, line.y)
    maxY = max(maxY, line.y)

  let originX = (minX + maxX) div 2
  let originY = (minY + maxY) div 2

  for tile in self.tiles:
    let relX = tile.x - originX
    let relY = tile.y - originY
    case direction:
      of RotateDirection.clockwise:
        tile.x = originX + relY
        tile.y = originY - relX
      of RotateDirection.counterClockwise:
        tile.x = originX - relY
        tile.y = originY + relX

  self.keepInBounds()

proc cycleColor* (self: LineGroup) =
  for tile in self.tiles:
    tile.cycleColor()
