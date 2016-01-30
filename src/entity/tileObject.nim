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
  result = vec2(float(x) * tileSize, float(y) * tileSize) + tileOffset

type
  TileObject = ref object of Entity
    x, y: int
  LineObject = ref object of TileObject
    tileRotation: int
    palletteIndex: int

proc newLineObject* (x, y, lineRotation, lineColor: int): LineObject =
  result = LineObject(drawable: true)

  let lineShape = createShape(vertices = @[vec2(0,0),vec2(0,0)],
                                drawStyle = DrawStyle.line)
  let solidShape = createShape(vertices = @[vec2(0,0),vec2(0,0),vec2(0,0),vec2(0,0)],
                               drawStyle = DrawStyle.solid)
  result.shapes = @[lineShape, solidShape]
  result.init()

method update(self: LineObject, dt: float) =
  let tilePos = getTilePos(self.x, self.y)
  self.shapes[0].vertices[0] = lineRelativeVertices[self.tileRotation][0] * tileSize + tilePos
  self.shapes[0].vertices[1] = lineRelativeVertices[self.tileRotation][1] * tileSize + tilePos
  self.shapes[1].vertices[0] = lineRelativeVertices[self.tileRotation][0] * tileSize + tilePos
  self.shapes[1].vertices[1] = lineRelativeVertices[self.tileRotation][1] * tileSize + tilePos
  self.shapes[1].vertices[2] = lineRelativeVertices[self.tileRotation][2] * tileSize + tilePos
  self.shapes[1].vertices[3] = lineRelativeVertices[self.tileRotation][3] * tileSize + tilePos

  let color = pallette[self.palletteIndex]
  self.shapes[0].lineColor = color
  self.shapes[1].fillColor = color * 0.25

