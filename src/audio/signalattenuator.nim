import audio
import math
import ../util/noise
import ../util/random
import ../util/util
import ../globals/globals

type
  SignalAttenuatorNodeObj = object of AudioNodeObj
    position : Vector2
    signalStrength: float
    signalRadius: float
    cutoffRadiusSquared: float
  SignalAttenuatorNode* = ptr SignalAttenuatorNodeObj

const dbAtRadius = -30 

proc newSignalAttenuatorNode*(position: Vector2, signalStrength: float, signalRadius: float): SignalAttenuatorNode =
  result = createShared(SignalAttenuatorNodeObj)
  result[] = SignalAttenuatorNodeObj()
  result.position = position
  result.signalStrength = signalStrength
  result.signalRadius = signalRadius
  result.cutoffRadiusSquared = (signalRadius * 2) * (signalRadius * 2)

method isSilent*(self: SignalAttenuatorNode): bool =
  return distanceSquared(self.position, crosshairPos) > self.cutoffRadiusSquared

method updateOutputs*(self: SignalAttenuatorNode, dt: float) =
  let d = distance(self.position, crosshairPos)

  let falloff = dbToAmplitude(dbAtRadius * d / self.signalRadius)

  self.output[0] = self.getInputNode(0).output[0] * falloff * dbToAmplitude(self.signalStrength)
  self.output[1] = self.getInputNode(0).output[1] * falloff * dbToAmplitude(self.signalStrength)


