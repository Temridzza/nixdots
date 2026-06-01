PanelWindow {
    id: neuroPanel
    anchors {
        top: parent.top
        bottom: parent.bottom
        right: parent.right
    }

    width: 500
    property bool opened: neuroClientState.neuroClientVisible

    x: opened ? parent.width - width : parent.width

    Behavior on x {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Loader {
        id: neuroClientMainLoader
        anchors.fill: parent
        active: true
        source: "/home/temridzza/Documents/NeuroClient/qml/Main.qml"
    }
}