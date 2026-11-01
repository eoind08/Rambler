import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1000
    height: 640
    visible: true
    title: "Rambler"
    color: Theme.bg
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Sidebar {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.bg
        }
    }
}