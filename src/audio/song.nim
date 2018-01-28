import audio
import math
import ambient
import drumpattern
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  SongNodeObj = object of MixerNodeObj
  SongNode* = ptr SongNodeObj

proc newSongNode*: SongNode =
  result = createShared(SongNodeObj)
  result[] = SongNodeObj()
  result.addInput(newChordNode())
  result.addInput(newChordNode())
  result.addInput(newDrumPatternNode())
  