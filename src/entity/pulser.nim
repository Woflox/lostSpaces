import entity
import math
import ../globals/globals
import ../geometry/shape
import ../util/util
import math
from ../input/input import nil

type
    Pulser* = ref object of Entity
        t: float

const 
  color1 = color(0.06, 0, 0.3)
  color2 = color(0.14, 0.06, 0.35)
  
proc generatePulser* =
  var pulser = Pulser(drawable: true)

  let color = color(0, 0, 0, 1)
  let rectangle = createShape(vertices = @[vec2(-100, -100),
                                           vec2(-100, 100),
                                           vec2(100, 100),
                                           vec2(100, -100)],
                               drawStyle = DrawStyle.solid, fillColor = color, closed = true)
  
  pulser.shapes = @[rectangle]
  pulser.init()
  addEntity(pulser)
  
method update (self: Pulser, dt: float) =
  var d = distance(crosshairPos, specialSignalPos)
  
  let pulsing = 1 - (cos((self.t * PI * 2) / (measureLength / 2)) + 1.0) / 2.0
  let intensity = max(0, 1 - d / specialSignalRadius)

  let color = color(lerp(color1.r, color2.r, pulsing) * intensity,
                    lerp(color1.g, color2.g, pulsing) * intensity,
                    lerp(color1.b, color2.b, pulsing) * intensity,)

  self.shapes[0].fillColor = color

  self.t += dt