import ../util/random
import strutils

const prose = staticRead("../../content/prose.txt")
let proseLines = prose.splitLines()

proc getProse* (): string =
  proseLines.randomChoice()
