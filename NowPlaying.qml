import QtQuick
import QtQuick.Effects
import Quickshell.Services.Mpris

Item {
  id: np

  property Item source
  property real u: 1

  readonly property var playersArr: {
    if (!Mpris.players) return [];
    return Mpris.players.values ? Mpris.players.values : Mpris.players;
  }

  readonly property var player: {
    var ps = playersArr;
    if (!ps || ps.length === 0) return null;
    for (var i = 0; i < ps.length; i++)
      if (ps[i].isPlaying) return ps[i];
    for (var j = 0; j < ps.length; j++)
      if ((ps[j].trackTitle || "").length > 0) return ps[j];
    return null;
  }

  readonly property bool active: player !== null
    && player !== undefined
    && (player.trackTitle || "").length > 0

  width: 320 * u
  height: 58 * u
  visible: active
  opacity: active ? 1 : 0
  Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

  Component.onCompleted: console.log("[NowPlaying] players:", playersArr.length, "active:", active,
    player ? player.identity + " / " + player.trackTitle : "none")

  Glass {
    anchors.fill: parent
    source: np.source
    radius: 14 * u
  }

  Image {
    id: art
    anchors {
      left: parent.left
      leftMargin: 8 * u
      verticalCenter: parent.verticalCenter
    }
    width: 42 * u
    height: 42 * u
    source: np.player ? (np.player.trackArtUrl || "") : ""
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    layer.enabled: status === Image.Ready
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: artMask
    }
  }

  Rectangle {
    id: artMask
    anchors.fill: art
    radius: 6 * u
    visible: false
    layer.enabled: true
    antialiasing: true
  }

  Rectangle {
    anchors.fill: art
    radius: 6 * u
    color: Qt.rgba(1, 1, 1, 0.15)
    visible: art.status !== Image.Ready
  }

  Column {
    anchors {
      left: art.right
      leftMargin: 12 * u
      right: playBtn.left
      rightMargin: 8 * u
      verticalCenter: parent.verticalCenter
    }
    spacing: 2 * u

    Text {
      width: parent.width
      text: np.player ? (np.player.trackTitle || "") : ""
      color: Qt.rgba(1, 1, 1, 0.95)
      elide: Text.ElideRight
      font.family: Config.body
      font.pixelSize: 13 * u
      font.weight: Font.DemiBold
    }
    Text {
      width: parent.width
      text: np.player ? (np.player.trackArtist || "") : ""
      color: Qt.rgba(1, 1, 1, 0.65)
      elide: Text.ElideRight
      font.family: Config.body
      font.pixelSize: 11 * u
      font.weight: Font.Medium
    }
  }

  Item {
    id: playBtn
    anchors {
      right: parent.right
      rightMargin: 10 * u
      verticalCenter: parent.verticalCenter
    }
    width: 34 * u
    height: 34 * u

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: playArea.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.10)
      Behavior on color { ColorAnimation { duration: 120 } }
    }

    Glyph {
      anchors.centerIn: parent
      kind: (np.player && np.player.isPlaying) ? "pause" : "play"
      size: 13 * u
      strokeWidth: 2.4
      color: Qt.rgba(1, 1, 1, 0.95)
    }

    MouseArea {
      id: playArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: if (np.player) np.player.togglePlaying()
    }
  }
}
