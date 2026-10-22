import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
  id: root

  signal unlocked()
  signal failed()

  property string currentText: ""
  property bool unlockInProgress: false
  property bool showFailure: false
  property bool unlocking: false

  onCurrentTextChanged: if (currentText !== "") showFailure = false

  function tryUnlock() {
    if (currentText === "" || unlockInProgress || unlocking) return;
    unlockInProgress = true;
    pam.start();
  }

  PamContext {
    id: pam
    configDirectory: "pam"
    config: "password.conf"

    onPamMessage: {
      if (pam.responseRequired)
        pam.respond(root.currentText);
    }

    onCompleted: result => {
      root.unlockInProgress = false;
      if (result === PamResult.Success) {
        root.unlocking = true;
        root.unlocked();
      } else {
        root.currentText = "";
        root.showFailure = true;
        root.failed();
      }
    }
  }
}
