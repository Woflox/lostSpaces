import ../util/util
import ../util/noise
import ../globals/globals
import opengl
import entity
import math

type
  Camera = ref object
    target*: Entity
    lastTargetPos: Vector2
    smoothedTargetPos: Vector2
    smoothPos: Vector2
    smoothTargetRotation: float
    smoothRotation: float
    shakeBoost: float
    zoom*: float
    zoomInThreshold*: float
    zoomOutThreshold*: float
    t: float
    rotation: float
    rotationMatrix: Matrix2x2
    position: Vector2
    velocity*: Vector2
    bounds: BoundingBox
    postZoomThreshold: float
    blur: float

const
  smoothing = 0.25
  velocityOffsetCoefficient = 0.75
  rotationSpeed = 1.5
  rotationSmoothing = 0.25
  positionShake = 0.2
  rotationShake = 0.005
  noiseFrequency = 0.5
  noiseOctaves = 3
  speedShakeBoost = 0.25
  rotationSpeedShakeBoost = 6
  zoomSpeed = 0.55
  zoomHysteresis = 1.25
  zoomPadding = 3
  minBoundsMinY = -10.5
  minBoundsMaxY = 22.5
  maxBoundsMinY = -19.5
  maxBoundsMaxY = 24.5
  blurRate = 0.012
  unblurRate = 0.024
  maxBlur = 0.01

var mainCamera*: Camera

proc newCamera* (pos: Vector2): Camera =
  result = Camera(position: pos, smoothedTargetPos: pos, lastTargetPos: pos, zoom: minBoundsMaxY - minBoundsMinY)
  mainCamera = result

proc shake* (self: Camera, shakeAmount: float) =
  self.shakeBoost = max(self.shakeBoost, shakeAmount)

proc update* (self: Camera, dt: float) =
  self.rotationMatrix = matrixFromAngle(-self.rotation)

proc getBounds* (self: Camera): BoundingBox {.inline.} = self.bounds

proc applyTransform* (self: Camera) =
  var scale = 2 / self.zoom
  if self.zoom < self.postZoomThreshold:
    scale = 2 / self.postZoomThreshold
  glScaled(scale, scale, 1)
  glRotated(radToDeg(-self.rotation), 0, 0, -1)
  glTranslated(-self.position.x, -self.position.y, 0)

proc worldToViewSpace* (self: Camera, point: Vector2): Vector2 =
  self.rotationMatrix * (point - self.position)

proc isOnScreen* (self: Camera, point: Vector2): bool =
  self.bounds.contains(self.worldToViewSpace(point))

proc isOnScreen* (self: Camera, box: BoundingBox): bool =
  var screenSpaceBox = minimalBoundingBox()
  screenSpaceBox.expandTo(self.worldToViewSpace(box.minPos))
  screenSpaceBox.expandTo(self.worldToViewSpace(box.maxPos))
  screenSpaceBox.expandTo(self.worldToViewSpace(vec2(box.minPos.x, box.maxPos.y)))
  screenSpaceBox.expandTo(self.worldToViewSpace(vec2(box.maxPos.x, box.minPos.y)))
  result = self.bounds.overlaps(screenSpaceBox)

proc getPostZoom* (self: Camera): float =
  if self.zoom > self.postZoomThreshold:
    return 1
  else:
    return self.zoom / self.postZoomThreshold

proc setPostZoomThreshold* (self: Camera, value: float) =
  if value > 1:
    self.postZoomThreshold = maxBoundsMaxY - maxBoundsMinY
  else:
    self.postZoomThreshold = (maxBoundsMaxY - maxBoundsMinY) * value

proc getBlur* (self: Camera): float =
  abs(self.blur) / (self.zoom / (maxBoundsMaxY - maxBoundsMinY))
