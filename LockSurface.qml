import QtQuick
import QtQuick.Effects
import Quickshell

Item {
  id: root

  required property LockContext context
  readonly property real u: Math.max(0.5, height / 900)
  property var screen: null
  property real lift: root.context.unlocking ? 22 * root.u : 0
  Behavior on lift { NumberAnimation { duration: 450; easing.type: Easing.InCubic } }

  property real intro: 0
  property real introLogin: 0

  Component.onCompleted: if (wall.ready) introAnim.start()
  Connections { target: wall; function onReadyChanged() { if (wall.ready) introAnim.start() } }
  Timer { interval: 1500; running: true; onTriggered: if (root.intro === 0) introAnim.start() }
  ParallelAnimation {
    id: introAnim
    NumberAnimation { target: root; property: "intro"; from: 0; to: 1; duration: 900; easing.type: Easing.OutCubic }
    SequentialAnimation {
      PauseAnimation { duration: 140 }
      NumberAnimation { target: root; property: "introLogin"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic }
    }
  }

  SystemClock { id: clock; precision: SystemClock.Minutes }

  readonly property point origin: {
    var mx = 1e9, my = 1e9, sc = Quickshell.screens;
    for (var i = 0; i < sc.length; i++) { mx = Math.min(mx, sc[i].x); my = Math.min(my, sc[i].y); }
    return Qt.point(mx, my);
  }

  Image {
    id: desktopImg
    anchors.fill: parent
    source: Config.desktop
    asynchronous: true
    fillMode: Image.Stretch
    sourceClipRect: root.screen
      ? Qt.rect(root.screen.x - root.origin.x, root.screen.y - root.origin.y, root.screen.width, root.screen.height)
      : Qt.rect(0, 0, 0, 0)
    opacity: Config.transitionMode === "screenshot" ? 1 : 0
  }

  Item {
    id: lockStack
    anchors.fill: parent
    opacity: (root.context.unlocking && Config.transitionMode === "screenshot"
        && desktopImg.status === Image.Ready) ? 0
      : (root.context.unlocking && Config.transitionMode === "live") ? 0
      : 1
    scale: root.context.unlocking ? 1.06 : 1
    Behavior on opacity {
      NumberAnimation {
        duration: root.context.unlocking ? Config.transitionFadeMs : 0
        easing.type: Easing.InOutCubic
      }
    }
    Behavior on scale { NumberAnimation { duration: 620; easing.type: Easing.OutCubic } }

    Wallpaper { id: wall; anchors.fill: parent }

    Rectangle {
      anchors.fill: parent
      color: "black"
      opacity: wall.ready ? 0 : 1
      Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    Rectangle { anchors.fill: parent; color: "black"; opacity: Config.dim }

    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top }
      height: parent.height * 0.35
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.30) }
        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.0) }
      }
    }
    Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      height: parent.height * 0.40
      gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.34) }
      }
    }
  }

  MultiEffect {
    id: blurred
    anchors.fill: parent
    source: wall
    visible: false
    autoPaddingEnabled: false
    blurEnabled: true
    blur: Config.glassBlur
    blurMax: 128
    saturation: 0.35
    brightness: -0.05
  }

  Item {
    id: ui
    anchors.fill: parent
    opacity: root.context.unlocking ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.InOutQuad } }

    Row {
      anchors { top: parent.top; right: parent.right; topMargin: 14 * root.u; rightMargin: 22 * root.u }
      height: 16 * root.u
      spacing: 15 * root.u
      opacity: root.intro

      Glyph {
        visible: Config.showWifi
        anchors.verticalCenter: parent.verticalCenter
        kind: "wifi"
        size: 17 * root.u
        strokeWidth: 2.3
        color: Qt.rgba(1, 1, 1, 0.92)
      }
      BatteryIcon {
        anchors.verticalCenter: parent.verticalCenter
        u: root.u
      }
    }

    Column {
      id: clockBlock
      anchors.horizontalCenter: parent.horizontalCenter
      y: 72 * root.u + (1 - root.intro) * 14 * root.u - root.lift
      opacity: root.intro
      spacing: -4 * root.u

      ShadowText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
        color: Qt.rgba(1, 1, 1, 0.88)
        font.family: Config.body
        font.pixelSize: 22 * root.u
        font.weight: Font.DemiBold
      }
     ShadowText {
    anchors.horizontalCenter: parent.horizontalCenter
    text: {
        if (Config.use24h)
            return Qt.formatDateTime(clock.date, "HH:mm");
        var h = clock.date.getHours() % 12;
        if (h === 0) h = 12;
        var m = clock.date.getMinutes();
        return h + ":" + (m < 10 ? "0" + m : m);
    }
    color: Qt.rgba(1, 1, 1, 0.92)
    font.family: Config.display
    font.pixelSize: 108 * root.u
    font.weight: Config.clockWeight
    font.letterSpacing: -3 * root.u
}
    }

    NowPlaying {
      id: npWidget
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: clockBlock.bottom
      anchors.topMargin: 34 * root.u
      source: blurred
      u: root.u
      opacity: root.intro * (npWidget.active ? 1 : 0)
      Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    Column {
      id: login
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 150 * root.u
      opacity: root.introLogin

      Avatar {
        anchors.horizontalCenter: parent.horizontalCenter
        size: 80 * root.u
      }
      Item { width: 1; height: 12 * root.u }
      ShadowText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Config.userName
        color: Qt.rgba(1, 1, 1, 0.96)
        font.family: Config.body
        font.pixelSize: 19 * root.u
        font.weight: Font.DemiBold
      }
      Item { width: 1; height: 16 * root.u }

      Item {
        id: field
        anchors.horizontalCenter: parent.horizontalCenter
        width: 236 * root.u
        height: 38 * root.u
        opacity: root.context.unlockInProgress ? 0.6 : 1
        property real shakeX: 0
        transform: Translate { x: field.shakeX }

        Glass {
          anchors.fill: parent
          source: blurred
          tint: input.activeFocus ? Qt.rgba(1, 1, 1, 0.24) : Qt.rgba(1, 1, 1, 0.20)
          Behavior on tint { ColorAnimation { duration: 150 } }
        }

        MouseArea { anchors.fill: parent; onClicked: input.forceActiveFocus() }

        Text {
          anchors { left: parent.left; leftMargin: 17 * root.u; verticalCenter: parent.verticalCenter }
          visible: input.text.length === 0
          text: "Enter Password"
          color: Qt.rgba(1, 1, 1, 0.62)
          font.family: Config.body
          font.pixelSize: 14.5 * root.u
          font.weight: Font.Medium
        }

        TextInput {
          id: input
          anchors {
            left: parent.left; leftMargin: 17 * root.u
            right: arrowBtn.left; rightMargin: 6 * root.u
            verticalCenter: parent.verticalCenter
          }
          clip: true
          focus: true
          enabled: !root.context.unlockInProgress
          echoMode: TextInput.Password
          passwordCharacter: "•"
          inputMethodHints: Qt.ImhSensitiveData
          color: "white"
          selectionColor: Qt.rgba(1, 1, 1, 0.35)
          selectedTextColor: "white"
          font.family: Config.body
          font.pixelSize: 17 * root.u
          font.letterSpacing: 1.5 * root.u
          cursorDelegate: Rectangle { width: 1.5 * root.u; color: Qt.rgba(1, 1, 1, 0.95) }

          Component.onCompleted: forceActiveFocus()
          onTextChanged: root.context.currentText = text
          onAccepted: root.context.tryUnlock()
          Keys.onEscapePressed: root.context.currentText = ""
        }

        Connections {
          target: root.context
          function onCurrentTextChanged() { input.text = root.context.currentText }
          function onFailed() { shake.restart() }
        }

        Rectangle {
          id: arrowBtn
          width: 26 * root.u
          height: 26 * root.u
          radius: width / 2
          antialiasing: true
          anchors { right: parent.right; rightMargin: 6 * root.u; verticalCenter: parent.verticalCenter }
          opacity: input.text.length > 0 ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 150 } }
          color: arrowMa.containsMouse ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.30)
          Behavior on color { ColorAnimation { duration: 120 } }

          Glyph {
            anchors.centerIn: parent
            kind: "arrow"
            size: 14 * root.u
            strokeWidth: 2.4
            color: "white"
          }
          MouseArea {
            id: arrowMa
            anchors.fill: parent
            hoverEnabled: true
            enabled: parent.opacity > 0.5
            cursorShape: Qt.PointingHandCursor
            onClicked: root.context.tryUnlock()
          }
        }

        SequentialAnimation {
          id: shake
          NumberAnimation { target: field; property: "shakeX"; to: -14 * root.u; duration: 50 }
          NumberAnimation { target: field; property: "shakeX"; to: 14 * root.u; duration: 70 }
          NumberAnimation { target: field; property: "shakeX"; to: -10 * root.u; duration: 70 }
          NumberAnimation { target: field; property: "shakeX"; to: 10 * root.u; duration: 70 }
          NumberAnimation { target: field; property: "shakeX"; to: -5 * root.u; duration: 60 }
          NumberAnimation { target: field; property: "shakeX"; to: 0; duration: 60 }
        }
      }

      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: field.width
        height: 26 * root.u
        ShadowText {
          anchors.horizontalCenter: parent.horizontalCenter
          y: 9 * root.u
          text: "Incorrect password"
          color: Qt.rgba(1, 1, 1, 0.8)
          font.family: Config.body
          font.pixelSize: 12.5 * root.u
          font.weight: Font.Medium
          opacity: root.context.showFailure ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 200 } }
        }
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Math.round(38 * root.u)
      spacing: Math.round(18 * root.u / 2) * 2
      opacity: root.introLogin

      ActionButton {
        label: "Sleep"; kind: "sleep"; u: root.u; source: blurred
        onTriggered: Quickshell.execDetached(["systemctl", "suspend"])
      }
      ActionButton {
        label: "Restart"; kind: "restart"; u: root.u; source: blurred; needsConfirm: true
        onTriggered: Quickshell.execDetached(["systemctl", "reboot"])
      }
      ActionButton {
        label: "Shut Down"; kind: "power"; u: root.u; source: blurred; needsConfirm: true
        onTriggered: Quickshell.execDetached(["systemctl", "poweroff"])
      }
    }
  }
}
