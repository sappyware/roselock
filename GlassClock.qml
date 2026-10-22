import QtQuick
import QtQuick.Effects

Item {
  id: gc

  property string text: ""
  property string family: "Inter"
  property real pixelSize: 100
  property int weight: Font.Bold
  property real letterSpacing: 0
  property real u: 1

  property Item source
  property real blurAmount: 0.22
  property real tintAlpha: 0.12
  property real lightness: -0.06
  property real lens: 0.05

  readonly property int pad: Math.ceil(10 * u)
  readonly property int rim: Math.max(1, Math.round(1.6 * u))
  readonly property font f: Qt.font({ family: family, pixelSize: pixelSize, weight: weight, letterSpacing: letterSpacing })

  Text { id: metrics; visible: false; text: gc.text; font: gc.f }

  width: Math.ceil(metrics.implicitWidth) + 2 * pad
  height: Math.ceil(metrics.implicitHeight) + 2 * pad

  property rect srcRect: Qt.rect(0, 0, 1, 1)
  function sync() {
    if (!source || width <= 0 || height <= 0) return;
    var p = gc.mapToItem(source, 0, 0);
    var ix = width * lens / 2, iy = height * lens / 2;
    srcRect = Qt.rect(p.x + ix, p.y + iy, width - 2 * ix, height - 2 * iy);
  }
  Component.onCompleted: Qt.callLater(sync)
  onWidthChanged: Qt.callLater(sync)
  onHeightChanged: Qt.callLater(sync)
  Connections {
    target: gc.source
    function onWidthChanged() { Qt.callLater(gc.sync) }
    function onHeightChanged() { Qt.callLater(gc.sync) }
  }

  Item {
    id: base
    width: gc.width; height: gc.height
    visible: false
    layer.enabled: true
    Text { x: gc.pad; y: gc.pad; text: gc.text; font: gc.f; color: "white" }
  }
  Item {
    id: shiftDR
    width: gc.width; height: gc.height
    visible: false
    layer.enabled: true
    Text { x: gc.pad + gc.rim; y: gc.pad + gc.rim; text: gc.text; font: gc.f; color: "white" }
  }
  Item {
    id: shiftUL
    width: gc.width; height: gc.height
    visible: false
    layer.enabled: true
    Text { x: gc.pad - gc.rim; y: gc.pad - gc.rim; text: gc.text; font: gc.f; color: "white" }
  }
  Item {
    id: sheen
    width: gc.width; height: gc.height
    visible: false
    layer.enabled: true
    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.06) }
        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.02) }
      }
    }
  }

  MultiEffect {
    y: Math.round(5 * gc.u)
    width: gc.width; height: gc.height
    source: base
    colorization: 1.0
    colorizationColor: "black"
    blurEnabled: true
    blur: 0.6
    blurMax: 32
    opacity: 0.28
  }

  ShaderEffectSource {
    id: ses
    width: gc.width; height: gc.height
    sourceItem: gc.source
    sourceRect: gc.srcRect
    visible: false
    live: true
  }
  MultiEffect {
    width: gc.width; height: gc.height
    source: ses
    blurEnabled: true
    blur: gc.blurAmount
    blurMax: 24
    brightness: gc.lightness
    saturation: 0.3
    contrast: 0.05
    maskEnabled: true
    maskSource: base
  }

  Text { x: gc.pad; y: gc.pad; text: gc.text; font: gc.f; color: Qt.rgba(1, 1, 1, gc.tintAlpha) }
  MultiEffect {
    width: gc.width; height: gc.height
    source: sheen
    maskEnabled: true
    maskSource: base
  }

  MultiEffect {
    width: gc.width; height: gc.height
    source: base
    maskEnabled: true
    maskSource: shiftDR
    maskInverted: true
    opacity: 0.95
  }
  MultiEffect {
    width: gc.width; height: gc.height
    source: base
    maskEnabled: true
    maskSource: shiftUL
    maskInverted: true
    opacity: 0.40
  }
}
