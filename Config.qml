pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/roselock"
  readonly property string configPath: configDir + "/config.toml"

  property string wallpaperMode: "screenshot_blur"
  property string screenshotPath: ""
  property real screenshotBlur: 0.6
  property real glassBlur: 1.0
  property string wallpaperShader: "topo"
  property int shaderFps: 30
  property string wallpaperFile: ""

  property bool use24h: false
  property int clockWeight: Font.DemiBold
  property string userFamily: ""
  property string displayName: ""
  property bool showWifi: true
  property bool showBatteryPercent: false
  property real dim: 0.14

  property string transitionMode: "screenshot"
  property int transitionFadeMs: 700

  readonly property string screenshotPathResolved: {
    if (screenshotPath !== "") return screenshotPath;
    var p = Quickshell.env("ROSELOCK_DESKTOP") || Quickshell.env("MACOS_LOCK_DESKTOP");
    if (p) return p;
    return (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/roselock-desktop.png";
  }

  property bool desktopFileExists: false

  readonly property url desktop: (desktopFileExists && screenshotPathResolved !== "")
    ? "file://" + screenshotPathResolved
    : ""

  readonly property url wallpaper: {
    if (wallpaperFile !== "")
      return wallpaperFile.startsWith("file://") ? wallpaperFile : "file://" + wallpaperFile;
    var p = Quickshell.env("ROSELOCK_WALLPAPER") || Quickshell.env("MACOS_LOCK_WALLPAPER");
    if (p) return "file://" + p;
    return Qt.resolvedUrl("background.jpg");
  }
  readonly property url avatar: "file://" + (Quickshell.env("HOME") || "") + "/.face"

  readonly property string userName: {
    if (displayName !== "") return displayName;
    var u = Quickshell.env("USER") || "User";
    return u.charAt(0).toUpperCase() + u.slice(1);
  }

  readonly property string wallpaperShaderPath: {
    var p = Quickshell.env("ROSELOCK_SHADER") || Quickshell.env("MACOS_LOCK_WALLPAPER_SHADER");
    if (p) return p;
    return (Quickshell.env("HOME") || "") + "/.config/rosewallpapers/shaders/" + wallpaperShader + ".frag.qsb";
  }
  property url wallpaperShaderUrl: ""
  property bool wallpaperShaderFileFound: false
  readonly property bool wallpaperShaderReady: wallpaperMode === "shader" && wallpaperShaderFileFound

  property var families: []
  function register(name) {
    if (name && families.indexOf(name) < 0) families = families.concat([name]);
  }
  readonly property string body: {
    if (userFamily !== "") return userFamily;
    if (families.indexOf("Inter") >= 0) return "Inter";
    for (var i = 0; i < families.length; i++)
      if (families[i].indexOf("Inter") === 0 && families[i].indexOf("Display") < 0) return families[i];
    return "Inter";
  }
  readonly property string display: families.indexOf("Inter Display") >= 0 ? "Inter Display" : body

  Process {
    id: ensureConfig
    command: ["sh", "-c", `if [ ! -s "$1" ]; then
mkdir -p "$(dirname "$1")"
cat > "$1" <<'__RWEOF__'
# roselock config - hot-reloaded on save
[wallpaper]
# "screenshot_blur" | "file" | "shader"
mode = "screenshot_blur"
# explicit screenshot path; empty = ROSELOCK_DESKTOP env, else $XDG_RUNTIME_DIR/roselock-desktop.png
screenshot_path = ""
screenshot_blur = 0.6
glass_blur = 1.0
shader = "topo"
shader_fps = 30
file = ""

[ui]
use24h = false
dim = 0.14
show_wifi = true
show_battery_percent = false
user_family = ""
display_name = ""

[transition]
# "screenshot" | "live"
mode = "screenshot"
fade_ms = 700
__RWEOF__
fi`, "sh", root.configPath]
    running: true
    onExited: (code) => {
      if (code !== 0) console.error("[roselock] failed to create default config");
      if (!reader.running) reader.running = true;
    }
  }

  property string lastRawContent: ""

  Process {
    id: reader
    command: ["cat", root.configPath]
    stdout: StdioCollector {
      onStreamFinished: {
        if (text !== root.lastRawContent) {
          root.lastRawContent = text;
          if (!parser.running) parser.running = true;
        }
      }
    }
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: if (!reader.running) reader.running = true
  }

  Process {
    id: parser
    command: ["python3", "-c", "import tomllib,json,sys;print(json.dumps(tomllib.load(open(sys.argv[1],'rb'))))", root.configPath]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.apply(JSON.parse(text));
        } catch (e) {
          console.error("[roselock] config parse failed:", e);
        }
      }
    }
  }

  function apply(d) {
    var w = d.wallpaper || {};
    if (w.mode !== undefined) wallpaperMode = String(w.mode);
    if (w.screenshot_path !== undefined) screenshotPath = String(w.screenshot_path);
    if (w.screenshot_blur !== undefined) screenshotBlur = Number(w.screenshot_blur);
    if (w.glass_blur !== undefined) glassBlur = Number(w.glass_blur);
    if (w.shader !== undefined) wallpaperShader = String(w.shader);
    if (w.shader_fps !== undefined) shaderFps = Number(w.shader_fps);
    if (w.file !== undefined) wallpaperFile = String(w.file);

    var u = d.ui || {};
    if (u.use24h !== undefined) use24h = Boolean(u.use24h);
    if (u.dim !== undefined) dim = Number(u.dim);
    if (u.show_wifi !== undefined) showWifi = Boolean(u.show_wifi);
    if (u.show_battery_percent !== undefined) showBatteryPercent = Boolean(u.show_battery_percent);
    if (u.user_family !== undefined) userFamily = String(u.user_family);
    if (u.display_name !== undefined) displayName = String(u.display_name);

    var t = d.transition || {};
    if (t.mode !== undefined) transitionMode = String(t.mode);
    if (t.fade_ms !== undefined) transitionFadeMs = Number(t.fade_ms);

    root.probeScreenshot();
    root.probeShader();
  }

  Process {
    id: screenshotProbe
    command: ["test", "-s", root.screenshotPathResolved]
    onExited: (code) => {
      var exists = (code === 0);
      if (root.desktopFileExists !== exists) {
        root.desktopFileExists = exists;
        if (exists) console.log("[roselock] screenshot ready:", root.screenshotPathResolved);
        else if (root.wallpaperMode === "screenshot_blur")
          console.warn("[roselock] mode=screenshot_blur but missing:", root.screenshotPathResolved);
      }
    }
  }
  function probeScreenshot() {
    if (screenshotProbe.running) return;
    screenshotProbe.running = true;
  }
  onScreenshotPathResolvedChanged: probeScreenshot()
  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.probeScreenshot()
  }

  Process {
    id: shaderProbe
    command: ["test", "-f", root.wallpaperShaderPath]
    onExited: (code) => {
      if (code === 0) {
        root.wallpaperShaderUrl = "file://" + root.wallpaperShaderPath;
        root.wallpaperShaderFileFound = true;
      } else {
        root.wallpaperShaderFileFound = false;
        if (root.wallpaperMode === "shader")
          console.warn("[roselock] mode=shader but missing:", root.wallpaperShaderPath);
      }
    }
  }
  function probeShader() {
    if (root.wallpaperMode !== "shader") return;
    if (shaderProbe.running) return;
    shaderProbe.running = true;
  }
  onWallpaperModeChanged: probeShader()
  onWallpaperShaderPathChanged: probeShader()

  Component.onCompleted: {
    probeScreenshot();
    probeShader();
  }
}
