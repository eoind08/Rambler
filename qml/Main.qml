import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 1000
    height: 640
    visible: true
    title: "Rambler"
    color: Theme.bg
    BookModel { id: books }
    EntryModel { id: entries }

    function openBook(row) {
        sidebar.currentIndex = row
        entries.bookPath = books.pathAt(row)
        Qt.callLater(timeline.positionViewAtEnd)
    }

    Component.onCompleted: openBook(0)

    Connections {
        target: books
        function oneErrorOccurred(message) { sidebar.errorText = message }
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Sidebar {
            id: sidebar
            model: books
            Layout.preferredWidth: 260
            Layout.fillHeight: true

            onBookClicked: (row) => openBook(row)
            onCreateRequested: (name) => {
                const row = books.createBook(name)
                if (row >= 0) openBook(row)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

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
            Composer {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.cardLeft        // lines up with the cards
                Layout.rightMargin: Theme.pageMargin
                Layout.topMargin: 8
                Layout.bottomMargin: 24

                onSubmitted: (text) => {
                    if (entries.addEntry(text))
                        Qt.callLater(timeline.positionViewAtEnd)
                }
            }
        }
    }
}