import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  TheraminNoiseNodeObj = object of AudioNodeObj
    t: float
    noiseFrequency: float
    baseFrequency: float
    maxFrequencyMultiplier: float
    harshMix: float
  TheraminNoiseNode* = ptr TheraminNoiseNodeObj

const
  noiseOctaves = 3

proc newTheraminNoiseNode*(): TheraminNoiseNode =
  result = createShared(TheraminNoiseNodeObj)
  result[] = TheraminNoiseNodeObj()
  result.noiseFrequency = random(0.5, 1.5)
  result.baseFrequency = random(300.0, 600.0)
  result.maxFrequencyMultiplier = random(2.0, 4.0)
  result.harshMix = random(0, 0.3)

proc sine(t: float, freq: float): float =
  return sin(t * freq * (Pi * 2))

proc triangle(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc sawTooth(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc square(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  if result > 0.5:
    return 1
  return 0

proc getOutput(t: float, freq: float, harshMix: float): float =
  let sineVal = sine(t, freq)
  let harshVal = 0.25 * (square(t, freq) + sawTooth(t, freq) + triangle(t, freq))
  result = 0.5 * lerp(sineVal, harshVal, harshMix)

method updateOutputs*(self: TheraminNoiseNode, dt: float) =
  let noiseVal = fractalNoise(self.t * self.noiseFrequency + 1000, noiseOctaves)

  self.output[0] = getOutput(self.t, self.baseFrequency, self.harshMix)
  self.output[1] = getOutput(self.t, self.baseFrequency, self.harshMix)

  self.t += dt * pow(self.maxFrequencyMultiplier, noiseVal);
