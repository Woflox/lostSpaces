import entity
import math
import ../globals/globals
import ../geometry/shape
import ../util/util
import ../audio/audio
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
  let d = distance(specialSignalPos, crosshairPos)

  let falloff = pow(dbToAmplitude((-30.0) * d / specialSignalRadius), 1 / 2.2)
  
  let pulsing = 1 - (cos((self.t * PI * 2) / (measureLength / 2)) + 1.0) / 2.0

  let color = color(lerp(color1.r, color2.r, pulsing) * falloff,
                    lerp(color1.g, color2.g, pulsing) * falloff,
                    lerp(color1.b, color2.b, pulsing) * falloff,)

  self.shapes[0].fillColor = color

  self.t += dt