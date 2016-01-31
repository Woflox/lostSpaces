import entity
import ../globals/globals
import ../geometry/shape
import ../util/util
import ../util/random
import math

type
  Rock* = ref object of Entity

const numRocks = 60

const corners = [vec2(-0.5, -0.5), vec2(-0.5, 0), vec2(0, -0.5), vec2(0, 0)]

proc generateBackground* () =
  for i in 0..<numRocks:
    var rock = Rock(drawable: true)

    #let ignoreCorner = random(0, 3)
    #let x = random(0, numTilesX * 4)
    #let y = random(0, numTilesY * 2)

    #var vertices: seq[Vector2] = @[]
    #for i in 0..3:
    #  if i != ignoreCorner:
    #    var vertex = corners[i]

    #let shape = createShape(vertices = @[vec2(-1000,floorY),vec2(1000,floorY),
    #                                          vec2(-1000,-1000),vec2(1000,-1000)],
    #                             drawStyle = DrawStyle.solid, fillColor = color(0, 0, 0))

    let shape = createIsoTriangle(width = expRandom(1.0 / 5.0),
                                  height = expRandom(1.0 / 5.0),
                                  drawStyle = DrawStyle.solid,
                                  fillColor = color(1,1,1,1),
                                  position = vec2(random(float(-numTilesX)*tileSize,
                                                         float(numTilesX)*tileSize),
                                                  random(float(-numTilesY)*0.5*tileSize,
                                                         float(numTilesY)*0.5*tileSize)))

    rock.shapes = @[shape]
    rock.init(rotation = matrixFromAngle(random(0.0, 2*Pi)))
    addEntity(rock)
