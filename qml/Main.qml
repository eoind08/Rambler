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
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView {
                    id: timeline
                    anchors.fill: parent
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

                Item {
                    id: emptyState
                    anchors.fill: timeline
                    visible: timeline.count === 0 ? 1: 0
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 30
                        Text {
                            text: "What's on your mind?"
                            font.family: Theme.serif
                            font.pixelSize: 32
                            color: Theme.editorText
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Image {
                            source: "qrc:/qt/qml/Rambler/assets/arrow-down.svg"
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            sourceSize: Qt.size(56,56)
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
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