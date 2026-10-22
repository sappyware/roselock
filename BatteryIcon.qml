import QtQuick
import Quickshell.Services.UPower

Row {
  id: root
  property real u: 1

  readonly property var dev: UPower.displayDevice
  readonly property bool present: dev !== null && dev !== undefined && dev.isPresent
  readonly property real pct: {
    if (!present) return 0;
    var p = dev.percentage;
    if (p > 1) p = p / 100;
    return Math.max(0, Math.min(1, p));
  }
  readonly property bool charging: present
    && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged)

  visible: present
  spacing: 5 * u

  Text {
    visible: Config.showBatteryPercent
    anchors.verticalCenter: parent.verticalCenter
    text: Math.round(root.pct * 100) + "%"
    color: Qt.rgba(1, 1, 1, 0.9)
    font.family: Config.body
    font.pixelSize: 13 * root.u
    font.weight: Font.Medium
  }

  Item {
    width: 28 * root.u
    height: 13 * root.u
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
      id: body
      width: 25 * root.u
      height: parent.height
      radius: 3.6 * root.u
      antialiasing: true
      color: "transparent"
      border.width: Math.max(1, 1 * root.u)
      border.color: Qt.rgba(1, 1, 1, 0.5)

      Rectangle {
        x: 2 * root.u
        y: 2 * root.u
        height: body.height - 4 * root.u
        width: Math.max(2 * root.u, (body.width - 4 * root.u) * root.pct)
        radius: 1.8 * root.u
        antialiasing: true
        color: root.charging ? "#34C759" : (root.pct <= 0.2 ? "#FF3B30" : Qt.rgba(1, 1, 1, 0.92))
      }
    }
    Rectangle {
      x: 25.8 * root.u
      anchors.verticalCenter: parent.verticalCenter
      width: 2 * root.u
      height: 4.6 * root.u
      radius: 1 * root.u
      antialiasing: true
      color: Qt.rgba(1, 1, 1, 0.5)
    }
  }
}
