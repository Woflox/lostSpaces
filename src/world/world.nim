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

var numSignals = 0

type
  Signal* {.pure.} = enum
    theramin, computer, chain, gibberish, special

let signals = @[Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin, Signal.theramin,
                  Signal.computer,
                  Signal.gibberish, Signal.gibberish, Signal.gibberish, Signal.gibberish, Signal.gibberish, Signal.gibberish, Signal.gibberish,
                  Signal.chain, Signal.computer,
                  Signal.chain, Signal.computer,
                  Signal.chain, Signal.chain, Signal.computer,
                  Signal.chain, Signal.gibberish,
                  Signal.chain, Signal.chain, Signal.chain, Signal.special]

echo signals.len

proc randomCoord: Vector2 =
  return vec2((uniformRandom() - 0.5) * scanAreaWidth, 
              (uniformRandom() - 0.5) * scanAreaHeight)

var signalNodes : seq[SignalAttenuatorNode]
signalNodes = @[]

proc generateSignal(coord : Vector2, topLevel: bool) =
  generateStar(coord, topLevel)

  var signalNode: AudioNode
  let nextCoord = randomCoord()

  var signal = signals[numSignals]

  case signal:
    of Signal.theramin:  
      signalNode = newTheraminNoiseNode()
    of Signal.computer:  
      signalNode = newComputerNoiseNode()
    of Signal.chain:
      signalNode = newWeirdVoiceNode(convertToSpeakableText(nextCoord))
    of Signal.gibberish:  
      signalNode = newWeirdVoiceNode(getMarkovString(120))
    of Signal.special:  
      signalNode = newSongNode()
      specialSignalPos = coord
  
  var signalStrength =  random(-6.0, -1.0)
  var signalRadius = relativeRandom(1.5, 2)
  if not topLevel: 
    signalStrength = random(-3.0, -1.0)
    signalRadius =  relativeRandom(0.125, 2)
  if signal == Signal.special:
    signalStrength = -1.0
    signalRadius = specialSignalRadius

  var signalAttenuatorNode = newSignalAttenuatorNode(coord, signalStrength, signalRadius)
  signalAttenuatorNode.addInput(signalNode)
  signalNodes.add(signalAttenuatorNode)

  numSignals += 1

  if signal == Signal.chain:
    generateSignal(nextCoord, false)
  
proc generate* () =
  clearEntities()
  var camera = newCamera(vec2(0,0))
  generateCrosshair()
  generateSpeedGauge()
  generateWaveform()
  calculateMarkovTable()
  for i in 0..2000:
    generateStar(randomCoord(), false)

  
  while numSignals < signals.len:
    generateSignal(randomCoord(), true)
    
  generatePulser()

  echo numSignals
  playSound(newBackgroundNoiseNode(), -14, 0)
  for signalNode in signalNodes:
    playSound(signalNode, -1.0, 0.0)

proc update* (dt: float) =
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
