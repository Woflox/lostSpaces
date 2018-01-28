import ../util/util
import ../globals/globals
import uiobject
import text
import opengl
import math

type
  Screen = ref object of UIObject

let baseScreenHeight* = 16.0f / 9.0f

proc newScreen(): Screen =
  Screen(hAlign: HAlign.center, vAlign: VAlign.center, position: vec2(0,0), innerElements: @[], shapes: @[])

#let hudScreen* = newScreen()
#hudScreen.innerElements.add(newTextObject("FPS: ", hudTextStyle, vec2(0.5, -0.5), HAlign.left, VAlign.top))

let mainScreen* = newScreen()

var xCoordLabel = newTextObject("0000", hudTextStyle, vec2(-0.25, -0.4), HAlign.center, VAlign.center)
var yCoordLabel = newTextObject("0000", hudTextStyle, vec2(0.25, -0.4), HAlign.center, VAlign.center)

mainScreen.innerELements.add(xCoordLabel)
mainScreen.innerELements.add(yCoordLabel)

var currentScreen* = mainScreen

method update* (self: Screen, dt: float) =
  xCoordLabel.setText(convertToText(crosshairPos.x, true)) 
  yCoordLabel.setText(convertToText(crosshairPos.y, false))

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

