import QtQuick
import QtQuick.Effects

Item {
  id: g

  property Item source
  property real radius: height / 2
  property color tint: Qt.rgba(1, 1, 1, 0.20)
  property real borderOpacity: 0.26
  property rect rectInSource: Qt.rect(0, 0, 1, 1)

  function sync() {
    if (!source || width <= 0 || height <= 0) return;
    var p = g.mapToItem(source, 0, 0);
    rectInSource = Qt.rect(p.x, p.y, width, height);
  }

  Component.onCompleted: Qt.callLater(sync)
  onWidthChanged: Qt.callLater(sync)
  onHeightChanged: Qt.callLater(sync)
  Connections {
    target: g.source
    function onWidthChanged() { Qt.callLater(g.sync) }
    function onHeightChanged() { Qt.callLater(g.sync) }
  }

  property bool blur: true

  Loader {
    anchors.fill: parent
    active: g.blur
    sourceComponent: Item {
      ShaderEffectSource {
        id: ses
        anchors.fill: parent
        sourceItem: g.source
        sourceRect: g.rectInSource
        visible: false
        live: true
      }

      Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: g.radius
        antialiasing: true
        visible: false
        layer.enabled: true
        layer.samples: 8
        layer.smooth: true
      }

      MultiEffect {
        anchors.fill: parent
        source: ses
        maskEnabled: true
        maskSource: maskRect
        saturation: 0.15
        brightness: 0.03
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: g.radius
    antialiasing: true
    color: g.tint
  }

  Rectangle {
    anchors.fill: parent
    radius: g.radius
    antialiasing: true
    gradient: Gradient {
      GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.10) }
      GradientStop { position: 0.6; color: Qt.rgba(1, 1, 1, 0.00) }
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: g.radius
    antialiasing: true
    color: "transparent"
    border.width: Math.max(1.5, g.radius > 20 ? 2 : 1.5)
    border.color: Qt.rgba(1, 1, 1, Math.min(0.55, g.borderOpacity * 1.8))
  }
}
