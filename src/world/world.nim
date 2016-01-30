import opengl
import ../entity/entity
import ../entity/camera
import ../util/util
import ../util/random
import ../geometry/shape
import ../audio/audio
import ../audio/ambient
import ../ui/text
import ../ui/uiobject
import ../entity/tileObject
import ../globals/globals
from ../input/input import nil
from ../entity/camera import nil
import math

proc generate* () =
  clearEntities()
  var camera = newCamera(vec2(0,0))
  for i in 0..10:
    addEntity(newLineObject(random(0, numTilesX), random(0, numTilesY), random(0, 7), random(0, 2)))
  for i in 0..pallette.high:
    pallette[i] = randomColor()

playSound(newAmbientNode(), -4.0, 0.0)

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
  mainCamera.applyTransform()
  glEnable (GL_BLEND);
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_TRIANGLES)
  for entity in entities:
    entity.onScreen = mainCamera.isOnScreen(entity.boundingBox)
    entity.renderSolid()
  glEnd()
  glBegin(GL_LINES)
  for entity in entities:
    entity.renderLine()
  glEnd()
  glPopMatrix()
