import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  ChordNodeObj = object of AudioNodeObj
    t: float
    freqA: float
    freqB: float
    fadingIn: bool
    fadeTime: float
    timeFaded: float
    killTimeFaded: float
    lowNote: bool
  ChordNode* = ptr ChordNodeObj

const
  noiseFrequency = 0.5
  noiseOctaves = 3
  lowNoteMultiplier = 0.25

const frequencies = [329.63, 392.00, 440.00, 493.88, 587.33]

proc getFadeTime: float =
  relativeRandom(6, 2)

proc newChordNode*(lowNote = false): ChordNode =
  result = createShared(ChordNodeObj)
  result[] = ChordNodeObj()
  result.fadingIn = true
  result.fadeTime = getFadeTime()
  result.freqA = frequencies[random(0,4)]
  result.freqB = frequencies[random(0,4)]
  result.lowNote = lowNote
  if lowNote:
    result.freqA *= lowNoteMultiplier
  while result.freqB == result.freqA:
    result.freqB = frequencies[random(0,4)]

proc triangle(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc sawTooth(t: float, freq: float): float =
  result = ((t * freq) mod 1.0) * 2.0 - 1.0
  result = abs(result) * 2.0 - 1.0

proc getOutput(t: float, freqA: float, freqB: float): float =
  result = sawTooth(t, freqA) + triangle(t, freqA) + sawTooth(t, freqB) + triangle(t, freqB)
  result *= 0.25

method updateOutputs*(self: ChordNode, dt: float) =
  const chorusAmount = 0.025
  const chorusFrequency = 0.1
  const nf = 300
  let noiseVal1 = (fractalNoise(self.t * chorusFrequency + 1000, noiseOctaves) + 1.0) / 2.0
  let noiseVal2 = noiseVal1#(fractalNoise(self.t * chorusFrequency + 2000.0, noiseOctaves) + 1.0) / 2.0

  if self.t > 2:
    self.timeFaded += dt

  if self.timeFaded > self.fadeTime:
    self.fadeTime = getFadeTime()
    self.fadingIn = not self.fadingIn
    self.timeFaded = 0
    if self.fadingIn:
      self.freqA = frequencies[random(0,4)]
      if self.lowNote:
        self.freqA *= lowNoteMultiplier
      self.freqB = frequencies[random(0,4)]
      while self.freqB == self.freqA:
        self.freqB = frequencies[random(0,4)]

  var volume = self.timeFaded / self.fadeTime
  if not self.fadingIn:
    volume = 1 - volume

  if killMusic:
    self.killTimeFaded += dt
    volume *= (1.0 - self.killTimeFaded / 4.0)
    if self.killTimeFaded >= 4.0:
      self.stopped = true

  self.output[0] = volume * getOutput(self.t + noiseVal1 * chorusAmount, self.freqA, self.freqB)
  self.output[1] = volume * getOutput(self.t + noiseVal2 * chorusAmount, self.freqA, self.freqB,)

  self.t += dt;
