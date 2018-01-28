import entity
import math
import ../globals/globals
import ../geometry/shape
import ../util/util
import ../util/random
import ../audio/audio
from ../input/input import nil

type
  Waveform* = ref object of Entity

const width = 20
const height = 2.5
const yOffset = -5.6

proc generateWaveform* =
  var waveform = Waveform(drawable: true)

  let color = color(1, 0.9, 0.6,1)
  var vertices: seq[Vector2]
  newSeq(vertices, rawAudioOutput.len)

  for i in 0..vertices.high:
    vertices[i] = vec2(-width/2 + width * float(i) / float(vertices.high), yOffset)

  let waveshape = createShape(vertices,
                               drawStyle = DrawStyle.line, lineColor = color, closed = false)

  waveform.shapes = @[waveshape]
  waveform.init()
  addEntity(waveform)

method update (self: Waveform, dt: float) =
  for i in 0..self.shapes[0].vertices.high:
    let ringBufferIndex = (rawAudioOutputIndex + 1 + i) mod rawAudioOutput.len
    self.shapes[0].vertices[i].y = yOffset + rawAudioOutput[ringBufferIndex][0] * height / 2