import QtQuick
import QtQuick.Effects

Text {
  color: "white"
  renderType: Text.QtRendering
  layer.enabled: true
  layer.smooth: true
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowColor: Qt.rgba(0, 0, 0, 0.38)
    shadowBlur: 0.75
    shadowVerticalOffset: 1.5
    shadowHorizontalOffset: 0
  }
}
