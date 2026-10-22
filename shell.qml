import QtQuick
import QtQml
import Quickshell
import Quickshell.Wayland
import Qt.labs.folderlistmodel

ShellRoot {
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

  LockContext {
    id: ctx
    onUnlocked: unlockTimer.start()
  }

  Timer { id: unlockTimer; interval: 620; onTriggered: { lock.locked = false; quitTimer.start(); } }
  Timer { id: quitTimer; interval: 250; onTriggered: Qt.quit() }

  WlSessionLock {
    id: lock
    locked: true

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
