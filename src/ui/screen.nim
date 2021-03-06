import ../util/util
import ../globals/globals
import uiobject
import text
import opengl
import math

type
  Screen = ref object of UIObject

let baseScreenHeight* = 10.0

proc newScreen(): Screen =
  Screen(hAlign: HAlign.center, vAlign: VAlign.center, position: vec2(0,0), innerElements: @[], shapes: @[])

#let hudScreen* = newScreen()
#hudScreen.innerElements.add(newTextObject("FPS: ", hudTextStyle, vec2(0.5, -0.5), HAlign.left, VAlign.top))

let writingScreen* = newScreen()
let drawingScreen* = newScreen()
let exploringScreen* = newScreen()

var writingScreenLabel1 = newTextObject("", hudTextStyle, vec2(0, 1.0), HAlign.center, VAlign.center)
var writingScreenLabel2 = newTextObject("", hudTextStyle, vec2(0, 0.5), HAlign.center, VAlign.center)
var writingScreenLabel3 = newTextObject("", hudTextStyle, vec2(0, 0), HAlign.center, VAlign.center)
var writingScreenLabel4 = newTextObject("", hudTextStyle, vec2(0, 0.7), HAlign.center, VAlign.bottom)

var drawingScreenLabel1 = newTextObject("", hudTextStyle, vec2(0, -0.5), HAlign.center, VAlign.top)
var drawingScreenLabel2 = newTextObject("", hudTextStyle, vec2(0, 0.7), HAlign.center, VAlign.bottom)
var drawingScreenLabel3 = newTextObject("", hudTextStyle, vec2(0, 0.2), HAlign.center, VAlign.bottom)

var exploringScreenLabel = newTextObject("", hudTextStyle, vec2(0, 0.7), HAlign.center, VAlign.bottom)
var exploringScreenExitDoorLabel = newTextObject("", hudTextStyle, vec2(0, -1.0), HAlign.center, VAlign.center)

var exploringScreenNormalDoorLabels: array[0..(doorsPerScreen - 1), TextObject]

for i in 0..<doorsPerScreen:
  var scaleFactor = (baseScreenHeight * 0.67) / (float(numTilesY) * float(tileSize)) #not sure where the constant comes from
  exploringScreenNormalDoorLabels[i] = newTextObject("", hudTextStyle, vec2(getDoorX(i) * scaleFactor, -1.0), HAlign.center, VAlign.center)

writingScreen.innerELements.add(writingScreenLabel1)
writingScreen.innerELements.add(writingScreenLabel2)
writingScreen.innerELements.add(writingScreenLabel3)
writingScreen.innerELements.add(writingScreenLabel4)

drawingScreen.innerElements.add(drawingScreenLabel1)
drawingScreen.innerElements.add(drawingScreenLabel2)
drawingScreen.innerElements.add(drawingScreenLabel3)

exploringScreen.innerElements.add(exploringScreenLabel)
exploringScreen.innerElements.add(exploringScreenExitDoorLabel)

for doorLabel in exploringScreenNormalDoorLabels:
  exploringScreen.innerElements.add(doorLabel)

var currentScreen* = writingScreen

method update* (self: Screen, dt: float) =
  case gameState:
    of GameState.textEntry:
      if talkProgress >= 1:
        writingScreenLabel2.setText(currentPoem[currentPoem.high])
        writingScreenLabel3.setText(if timeAfterTalkFinished mod 1.0 > 0.5: poemTextEntered else: " " & poemTextEntered & "_")
      else:
        writingScreenLabel1.setText(if currentPoem.len > 1: currentPoem[currentPoem.high-1] else: "")
        let poemLine = currentPoem[currentPoem.high]
        writingScreenLabel2.setText(poemLine[0..<int(float(poemLine.high) * talkProgress)])
        writingScreenLabel3.setText("")
      if timeAfterTalkFinished > 0.75:
        writingScreenLabel4.setText("Enter the next line of the poem")
      else:
        writingScreenLabel4.setText("")

    of GameState.drawing:
      drawingScreenLabel1.setText(currentPoem[currentPoem.high])
      drawingScreenLabel2.setText("Draw a picture to go with the line")
      drawingScreenLabel3.setText("Arrow: Move    A/D: rotate    S: cycle color    space: place")
    of GameState.exploring:
      if startedTalking:
        exploringScreenLabel.setText(caption)
      else:
        exploringScreenLabel.setText("")
      exploringScreenExitDoorLabel.setText(exitDoorText)
      
      for i in 0..<doorsPerScreen:
        exploringScreenNormalDoorLabels[i].setText(normalDoorTexts[i])



  self.bounds = boundingBox(vec2(-baseScreenHeight * screenAspectRatio / 2, -baseScreenHeight / 2),
                            vec2(baseScreenHeight * screenAspectRatio / 2, baseScreenHeight / 2))
  for element in self.innerElements:
    element.updateLayout(self.bounds)
  procCall UIObject(self).update(dt)

proc render* (self: Screen, zoom: float) =
  glPushMatrix()
  let scale = 1 / (baseScreenHeight / (2 * zoom))
  glScaled(scale, scale, 1)

  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glBegin(GL_TRIANGLES)
  for element in self.innerElements:
    element.renderSolid()
  glEnd()
  glBegin(GL_LINES)
  for element in self.innerElements:
    element.renderLine()
  glEnd()
  glBegin(GL_POINTS)
  for element in self.innerElements:
    element.renderPoint()
  glEnd()
  glPopMatrix()

