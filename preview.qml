import QtQuick
import QtQml
import Quickshell
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

  LockContext { id: ctx }

  FloatingWindow {
    title: "macoslock preview"
    color: "black"
    implicitWidth: 1920
    implicitHeight: 1080

    LockSurface {
      anchors.fill: parent
      context: ctx
    }
  }
}
