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
  result = vec2((float(x) - numTilesX * 0.5) * tileSize, (float(y) - numTilesY * 0.5) * tileSize)

type
  TileObject = ref object of Entity
    x, y: int
  LineObject = ref object of TileObject
    tileRotation, palletteIndex: int
    t: float

proc newLineObject* (x, y, tileRotation, palletteIndex: int): LineObject =
  result = LineObject(drawable: true, x:x, y:y, tileRotation: tileRotation, palletteIndex: palletteIndex)

  let lineShape = createShape(vertices = @[vec2(0,0),vec2(0,0)],
                                drawStyle = DrawStyle.line)
  let solidShape = createShape(vertices = @[vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0)],
                               drawStyle = DrawStyle.solid)
  result.shapes = @[lineShape, solidShape]
  result.init()

method update(self: LineObject, dt: float) =
  self.t += dt

  if self.t > 0.5:
    self.t -= 0.5
    self.tileRotation = (self.tileRotation + 1) mod 8

  let tilePos = getTilePos(self.x, self.y)
  self.shapes[0].vertices[0] = lineRelativeVertices[self.tileRotation][0] * tileSize + tilePos
  self.shapes[0].vertices[1] = lineRelativeVertices[self.tileRotation][1] * tileSize + tilePos
  self.shapes[1].vertices[0] = solidRelativeVertices[self.tileRotation][0] * tileSize + tilePos
  self.shapes[1].vertices[1] = solidRelativeVertices[self.tileRotation][1] * tileSize + tilePos
  self.shapes[1].vertices[2] = solidRelativeVertices[self.tileRotation][2] * tileSize + tilePos
  self.shapes[1].vertices[3] = solidRelativeVertices[self.tileRotation][3] * tileSize + tilePos

  let color = pallette[self.palletteIndex]
  self.shapes[0].lineColor = color
  self.shapes[1].fillColor = color * 0.125

  echo self.shapes[1].fillColor

