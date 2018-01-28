import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  BackgroundNoiseNodeObj = object of AudioNodeObj
    t1: float
    t2: float
    perlinSeed: float
  BackgroundNoiseNode* = ptr BackgroundNoiseNodeObj

const
  lowNoiseFrequency = 500
  timeVariance = 0.33f
  highNoiseFrequency = 1000
  positionalNoiseFrequency = 0.3
  noiseOctaves = 3


proc newBackgroundNoiseNode*(): BackgroundNoiseNode =
  result = createShared(BackgroundNoiseNodeObj)
  result[] = BackgroundNoiseNodeObj()
  result.perlinSeed = random(0.0, 1000.0)

method updateOutputs*(self: BackgroundNoiseNode, dt: float) =
  let noiseVal1 = fractalNoise(self.t1 * highNoiseFrequency + 1000.0 + self.perlinSeed, noiseOctaves)
  let noiseVal2 = fractalNoise(self.t2 * lowNoiseFrequency + 1000.0 + self.perlinSeed, noiseOctaves)
  let noise1Intensity = 0.5 * (fractalNoise(crosshairPos.x * positionalNoiseFrequency + 1000 + self.perlinSeed,
                                      crosshairPos.y * positionalNoiseFrequency + 1000 + self.perlinSeed,
                                      noiseOctaves) + 1.1) / 2.1
  let noise2Intensity = (fractalNoise(crosshairPos.x * positionalNoiseFrequency + 2000 + self.perlinSeed,
                                      crosshairPos.y * positionalNoiseFrequency + 2000 + self.perlinSeed, 
                                      noiseOctaves) + 1.1) / 2.1

  let outputValue = noiseVal1 * noise1Intensity + noiseVal2 * noise2Intensity
  self.output[0] = outputValue
  self.output[1] = outputValue

  self.t1 += dt * (1 + timeVariance *  fractalNoise(crosshairPos.x * positionalNoiseFrequency + 3000,
  crosshairPos.y * positionalNoiseFrequency + 3000,
  noiseOctaves));
  
  self.t2 += dt * (1 + timeVariance *  fractalNoise(crosshairPos.x * positionalNoiseFrequency + 4000,
  crosshairPos.y * positionalNoiseFrequency + 4000,
  noiseOctaves));


