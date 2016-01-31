import opengl
import ../entity/entity
import ../entity/camera
import ../util/util
import ../util/random
import ../geometry/shape
import ../audio/audio
import ../audio/voice
import ../audio/prose
import ../audio/ambient
import ../ui/text
import ../ui/uiobject
import ../ui/screen
import ../entity/tileObject
import ../globals/globals
import ../entity/floor
import ../entity/background
import ../entity/character
from ../input/input import nil
from ../entity/camera import nil
import math
import strutils
import os

var lineGroup = newLineGroup(@[])

type
  LevelScreen = ref object
    poemLine: string
    tiles: seq[LineObject]
  Level = ref object
    number: int
    screens: seq[LevelScreen]

var levels: seq[Level]
levels = @[]

var currentLevel: Level
var currentLevelScreen = 0

proc setPallette(levelNum: int) =
  seed(levelNum * 1000)

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


proc newLevelScreen(): LevelScreen =
  LevelScreen(poemLine: "", tiles: @[])

proc generateLevel* (number: int): Level =
  result = Level(number: number, screens: @[])
  seed(number * 1000)

  for i in 0..numLevelScreens-1:
    if i mod 2 == 0:
      if number > 0:
        result.screens.add(levels[random(0, number-1)].screens[i+1])
      else:
        var screen = newLevelScreen()
        for i in 0..<16:
          let obj = newLineObject(random(0, numTilesX), random(0, numTilesY), random(0, 7), random(0, 1))
          screen.tiles.add(obj)
        screen.poemLine = getProse()
        result.screens.add(screen)
    else:
      result.screens.add(newLevelScreen())

proc serialize(self: Level) =
  var file = open($(self.number) & ".lvl", fmWrite)
  for screen in self.screens:
    file.writeln(screen.poemLine)
    for tile in screen.tiles:
      file.writeln(tile.x)
      file.writeln(tile.y)
      file.writeln(tile.tileRotation)
      file.writeln(tile.palletteIndex)

proc unserializeLevel(number: int): Level =
  result = Level(number: number, screens: @[])

  var file = open($(number) & ".lvl")

  for i in 0..<8:
    var screen = newLevelScreen()
    screen.poemLine = file.readline()
    for j in 0..<16:
      var lineObject = newLineObject()
      lineObject.x = file.readline().parseInt()
      lineObject.y = file.readline().parseInt()
      lineObject.tileRotation = file.readline().parseInt()
      lineObject.palletteIndex = file.readline().parseInt()
      screen.tiles.add(lineObject)
    result.screens.add(screen)


proc setGameState(st: GameState) =
  gameState = st
  stateTime = 0
  case gameState:
    of GameState.textEntry:
      currentScreen = writingScreen
    of GameState.drawing:
      currentScreen = drawingScreen
    of GameState.exploring:
      currentScreen = exploringScreen

proc startTextEntry* =
  setGameState(GameState.textEntry)
  let previousLine = currentLevel.screens[currentLevelScreen].poemLine
  currentPoem.add(previousLine)
  #say(previousLine)
  startedTalking = false
  talkProgress = 0
  timeAfterTalkFinished = 0
  poemTextEntered = ""
  inc currentLevelScreen
  clearEntities()
  generateFloor()
  generateBackground()

proc startNewLineGroup* =
  lineGroup = newLineGroup(@[])
  let screen = currentLevel.screens[currentLevelScreen]
  if screen.tiles.len mod 8 == 0:
    if currentLevel.number > 0:
      let randomLevel = levels[random(0, currentLevel.number-1)]
      for i in 0..<4:
        let lineObj = randomLevel.screens[currentLevelScreen].tiles[screen.tiles.high + i + 4]
        lineGroup.tiles.add(newLineObject(lineObj.x, lineObj.y, lineObj.tileRotation, lineObj.palletteIndex))
    else:
      for i in 0..3:
        let obj = newLineObject(random(0, numTilesX), random(0, numTilesY), random(0, 7), random(0, 1))
        lineGroup.tiles.add(obj)
  else:
    let obj = newLineObject(random(0, numTilesX), random(0, numTilesY), random(0, 7), random(0, 1))
    lineGroup.tiles.add(obj)
  for tile in lineGroup.tiles:
    screen.tiles.add(tile)
    addEntity(tile)

proc startDrawing* =
  setGameState(GameState.drawing)
  startNewLineGroup()

