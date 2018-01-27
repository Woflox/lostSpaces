import mersenne
import times
import util
import math

var mt = newMersenneTwister(uint32(epochTime()))

proc rand(self: var MersenneTwister): uint32 {.inline.}=
  cast[uint32](self.getNum())

proc newRandom* (seed: int): MersenneTwister =
  newMersenneTwister(uint32(seed))

proc random* (self: var MersenneTwister, minValue, maxValue: int): int =
  result = (abs(int(self.getNum())) mod (maxValue + 1 - minValue)) + minValue

proc random* (self: var MersenneTwister, minValue, maxValue: float): float =
  float(self.rand()) * ((maxValue - minValue) / float(uint32.high)) + minValue

proc uniformRandom* (self: var MersenneTwister): float =
  float(self.rand()) / float(uint32.high)

proc randomChoice* (self: var MersenneTwister, choices: auto): distinct auto =
  choices[self.random(int(choices.low), int(choices.high))]

proc randomChoice* [T](self: var MersenneTwister, choices: varargs[T]): T =
  randomChoice(choices)

proc randomEnumValue* [T](self: var MersenneTwister, kind: T): auto =
  T(random(int(T.low), int(T.high)))

proc randomChance* (self: var MersenneTwister, probability: float): bool =
  return self.uniformRandom() < probability

proc randomDirection* (self: var MersenneTwister): Vector2 =
  directionFromAngle(self.random(0, 2*Pi))

proc randomPointInDisc* (self: var MersenneTwister, radius: float): Vector2 =
  self.randomDirection() * sqrt(self.uniformRandom()) * radius

proc expRandom* (self: var MersenneTwister, frequency: float) : float =
  -ln(self.uniformRandom()) / frequency

proc relativeRandom* (self: var MersenneTwister, median: float, maxMultiplier: float) : float =
  median * (pow(maxMultiplier, self.random(-1.0, 1.0)))

proc randomColor* (self: var MersenneTwister): Color =
  result = color(self.uniformRandom(), self.uniformRandom(), self.uniformRandom())
  let fullColorIndex = self.random(0, 2)
  let halfColorIndex = (fullColorIndex + self.random(1, 2)) mod 3
  result[fullColorIndex] = 1
  result[halfColorIndex] = result[halfColorIndex] * 0.5

proc seed* (seed: int) =
  mt = newMersenneTwister(uint32(seed))

proc random* (minValue, maxValue: int): int =
  mt.random(minValue, maxValue)

proc random* (minValue, maxValue: float): float =
  mt.random(minValue, maxValue)

proc uniformRandom* : float =
  mt.uniformRandom()

proc randomChoice* (choices: auto): distinct auto =
  mt.randomChoice(choices)

proc randomChoice* [T](choices: varargs[T]): T =
  mt.randomChoice(choices)

proc randomEnumValue* [T](kind: T): auto =
  mt.randomEnumValue(T)

proc randomChance* (probability: float): bool =
  mt.randomChance(probability)

proc randomDirection* : Vector2 =
  mt.randomDirection()

proc randomPointInDisc* (radius: float) : Vector2 =
  mt.randomPointInDisc(radius)

proc expRandom* (frequency: float) : float =
  mt.expRandom(frequency)

proc relativeRandom* (median: float, maxMultiplier: float) : float =
  mt.relativeRandom(median, maxMultiplier)

proc randomColor* () : Color =
  mt.randomColor()
