import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1000
    height: 640
    visible: true
    title: "Rambler"
    color: Theme.bg
    ListModel {
        id: entries
        ListElement { timestamp: "30 Oct 20:45"; body: "Hello **World**!" }
        ListElement { timestamp: "31 Oct 13:17"; body: "Here's a second one" }
        ListElement { timestamp: "31 Oct 14:32"; body: "And a third for good _Luck_" }
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Sidebar {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: Theme.surface
        }
        ListView {
            id: timeline
            Layout.fillWidth: true
            Layout.fillHeight: true
            topMargin: 24
            bottomMargin: 24
            clip: true
            model: entries
            delegate: EntryCard {
                required property int index
                width: ListView.view.width
                isFirst: index === 0
                isLast: index === ListView.view.count - 1
            }
        }
    }
}