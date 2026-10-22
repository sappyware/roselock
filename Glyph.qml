import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property string kind: "power"
  property color color: "white"
  property real size: 20
  property real strokeWidth: 1.8
  property bool filled: kind === "sleep" || kind === "play"

  width: size
  height: size

  readonly property bool hasCurve: Shape.CurveRenderer !== undefined
  readonly property real k: size / 24

  readonly property var paths: ({
    "power":   "M 6.86 6.87 A 8 8 0 1 0 17.14 6.87 M 12 3.5 L 12 12",
    "restart": "M 19.52 14.74 A 8 8 0 1 1 17.14 5.87 M 16.75 1.38 L 17.14 5.87 L 12.65 6.26",
    "sleep":   "M 21 12.79 A 9 9 0 1 1 11.21 3 A 7 7 0 0 0 21 12.79 Z",
    "arrow":   "M 5 12 L 19 12 M 13 6 L 19 12 L 13 18",
    "wifi":    "M 9.17 16.17 A 4 4 0 0 1 14.83 16.17 M 6.34 13.34 A 8 8 0 0 1 17.66 13.34 M 3.51 10.51 A 12 12 0 0 1 20.49 10.51 M 12 18.8 L 12 19.2",
    "play":    "M 7 4 L 20 12 L 7 20 Z",
    "pause":   "M 8 5 L 8 19 M 16 5 L 16 19"
  })

  function scaled(d, k) {
    var t = d.split(" "), out = [], i = 0;
    while (i < t.length) {
      var c = t[i++];
      if (c === "M" || c === "L") {
        out.push(c, t[i] * k, t[i + 1] * k); i += 2;
      } else if (c === "A") {
        out.push(c, t[i] * k, t[i + 1] * k, t[i + 2], t[i + 3], t[i + 4], t[i + 5] * k, t[i + 6] * k); i += 7;
      } else if (c === "Z") {
        out.push(c);
      }
    }
    return out.join(" ");
  }
  readonly property string d: scaled(paths[kind], k)

  Item {
    anchors.fill: parent
    layer.enabled: !root.hasCurve
    layer.samples: 8
    layer.smooth: true
    layer.mipmap: true
    layer.textureSize: Qt.size(Math.max(1, Math.ceil(root.size * Screen.devicePixelRatio * 3)),
      Math.max(1, Math.ceil(root.size * Screen.devicePixelRatio * 3)))

    Shape {
      anchors.fill: parent
      preferredRendererType: root.hasCurve ? Shape.CurveRenderer : Shape.GeometryRenderer

      ShapePath {
        strokeColor: root.filled ? "transparent" : root.color
        strokeWidth: root.strokeWidth * root.k
        fillColor: root.filled ? root.color : "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathSvg { path: root.d }
      }
    }
  }
}
