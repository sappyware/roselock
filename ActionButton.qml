import QtQuick

Item {
  id: btn

  property string label: ""
  property string kind: "power"
  property Item source
  property real u: 1
  property bool needsConfirm: false
  property bool armed: false
  signal triggered()

  readonly property int circleSize: Math.round(44 * u / 2) * 2
  readonly property int gap: Math.round(9 * u)
  readonly property int labelSize: Math.round(12 * u)

  width: Math.round(78 * u / 2) * 2
  height: circleSize + gap + labelSize + Math.round(6 * u)

  Timer { id: disarm; interval: 2600; onTriggered: btn.armed = false }

  Item {
    id: circle
    width: btn.circleSize
    height: btn.circleSize
    x: Math.round((btn.width - width) / 2)
    scale: ma.pressed ? 0.93 : 1
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }

    Glass {
      anchors.fill: parent
      source: btn.source
      blur: true
      tint: btn.armed ? Qt.rgba(1, 0.27, 0.23, 0.55)
        : (ma.containsMouse ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(1, 1, 1, 0.22))
      Behavior on tint { ColorAnimation { duration: 140 } }
    }

    Glyph {
      readonly property int px: Math.round(20 * btn.u / 2) * 2
      size: px
      x: Math.round((parent.width - px) / 2)
      y: Math.round((parent.height - px) / 2)
      kind: btn.kind
      strokeWidth: 1.9
      color: Qt.rgba(1, 1, 1, 0.95)
    }

    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        if (btn.needsConfirm && !btn.armed) {
          btn.armed = true;
          disarm.restart();
        } else {
          btn.armed = false;
          btn.triggered();
        }
      }
    }
  }

  Text {
    id: shadowLbl
    x: lbl.x
    y: lbl.y + 1
    text: lbl.text
    color: Qt.rgba(0, 0, 0, 0.35)
    font: lbl.font
  }
  Text {
    id: lbl
    x: Math.round((btn.width - width) / 2)
    y: btn.circleSize + btn.gap
    text: btn.armed ? "Click again" : btn.label
    color: Qt.rgba(1, 1, 1, 0.94)
    font.family: Config.body
    font.pixelSize: btn.labelSize
    font.weight: Font.Medium
  }
}
