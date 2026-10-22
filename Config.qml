pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property bool use24h: false
  property int clockWeight: Font.DemiBold
  property string userFamily: ""
  property string displayName: ""
  property bool showWifi: true
  property bool showBatteryPercent: false
  property real dim: 0.14

  property string transitionMode: "screenshot"
  property int transitionFadeMs: 700

  readonly property url wallpaper: {
    var p = Quickshell.env("MACOS_LOCK_WALLPAPER");
    if (p) return "file://" + p;
    return Qt.resolvedUrl("Beach-Dark.jpg");
  }
  readonly property url desktop: {
    var p = Quickshell.env("MACOS_LOCK_DESKTOP");
    return p ? "file://" + p : "";
  }
  readonly property url avatar: "file://" + (Quickshell.env("HOME") || "") + "/.face"

  readonly property string userName: {
    if (displayName !== "") return displayName;
    var u = Quickshell.env("USER") || "User";
    return u.charAt(0).toUpperCase() + u.slice(1);
  }

  property var families: []
  function register(name) {
    if (name && families.indexOf(name) < 0)
      families = families.concat([name]);
  }
  readonly property string body: {
    if (userFamily !== "") return userFamily;
    if (families.indexOf("Inter") >= 0) return "Inter";
    for (var i = 0; i < families.length; i++)
      if (families[i].indexOf("Inter") === 0 && families[i].indexOf("Display") < 0)
        return families[i];
    return "Inter";
  }
  readonly property string display: families.indexOf("Inter Display") >= 0 ? "Inter Display" : body

  readonly property string wallpaperShaderPath: {
    var p = Quickshell.env("MACOS_LOCK_WALLPAPER_SHADER");
    if (p) return p;
    return (Quickshell.env("HOME") || "") + "/.config/rosewallpapers/shaders/topo.frag.qsb";
  }
  property url wallpaperShaderUrl: ""
  property bool wallpaperShaderReady: false

  Process {
    command: ["test", "-f", root.wallpaperShaderPath]
    running: true
    onExited: (code) => {
      if (code === 0) {
        root.wallpaperShaderUrl = "file://" + root.wallpaperShaderPath;
        root.wallpaperShaderReady = true;
      }
    }
  }
}
