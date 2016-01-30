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
    addEntity(newLineObject(random(0, numTilesX), random(0, numTilesY), random(0, 7), random(0, 1)))

  var mainColor1 = color(uniformRandom(), uniformRandom(), uniformRandom())
  var fullColorIndex = random(0, 2)
  var halfColorIndex = (fullColorIndex + random(0, 1)) mod 3
  mainColor1[fullColorIndex] = 1
  mainColor1[halfColorIndex] = mainColor1[halfColorIndex] * 0.5

  var mainColor2 = color(uniformRandom(), uniformRandom(), uniformRandom())
  halfColorIndex = fullColorIndex
  fullColorIndex = (halfColorIndex + random(0, 10)) mod 3
  mainColor2[fullColorIndex] = 1
  mainColor2[halfColorIndex] = mainColor2[halfColorIndex] * 0.5

  pallette[0] = mainColor1
  pallette[1] = mainColor2
  pallette[2] = randomColor() * 0.0625

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
  let scale = 1 / (numTilesY * tileSize)
  glScaled(scale, scale, 1)

  glEnable (GL_BLEND);
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_TRIANGLES)
  for entity in entities:
    entity.renderSolid()
  glEnd()
  glBegin(GL_LINES)
  for entity in entities:
    entity.renderLine()
  glEnd()
  glPopMatrix()