proc startBuildLevel* (number: int) =
  currentLevel = generateLevel(number)
  setPallette(number)
  levels.add(currentLevel)
  currentPoem = @[]
  startTextEntry()

proc loadScreen* (screenNumber: int) =
  currentLevelScreen = screenNumber
  clearEntities()
  generateFloor()
  generateBackground()
  generateCharacter()

  if screenNumber >= 0 and screenNumber < 8:
    for tile in currentLevel.screens[currentLevelScreen].tiles:
      addEntity(tile)
    caption = currentLevel.screens[currentLevelScreen].poemLine
    say(caption)
  else:
    caption = ""


proc startExplore* (number: int) =
  setGameState(GameState.exploring)
  currentLevel = levels[number]
  setPallette(number)
  loadScreen(0)

proc generate* () =
  clearEntities()
  var camera = newCamera(vec2(0,0))

  var levelNum = 0
  while fileExists($levelNum & ".lvl"):
    levels.add(unserializeLevel(levelNum))
    levelNum += 1
  #startBuildLevel(levelNum)
  startExplore(levelNum-1)

#playSound(newAmbientNode(), -4.0, 0.0)


proc updateTextEntry(dt: float) =

  if talkProgress >= 1.0:
    if input.enteredText == "\b":
      if poemTextEntered.len > 0:
        poemTextEntered = poemTextEntered[0 .. <poemTextEntered.high]
    else:
      poemTextEntered &= input.enteredText
    if input.buttonPressed(input.confirm) and poemTextEntered.len > 0:
      currentLevel.screens[currentLevelScreen].poemLine = poemTextEntered
      currentPoem.add(poemTextEntered)
      startDrawing()
    timeAfterTalkFinished += dt
  else:
    if stateTime > 1:
      if not startedTalking:
        startedTalking = true
        say(currentPoem[currentPoem.high])
      talkProgress = (stateTime - 1) / (0.075 * float(currentPoem[currentPoem.high].len))


proc finishBuildLevel() =
  currentLevel.serialize()

proc updateDrawing(dr: float) =
  if input.buttonPressed(input.rotateLeft):
    lineGroup.rotate(RotateDirection.counterClockwise)
  if input.buttonPressed(input.rotateRight):
    lineGroup.rotate(RotateDirection.clockwise)
  if input.buttonPressed(input.cycleColor):
    lineGroup.cycleColor()
  if input.buttonPressed(input.left):
    lineGroup.translate(-1, 0)
  if input.buttonPressed(input.right):
    lineGroup.translate(1, 0)
  if input.buttonPressed(input.up):
    lineGroup.translate(0, 1)
  if input.buttonPressed(input.down):
    lineGroup.translate(0, -1)
  if input.buttonPressed(input.place):
    if currentLevel.screens[currentLevelScreen].tiles.len >= 16:
      if currentLevelScreen >= 7:
        finishBuildLevel()
      else:
        inc currentLevelScreen
        startTextEntry()
    else:
      startNewLineGroup()


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

  case gameState:
    of GameState.textEntry:
      updateTextEntry(dt)
    of GameState.drawing:
      updateDrawing(dt)
    of GameState.exploring:
      discard

  stateTime += dt

  mainCamera.update(dt)

proc render* () =
  glPushMatrix()
  let scale = 1 / ((numTilesY) * tileSize)
  glScaled(scale, scale, 1)

  glEnable (GL_BLEND);
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_TRIANGLES)
  for entity in entitiesOfType[LineObject]():
    entity.renderSolid()
  glEnd()
  glBlendFunc (GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR)
  glBegin(GL_TRIANGLES)
  for entity in entitiesOfType[Rock]():
    entity.renderSolid()
  glEnd()
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_TRIANGLES)
  for entity in entitiesOfType[NormalDrawEntity]():
    entity.renderSolid()
  glEnd()
  glBegin(GL_LINES)
  for entity in entitiesOfType[NormalDrawEntity]():
    entity.renderLine()
  glEnd()
  glBlendFunc(GL_ONE, GL_ZERO)
  glBegin(GL_TRIANGLES)
  entityOfType[Floor]().renderSolid()
  glEnd()
  glBegin(GL_LINES)
  entityOfType[Floor]().renderLine()
  glEnd()
  glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_COLOR);
  glBegin(GL_LINES)
  for entity in entitiesOfType[LineObject]():
    entity.renderLine()
  glEnd()
  glPopMatrix()
