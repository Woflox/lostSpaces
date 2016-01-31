import entity
import ../globals/globals
import ../geometry/shape
import ../util/util

type
  Floor* = ref object of Entity

proc generateFloor* () =
  var floor = Floor(drawable: true)

  let lineShape = createShape(vertices = @[vec2(-1000,floorY),vec2(1000,floorY)],
                                drawStyle = DrawStyle.line, lineColor = pallette[2] * 3)
  let solidShape = createShape(vertices = @[vec2(-1000,floorY),vec2(1000,floorY),
                                            vec2(-1000,-1000),vec2(1000,-1000)],
                               drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0))
  floor.shapes = @[lineShape, solidShape]
  floor.init()
  addEntity(floor)
