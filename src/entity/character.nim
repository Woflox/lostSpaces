import entity
import ../globals/globals
import ../geometry/shape
import ../util/util
import ../util/random
from ../input/input import nil
import math

type
  Character* = ref object of NormalDrawEntity

const
  scale = 1.25
  headLength = 1.0*scale
  torsoLength = 2.25*scale
  armLegRatio = 0.75
  legLength = 5.0*scale
  neckLength = 0.5*scale
  kneeBend = 0.5*scale
  armMoveRatio = 0.75
  limbMoveScale = 1.8
  shoulderRatio = 0.25
  limbMoveFrequency = 0.5
  moveSpeed = 30.0
  floorLineSize = 2.5
  floorLineIntensity = 0.125
  boilDistance = 0.25
  color = color(1,1,1,1)
  headIndex = 0
  torsoIndex = 1
  leftArmIndex = 2
  rightArmIndex = 3
  leftLegIndex = 4
  rightLegIndex = 5
  floorLineIndex = 6

proc generateCharacter* (x: float) =
  var character = Character(drawable: true)

  let head = createShape(vertices = @[vec2(0,0), vec2(0,0),vec2(-headLength,headLength),vec2(0,0),
                                      vec2(headLength,headLength),vec2(0,0)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let torso = createShape(vertices = @[vec2(0,0),vec2(0,torsoLength)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let leftArm = createShape(vertices = @[vec2(0,0),  vec2(0,0), vec2(0,0)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let rightArm = createShape(vertices = @[vec2(0,0),  vec2(0,0), vec2(0,0)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let leftLeg = createShape(vertices = @[vec2(0,0), vec2(0,0), vec2(0,0)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let rightLeg = createShape(vertices = @[vec2(0,0), vec2(0,0), vec2(0,0)],
                         drawStyle = DrawStyle.line, lineColor = color)
  let floorLineShape = createShape(vertices = @[vec2(0,0),vec2(0,0)],
                                drawStyle = DrawStyle.line, lineColor = color * floorLineIntensity)

  character.shapes = @[head, torso, leftArm, rightArm, leftLeg, rightLeg, floorLineShape]
  character.init()
  character.position = vec2(x, floorY)
  addEntity(character)

method update (self: Character, dt: float) =
  let moveDir = input.moveDir()
  self.position.x = clamp(self.position.x + moveDir.x * moveSpeed * dt, -screenEdge, screenEdge)

  #legs
  var origin = self.position
  var leftLegX = origin.x + sin(origin.x * limbMoveFrequency) *limbMoveScale
  var rightLegX = origin.x - sin(origin.x * limbMoveFrequency) * limbMoveScale
  self.shapes[leftLegIndex].vertices[0] = vec2(leftLegX, origin.y)
  self.shapes[rightLegIndex].vertices[0] = vec2(rightLegX, origin.y)
  self.shapes[leftLegIndex].vertices[2] = origin + vec2(0, legLength + cos(origin.x * 2* limbMoveFrequency)*0.125 * limbMoveScale)
  self.shapes[rightLegIndex].vertices[2] = self.shapes[leftLegIndex].vertices[2]
  self.shapes[leftLegIndex].vertices[1] = (self.shapes[leftLegIndex].vertices[0] + self.shapes[leftLegIndex].vertices[2]) * 0.5 + vec2(kneeBend, 0)
  self.shapes[rightLegIndex].vertices[1] = (self.shapes[rightLegIndex].vertices[0] + self.shapes[rightLegIndex].vertices[2]) * 0.5 + vec2(kneeBend, 0)

  #torso
  origin = self.shapes[leftLegIndex].vertices[2]
  self.shapes[torsoIndex].vertices[0] = origin
  self.shapes[torsoIndex].vertices[1] = origin + vec2(0, torsoLength)

  #arms
  origin = self.shapes[torsoIndex].vertices[1]
  self.shapes[leftArmIndex].vertices[0] = origin
  self.shapes[leftArmIndex].vertices[1] = origin + vec2(sin(origin.x * limbMoveFrequency) *limbMoveScale * armMoveRatio * shoulderRatio, 0)
  self.shapes[leftArmIndex].vertices[2] = origin + vec2(sin(origin.x * limbMoveFrequency) *limbMoveScale * armMoveRatio, -legLength * armLegRatio - cos(origin.x * 2* limbMoveFrequency)*0.125 * limbMoveScale * armMoveRatio)
  self.shapes[rightArmIndex].vertices[0] = origin
  self.shapes[rightArmIndex].vertices[1] = origin + vec2(-sin(origin.x * limbMoveFrequency) *limbMoveScale * armMoveRatio * shoulderRatio, 0)
  self.shapes[rightArmIndex].vertices[2] = origin + vec2(-sin(origin.x * limbMoveFrequency) *limbMoveScale * armMoveRatio, -legLength * armLegRatio - cos(origin.x * 2* limbMoveFrequency)*0.125 * limbMoveScale * armMoveRatio)

  #head
  self.shapes[headIndex].vertices[0] = origin
  self.shapes[headIndex].vertices[1] = origin + vec2(0, neckLength)
  self.shapes[headIndex].vertices[2] = origin + vec2(-headLength*0.5, headLength*0.66 + neckLength)
  self.shapes[headIndex].vertices[3] = origin + vec2(0, headLength + neckLength)
  self.shapes[headIndex].vertices[4] = origin + vec2(headLength*0.5, headLength*0.66 + neckLength)
  self.shapes[headIndex].vertices[5] = origin + vec2(0, neckLength)

  #floorline
  origin = self.position
  self.shapes[floorLineIndex].vertices[0] = origin + vec2(-floorLineSize, 0)
  self.shapes[floorLineIndex].vertices[1] = origin + vec2(floorLineSize, 0)

  for i in 0..<self.shapes.high:
    for j in 0..self.shapes[i].vertices.high:
      self.shapes[i].vertices[j] = self.shapes[i].vertices[j] + randomPointInDisc(boilDistance)




