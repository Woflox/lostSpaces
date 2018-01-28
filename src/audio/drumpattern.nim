import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  DrumPatternNodeObj = object of AudioNodeObj
    kickBeat : int
    t : float
  DrumPatternNode* = ptr DrumPatternNodeObj

const
  kickBaseFrequency = 120.0
  kickDrop = 0.01
  kickRelease = 0.25
  kickVolume = 0.0
  snareBaseFrequency = 220.0
  snareDrop = 220.0
  snareRelease = 0.125
  snareNoiseMix = 0.5
  snareNoiseFrequency = 600.0
  snareVolume = 2.0
  hiHatHoldTime = 0.0175
  hiHatVolume = -10.0

const frequencies = [329.63, 392.00, 440.00, 493.88, 587.33]
var drumT: float

var kickBeats = @[5, 7, 9, 11]

proc newDrumPatternNode*(): DrumPatternNode =
  result = createShared(DrumPatternNodeObj)
  result[] = DrumPatternNodeObj()
  result.kickBeat = kickBeats.randomChoice()

proc triangle(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc sawTooth(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc sine(t: float, freq: float): float =
  return cos(t * freq * (Pi * 2))

proc square(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  if result > 0.5:
    return 1
  return 0
    
proc getOutput(t: float, freqA: float, freqB: float): float =
  result = sawTooth(t, freqA) + triangle(t, freqA) + sawTooth(t, freqB) + triangle(t, freqB)
  result *= 0.25

proc getDrumOutput(t: float, baseFrequency: float, drop: float, release: float, noiseMix: float, noiseFrequency: float, volume: float, dt: float): float =
  var amplitude = sin(PI * 0.5 * sqrt(t / release))
  drumT += dt * pow(drop / baseFrequency, 1 - amplitude)

  var noiseAmplitude = 0.0
  

  var baseTone = sine(drumT, baseFrequency)
  var noiseValue = fractalNoise(t * noiseFrequency + 1000, 3)
  return dbToAmplitude(volume) * dbToAmplitude((amplitude - 1.0) * 30) * (baseTone + noiseMix * noiseValue)



method updateOutputs*(self: DrumPatternNode, dt: float) =

  var drumValue = 0.0
  var drumming = false

  var hiHatValue = 0.0

  let firstSnareTime = 1.0 * (measureLength / 2.0)
  let secondKickTime = float(self.kickBeat) * (measureLength / 8.0)
  let secondSnareTime = 3.0 * (measureLength / 2.0)
  

  if self.t > secondSnareTime and self.t < secondSnareTime + snareRelease:
    drumValue = getDrumOutput(snareRelease - (self.t - secondSnareTime), snareBaseFrequency, snareDrop, snareRelease, snareNoiseMix, snareNoiseFrequency, snareVolume, dt)
    drumming = true
  elif self.t > secondKickTime and self.t < secondKickTime + kickRelease:
    drumValue =  getDrumOutput(kickRelease - (self.t - secondKickTime), kickBaseFrequency, kickDrop, kickRelease, 0, 1, kickVolume, dt)
    drumming = true
  elif self.t > firstSnareTime and self.t < firstSnareTime + snareRelease:
    drumValue = getDrumOutput(snareRelease - (self.t - firstSnareTime), snareBaseFrequency, snareDrop, snareRelease, snareNoiseMix, snareNoiseFrequency, snareVolume, dt)
    drumming = true
  elif self.t < kickRelease:
    drumValue = getDrumOutput(kickRelease - self.t, kickBaseFrequency, kickDrop, kickRelease, 0, 1, kickVolume, dt)
    drumming = true

  let quarterNoteT = self.t mod (measureLength / 4.0)
  if quarterNoteT < hiHatHoldTime:
    hiHatValue = random(-1.0, 1.0) * dbToAmplitude(hiHatVolume)

  if not drumming:
    drumT = 0

  var value = drumValue + hiHatValue
  self.output[0] = value
  self.output[1] = value

  self.t += dt;
  if self.t > measureLength * 2:
    self.t -= measureLength * 2
    self.kickBeat = kickBeats.randomChoice()
