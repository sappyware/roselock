import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Item {
  id: av
  property real size: 80
  width: size
  height: size

  Rectangle {
    id: disc
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#b3b6bd" }
      GradientStop { position: 1.0; color: "#80838c" }
    }
  }

  Item {
    anchors.fill: parent
    visible: photo.status !== Image.Ready
    layer.enabled: true
    layer.samples: 4
    layer.smooth: true
    layer.mipmap: true
    layer.textureSize: Qt.size(Math.ceil(av.size * Screen.devicePixelRatio * 3), Math.ceil(av.size * Screen.devicePixelRatio * 3))

    Shape {
      Component.onCompleted: if (Shape.CurveRenderer !== undefined) preferredRendererType = Shape.CurveRenderer
      width: 100
      height: 100
      scale: av.size / 100
      transformOrigin: Item.TopLeft
      ShapePath {
        strokeColor: "transparent"
        fillColor: Qt.rgba(1, 1, 1, 0.92)
        PathSvg { path: "M 33 40 A 17 17 0 1 1 67 40 A 17 17 0 1 1 33 40 Z" }
      }
      ShapePath {
        strokeColor: "transparent"
        fillColor: Qt.rgba(1, 1, 1, 0.92)
        PathSvg { path: "M 17.5 88 C 17.5 70 33 62 50 62 C 67 62 82.5 70 82.5 88 A 50 50 0 0 1 17.5 88 Z" }
      }
    }
  }

  Rectangle {
    id: photoMask
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    visible: false
    layer.enabled: true
    layer.smooth: true
  }
  Image {
    id: photo
    anchors.fill: parent
    source: Config.avatar
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    smooth: true
    visible: status === Image.Ready
    layer.enabled: visible
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: photoMask
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    color: "transparent"
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.22)
  }
}
