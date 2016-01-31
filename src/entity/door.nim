import entity
import ../globals/globals
import ../geometry/shape
import ../util/util

type
  Door* = ref object of Entity
    number* :int

const
  doorWidth = 10
  doorHeight = 25
  floorLineWidth = 20
  floorLineIntensity = 0.125

proc generateDoor* (x: float, number: int) =
  var door = Door(drawable: true, number:number)

  let color = pallette[2] * 10

  let arch = createShape(vertices = @[vec2(-doorWidth,0),vec2(-doorWidth,doorHeight),vec2(doorWidth,doorHeight),vec2(doorWidth,0),vec2(doorWidth,doorHeight),vec2(-doorWidth,doorHeight)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let solidShape = createShape(vertices = @[vec2(-doorWidth,0),vec2(-doorWidth,doorHeight),
                                            vec2(doorWidth,doorHeight),vec2(doorWidth,0)],
                               drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0))
  let floorLineShape = createShape(vertices = @[vec2(-floorLineWidth,0),vec2(floorLineWidth,0)],
                                drawStyle = DrawStyle.line, lineColor = color * floorLineIntensity)
  door.shapes = @[arch, solidShape, floorLineShape]
  door.position = vec2(x, floorY)
  door.init()
  addEntity(door)
