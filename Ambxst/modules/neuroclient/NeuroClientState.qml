// modules/neuroclient/NeuroClientState.qml

pragma Singleton

import QtQuick

QtObject {

    property bool open: false   // ← было visible

    function toggle() {
        open = !open
        console.log("NeuroClientState open =", open)
    }
}