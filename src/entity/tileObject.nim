import ../util/util
import ../util/noise
import ../globals/globals
import opengl
import entity
import math

type
  TileObject = ref object of RootObj
    x, y: int
  DrawnLineObject = ref object of TileObject
    lineRotation: int
    lineColor: int
