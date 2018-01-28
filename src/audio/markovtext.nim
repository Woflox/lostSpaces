import ../util/random
import strutils
import tables
import voice

const prose = staticRead("../../content/prose.txt")
const numChars = 2

var markovTable: Table[string, seq[char]]
markovTable = initTable[string, seq[char]]()

proc calculateMarkovTable* =
  for i in numChars..prose.high:
    var substring = prose[i-numChars..i-1]
    if not markovTable.hasKey(substring):
      markovTable.add(substring, @[])
    markovTable[substring].add(prose[i])

proc getMarkovString* (length: int): string =
  let startIndex = random(0, prose.len - numChars)
  var generatedString = prose[startIndex..(startIndex+numChars-1)]
  while generatedString.len < length:
    var substring = generatedString[(generatedString.high+1-numChars)..generatedString.high]
    if not markovTable.hasKey(substring):
      return generatedString
    generatedString &= markovTable[substring].randomChoice()
  return generatedString
