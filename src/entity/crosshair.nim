import entity
import math
import ../globals/globals
import ../geometry/shape
import ../util/util
from ../input/input import nil

type
  Crosshair* = ref object of Entity

const minSpeed = 0.04
const maxSpeed = 4.0

proc generateCrosshair* =
  var crosshair = Crosshair(drawable: true)

  let color = color(0.5,0.33,0.1,1)
  let horizontal = createShape(vertices = @[vec2(-scanAreaWidth/2, 0), vec2(scanAreaWidth/2, 0)],
                               drawStyle = DrawStyle.line, lineColor = color)
  let vertical = createShape(vertices = @[vec2(0, -scanAreaHeight/2), vec2(0, scanAreaHeight/2)],
                               drawStyle = DrawStyle.line, lineColor = color)

  crosshair.shapes = @[horizontal, vertical]
  crosshair.init()
  addEntity(crosshair)

method update (self: Crosshair, dt: float) =
  let moveDirection = input.leftStickMoveDir
  let speedModifier = max(0, -input.rightStickMoveDir.y)

  let moveSpeed = moveDirection * minSpeed * pow(maxSpeed / minSpeed, speedModifier)
  crosshairPos.x = clamp(crosshairPos.x + moveSpeed.x * dt, -scanAreaWidth/2, scanAreaWidth/2)
  crosshairPos.y = clamp(crosshairPos.y + moveSpeed.y * dt, -scanAreaHeight/2, scanAreaHeight/2)

  self.shapes[0].vertices[0].y = crosshairPos.y
  self.shapes[0].vertices[1].y = crosshairPos.y
  self.shapes[1].vertices[0].x = crosshairPos.x
  self.shapes[1].vertices[1].x = crosshairPos.x