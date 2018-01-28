import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  ComputerNoiseNodeObj = object of AudioNodeObj
    t: float
    stepAccumulator: float
    currentMultiplier: float
    baseFrequency: float
    stepSize: float
    stepTime: float
    numSteps: int
    harshMix: float
  ComputerNoiseNode* = ptr ComputerNoiseNodeObj

proc newComputerNoiseNode*(): ComputerNoiseNode =
  result = createShared(ComputerNoiseNodeObj)
  result[] = ComputerNoiseNodeObj()
  result.baseFrequency = random(100.0, 600.0)
  result.stepSize = pow(1.05946, random(1.0, 6.0))
  result.stepTime = random(0.05, 0.1)
  result.numSteps = random(5, 10)
  result.currentMultiplier = 1
  result.harshMix = random(0, 0.5)

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

method updateOutputs*(self: ComputerNoiseNode, dt: float) =
  self.output[0] = getOutput(self.t, self.baseFrequency, self.harshMix)
  self.output[1] = getOutput(self.t, self.baseFrequency, self.harshMix)

  self.stepAccumulator += dt
  if self.stepAccumulator > self.stepTime:
    self.stepAccumulator -= self.stepTime
    self.currentMultiplier = pow(self.stepSize, float(random(0, self.numSteps)))
  self.t += dt * self.currentMultiplier;
