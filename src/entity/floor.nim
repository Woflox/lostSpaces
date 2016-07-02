import entity
import ../globals/globals
import ../geometry/shape
import ../util/util

type
  Floor* = ref object of Entity

proc generateFloor* (leftWall, rightWall: bool) =
  var floor = Floor(drawable: true)

  let leftBoundary = if leftWall: -(screenEdge + wallPadding) else: -1000
  let rightBoundary = if rightWall: screenEdge + wallPadding else: 1000

  let lineShape = createShape(vertices = @[vec2(leftBoundary,floorY),vec2(rightBoundary,floorY)],
                                drawStyle = DrawStyle.line, lineColor = pallette[2] * 3)
  let solidShape = createShape(vertices = @[vec2(-1000,floorY),vec2(1000,floorY),
                                            vec2(-1000,-1000),vec2(1000,-1000)],
                               drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0))
  floor.shapes = @[lineShape, solidShape]

  if leftWall:
   # floor.shapes.add(createShape(vertices = @[vec2(leftBoundary, floorY), vec2(leftBoundary, 1000)],
   #                                 drawStyle = DrawStyle.line, lineColor = pallette[2] * 3))
    floor.shapes.add(createShape(vertices = @[vec2(leftBoundary, -1000), vec2(leftBoundary, 1000),
                                              vec2(-1000,1000), vec2(-1000,-1000)],
                                 drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0)))
  if rightWall:
   # floor.shapes.add(createShape(vertices = @[vec2(rightBoundary, floorY), vec2(rightBoundary, 1000)],
   #                                 drawStyle = DrawStyle.line, lineColor = pallette[2] * 3))
    floor.shapes.add(createShape(vertices = @[vec2(rightBoundary, -1000), vec2(rightBoundary, 1000),
                                              vec2(1000,1000), vec2(1000,-1000)],
                                 drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0)))

  floor.init()
  addEntity(floor)
