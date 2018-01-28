import entity
import math
import ../globals/globals
import ../geometry/shape
import ../util/util
from ../input/input import nil

type
    SpeedGauge* = ref object of Entity
  
proc generateSpeedGauge* =
  var speedGauge = SpeedGauge(drawable: true)

  const offset = 0.5
  const width = 0.5

  let color = color(0.25, 0.1, 0, 1)
  let rectangle = createShape(vertices = @[vec2(scanAreaWidth/2 + offset, -scanAreaHeight/2),
                                           vec2(scanAreaWidth/2 + offset + width, -scanAreaHeight/2),
                                           vec2(scanAreaWidth/2 + offset + width, 0),
                                           vec2(scanAreaWidth/2 + offset, 0)],
                               drawStyle = DrawStyle.solid, fillColor = color, closed = true)
  
  speedGauge.shapes = @[rectangle]
  speedGauge.init()
  addEntity(speedGauge)
  
method update (self: SpeedGauge, dt: float) =
  let speedModifier = max(0, -input.rightStickMoveDir.y)
  
  self.shapes[0].vertices[2].y = -4 + 8 * speedModifier
  self.shapes[0].vertices[3].y = -4 + 8 * speedModifier