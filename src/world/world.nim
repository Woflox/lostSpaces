import opengl
import ../entity/entity
import ../entity/camera
import ../util/util
import ../util/random
import ../geometry/shape
import ../audio/audio
import ../audio/voice
import ../audio/signalAttenuator
import ../audio/prose
import ../audio/ambient
import ../audio/backgroundnoise
import ../audio/computernoise
import ../audio/theraminnoise
import ../audio/markovtext
import ../audio/song
import ../ui/text
import ../ui/uiobject
import ../ui/screen
import ../globals/globals
import ../entity/star
import ../entity/crosshair
import ../entity/speedgauge
import ../entity/waveform
import ../entity/pulser
from ../input/input import nil
from ../entity/camera import nil
import math
import strutils
import os

const maxSignals = 30
var numSignals = 0
var madeSpecialSignal = false

const topLevelWeights = @[0.5, #theramin
                        0.1, #computer
                        0.19, #chain
                        0.21 #weird voice
                        ]

const chainWeights = @[0.0, #theramin
                     0.3, #computer
                     0.55, #chain
                     0.15 #weird voice
                    ]

proc randomCoord: Vector2 =
  return vec2((uniformRandom() - 0.5) * scanAreaWidth, 
              (uniformRandom() - 0.5) * scanAreaHeight)

var signalNodes : seq[SignalAttenuatorNode]
signalNodes = @[]

var generated = false
var firstUpdate = true

proc generateSignal(coord : Vector2, topLevel: bool, forceChain = false) =
  numSignals += 1
  if numSignals > maxSignals and madeSpecialSignal:
    return

  generateStar(coord, topLevel)

  let weights = if topLevel: topLevelWeights else: chainWeights

  let u = uniformRandom()
  var weightAccumulator = 0.0
  var selectedSignal = 0
  for i in 0..weights.high:
    selectedSignal = i
    weightAccumulator += weights[i]
    if weightAccumulator >= u:
      break
  var signalNode: AudioNode
  var chain = false
  var special = false
  let nextCoord = randomCoord()

  if forceChain:
    chain = true
    signalNode = newWeirdVoiceNode(convertToSpeakableText(nextCoord))
  elif (not topLevel) and ((selectedSignal != 2)) and (not madeSpecialSignal):
    special = true
    madeSpecialSignal = true
    signalNode = newSongNode()
    specialSignalPos = coord
  else:
    case selectedSignal:
      of 0:
        signalNode = newTheraminNoiseNode()
      of 1:
        signalNode = newComputerNoiseNode()
      of 2:
        chain = true
        signalNode = newWeirdVoiceNode(convertToSpeakableText(nextCoord))
      of 3:
        signalNode = newWeirdVoiceNode(getMarkovString(120))
      else:
        return
  
  var signalStrength =  random(-6.0, -1.0)
  var signalRadius = relativeRandom(1.5, 2)
  if not topLevel: 
    signalStrength = random(-3.0, -1.0)
    signalRadius =  relativeRandom(0.125, 2)
  if special:
    signalStrength = -1.0
    signalRadius = specialSignalRadius

  var signalAttenuatorNode = newSignalAttenuatorNode(coord, signalStrength, signalRadius)
  signalAttenuatorNode.addInput(signalNode)
  signalNodes.add(signalAttenuatorNode)

  if chain:
    generateSignal(nextCoord, false)
  
proc init* () =
  var camera = newCamera(vec2(0,0))

proc generate* () =
  clearEntities()
  generateCrosshair()
  generateSpeedGauge()
  generateWaveform()
  calculateMarkovTable()
  for i in 0..(2000-maxSignals):
    generateStar(randomCoord(), false)

  
  while numSignals < maxSignals or (not madeSpecialSignal):
    generateSignal(randomCoord(), true, numSignals >= maxSignals)
    
  generatePulser()

  echo numSignals
  playSound(newBackgroundNoiseNode(), -14, 0)
  for signalNode in signalNodes:
    playSound(signalNode, -1.0, 0.0)

  currentScreen = mainScreen

  generated = true

proc update* (dt: float) =
  if not generated:
    if firstUpdate:
      firstUpdate = false
      return
    generate()

  var i = 0
  while i <= entities.high:
    entities[i].update(dt)
    inc i
  for entityList in entitiesByTag:
    i = 0
    while i <= entityList.high:
      entityList[i].checkForCollisions(i, dt)
      inc i
  i = 0
  while i <= entities.high:
    if entities[i].destroyed:
      removeEntity(i)
    else:
      inc i

  mainCamera.update(dt)

proc render* () =
  if not generated:
    return
  glPushMatrix()
  let scale = 1.0 / 7.5
  glScaled(scale, scale, 1)
  glTranslated(0, 1.25, 0)

  glEnable (GL_BLEND);
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_POINTS)
  for entity in entitiesOfType[Star]():
    entity.renderLine()
  glEnd()
  glBegin(GL_LINES)
  entityOfType[Crosshair]().renderLine();
  entityOfType[Waveform]().renderLine();
  glEnd()
  glBegin(GL_TRIANGLES)
  entityOfType[SpeedGauge]().renderSolid();
  glEnd()
  glBlendFunc (GL_ONE, GL_ONE);
  glBegin(GL_TRIANGLES)
  entityOfType[Pulser]().renderSolid();
  glEnd()
  glBegin(GL_TRIANGLES)
  for entity in entitiesOfType[NormalDrawEntity]():
    entity.renderSolid()
  glEnd()
  glPopMatrix()
