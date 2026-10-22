import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Qt.labs.folderlistmodel

ShellRoot {
  id: shell

  FolderListModel {
    id: fontFiles
    folder: Qt.resolvedUrl("fonts")
    nameFilters: ["*.ttf", "*.otf", "*.TTF", "*.OTF"]
    showDirs: false
  }
  Instantiator {
    model: fontFiles
    delegate: FontLoader {
      required property url fileUrl
      source: fileUrl
      onStatusChanged: if (status === FontLoader.Ready) Config.register(name)
    }
  }

  readonly property string shotPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/roselock-desktop.png"
  readonly property string rosewallpapersDir: (Quickshell.env("HOME") || "") + "/.config/rosewallpapers"
  property bool lockReady: false

  Process {
    id: grimProc
    command: ["grim", "-t", "png", "-c", shell.shotPath]
    running: true
    onExited: (code) => {
      if (code !== 0) console.warn("[roselock] grim failed:", code);
      else console.log("[roselock] screenshot:", shell.shotPath);
      shell.lockReady = true;
    }
  }

  Process {
    command: ["qs", "ipc", "-p", shell.rosewallpapersDir, "call", "rosewallpapers", "pause"]
    running: shell.lockReady
  }

  LockContext {
    id: ctx
    onUnlocked: unlockTimer.start()
  }

  Timer {
    id: unlockTimer
    interval: Config.transitionFadeMs + 80
    onTriggered: {
      lock.locked = false;
      resumeWallpaper.running = true;
      quitTimer.start();
    }
  }
  Timer { id: quitTimer; interval: 300; onTriggered: Qt.quit() }

  Process {
    id: resumeWallpaper
    command: ["qs", "ipc", "-p", shell.rosewallpapersDir, "call", "rosewallpapers", "resume"]
    running: false
  }

  WlSessionLock {
    id: lock
    locked: shell.lockReady

    WlSessionLockSurface {
      id: surface
      LockSurface {
        anchors.fill: parent
        context: ctx
        screen: surface.screen
      }
    }
  }
}
