import audio
import flite
import flite/rms
import math
import common
import threadpool
import ../util/util
import ../util/random
import ../ui/screen
import ../util/noise

type
  VoiceNodeObj = object of AudioNodeObj
    t: float
    unloopedT: float
    wave: Wave
    looping: bool
    speed: float
    maxSpeedMultiplier: float
    speedNoiseFrequency: float
  VoiceNode* = ptr VoiceNodeObj

let fliteSuccess = fliteInit()
let voice = registerCmuUsRms(nil)

const volumeBoost = 2.5
const saturation = -0.5
const numBits = 4
const downSample = 8
const bitcrushedSaturation = 1.0
const bitcrushMix = 0.15

proc newVoiceNode* (text: string, looping = false, speed = 1.0, maxSpeedMultiplier = 0.0, speedNoiseFrequency = 1.0): VoiceNode =
  result = createShared(VoiceNodeObj)
  result[] = VoiceNodeObj()
  result.looping = looping
  result.speed = speed
  result.maxSpeedMultiplier = maxSpeedMultiplier
  result.speedNoiseFrequency = speedNoiseFrequency
  result.wave = fliteTextToWave(text, voice)

method destruct*(self: VoiceNode) =
  self.wave.delete()

const loopPauseTime = 1.0

method updateOutputs*(self: VoiceNode, dt: float) =
  self.output = [0.0, 0.0]
  if self.wave == nil:
    self.stop()
    return
  
  if self.t < 0.0:
    self.t += dt;
    self.output[0] = 0
    self.output[1] = 0
    return;

  var index = int(self.t * self.speed * float(self.wave.sampleRate))
  let downSampledIndex = int(index / downSample) * downSample
  if index >= self.wave.numSamples:
    if self.looping:
      self.t = -loopPauseTime
      index = int(self.t * self.speed * float(self.wave.sampleRate))
      return
    else:
      self.stop()
      return

  var sample = float(self.wave[index]) / float(int16.high)
  var bitcrushedSample = float(self.wave[downSampledIndex]) / float(int16.high)
  bitcrushedSample = bitcrush(bitcrushedSample, numBits)
  bitcrushedSample = saturate(bitcrushedSample, bitcrushedSaturation)
  sample = saturate(sample, saturation)
  var output = lerp(sample, bitcrushedSample, bitcrushMix)

  output *= volumeBoost

  self.output[0] = output
  self.output[1] = output
  
  let noiseVal = fractalNoise(self.unloopedT * self.speedNoiseFrequency + 1000, 3)

  self.unloopedT += dt * pow(self.maxSpeedMultiplier, noiseVal);
  self.t += dt * pow(self.maxSpeedMultiplier, noiseVal);

proc createAndPlayVoiceNode(text: string) =
  let node = newVoiceNode(text)
  playSound(node, -1.0, 0.0)

proc say*(text: string) =
  spawn createAndPlayVoiceNode(text)

proc newWeirdVoiceNode* (text: string): VoiceNode =
  return newVoiceNode(text, true, random(0.75, 1.5), random(1.0, 1.5), random(0.5, 1.5))