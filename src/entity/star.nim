import entity
import ../globals/globals
import ../geometry/shape
import ../util/util
import ../util/random
import math

type
  Star* = ref object of Entity
    brightness : float
    warmth : float

const minBrightness = 0.01
const maxBrightness = 0.7

proc generateStar* (pos: Vector2, special: bool) =
  var star = Star(drawable: true)
  star.brightness = minBrightness * pow(maxBrightness / minBrightness, uniformRandom())
  star.warmth = uniformRandom()
  if special:
    star.brightness = 1
    star.warmth = 1
  #star.position = pos

  let color = color( star.brightness * star.warmth * 0.25, 
                    star.brightness * star.warmth, star.brightness,1)
  let dot = createShape(vertices = @[pos], drawStyle = DrawStyle.point, lineColor = color)

  star.shapes = @[dot]
  star.init();
  addEntity(star)

