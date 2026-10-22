import QtQuick
import QtQuick.Shapes
import Quickshell

Item {
  id: root

  readonly property bool usingShader: Config.wallpaperShaderReady

  readonly property bool ready: width > 0 && (
    usingShader
      || (loader.item !== null
        && (loader.item.status === Image.Ready || loader.item.status === Image.Error))
  )

  property real shaderTime: 0
  Timer {
    interval: 33
    running: root.usingShader
    repeat: true
    triggeredOnStart: true
    onTriggered: root.shaderTime += interval / 1000.0
  }

  Loader {
    id: shaderLoader
    anchors.fill: parent
    active: root.usingShader
    sourceComponent: ShaderEffect {
      anchors.fill: parent
      fragmentShader: Config.wallpaperShaderUrl
      property real time: root.shaderTime
    }
  }

  Item {
    anchors.fill: parent
    visible: !root.usingShader && root.ready
      && loader.item && loader.item.status === Image.Error

    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#16123a" }
        GradientStop { position: 0.55; color: "#43286f" }
        GradientStop { position: 1.0; color: "#b9487a" }
      }
    }

    component Blob: Shape {
      id: blob
      property real cx: 0.5
      property real cy: 0.5
      property real r: 0.5
      property color tone: "white"
      property real strength: 0.6
      anchors.fill: parent
      ShapePath {
        strokeColor: "transparent"
        fillGradient: RadialGradient {
          centerX: root.width * blob.cx
          centerY: root.height * blob.cy
          centerRadius: root.width * blob.r
          focalX: centerX
          focalY: centerY
          GradientStop { position: 0.0; color: Qt.rgba(blob.tone.r, blob.tone.g, blob.tone.b, blob.strength) }
          GradientStop { position: 1.0; color: Qt.rgba(blob.tone.r, blob.tone.g, blob.tone.b, 0) }
        }
        startX: 0; startY: 0
        PathLine { x: root.width; y: 0 }
        PathLine { x: root.width; y: root.height }
        PathLine { x: 0; y: root.height }
        PathLine { x: 0; y: 0 }
      }
    }

    Blob { cx: 0.18; cy: 0.22; r: 0.55; tone: "#4c7dff"; strength: 0.55 }
    Blob { cx: 0.85; cy: 0.30; r: 0.45; tone: "#ff6fb1"; strength: 0.50 }
    Blob { cx: 0.60; cy: 1.00; r: 0.60; tone: "#ffa46b"; strength: 0.55 }
  }

  Loader {
    id: loader
    anchors.fill: parent
    active: !root.usingShader && root.width > 0
    sourceComponent: Image {
      source: Config.wallpaper
      fillMode: Image.PreserveAspectCrop
      asynchronous: false
      smooth: true
      sourceSize.width: Math.min(7680, Math.round(root.width * Screen.devicePixelRatio))
    }
  }
}
