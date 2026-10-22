import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell

Item {
  id: root

  readonly property bool useShader: Config.wallpaperMode === "shader" && Config.wallpaperShaderReady
  readonly property bool useScreenshot: Config.wallpaperMode === "screenshot_blur"
    && Config.desktop.toString() !== ""
  readonly property bool blurActive: useScreenshot && Config.screenshotBlur > 0

  readonly property url imageSource: useScreenshot ? Config.desktop : Config.wallpaper

  property real shaderTime: 0
  Timer {
    interval: Math.round(1000 / Math.max(1, Config.shaderFps))
    running: root.useShader
    repeat: true
    triggeredOnStart: true
    onTriggered: root.shaderTime += interval / 1000.0
  }

  readonly property bool ready: width > 0 && (
    useShader
      || (imgLoader.item !== null
        && (imgLoader.item.status === Image.Ready || imgLoader.item.status === Image.Error))
  )

  Loader {
    id: shaderLoader
    anchors.fill: parent
    active: root.useShader
    sourceComponent: ShaderEffect {
      anchors.fill: parent
      fragmentShader: Config.wallpaperShaderUrl
      property real time: root.shaderTime
    }
  }

  Loader {
    id: imgLoader
    anchors.fill: parent
    active: !root.useShader && root.width > 0
    sourceComponent: Item {
      id: imgWrap
      anchors.fill: parent
      clip: true

      readonly property int pad: Math.ceil(Math.max(0, Config.screenshotBlur) * 96) + 4
      readonly property int status: img.status

      Image {
        id: img
        anchors.fill: parent
        anchors.margins: root.blurActive ? -imgWrap.pad : 0
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        smooth: true
        sourceSize.width: Math.min(7680, Math.round(root.width * Screen.devicePixelRatio))
        layer.enabled: root.blurActive
        layer.effect: MultiEffect {
          blurEnabled: true
          blur: Config.screenshotBlur
          blurMax: 96
          autoPaddingEnabled: false
        }
      }
    }
  }

  Item {
    anchors.fill: parent
    visible: !root.useShader
      && imgLoader.item !== null
      && imgLoader.item.status === Image.Error

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
}
