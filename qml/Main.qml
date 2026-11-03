import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 1000
    height: 640
    minimumHeight: 520
    minimumWidth: 820
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
    function deleteBook(row) {
        const wasCurrent = row === sidebar.currentIndex
        if (!books.deleteBook(row))
            return
        sidebar.closeEditor()
        if (books.count === 0) {    
            sidebar.currentIndex = -1
            entries.bookPath = ""
        } else if (wasCurrent) {  
            openBook(Math.min(row, books.count - 1))
        } else {                                    
            sidebar.currentIndex = books.rowOfPath(entries.bookPath)
        }
    }
    function renameBook(row, name) {
        const wasCurrent = row === sidebar.currentIndex
        const newRow = books.renameBook(row, name)
        if (newRow < 0)
            return
        sidebar.closeEditor()

        if (wasCurrent)
            openBook(newRow)            
        else
            sidebar.currentIndex = books.rowOfPath(entries.bookPath)
    }
    Component.onCompleted: {
        if (books.count > 0)
            openBook(0)
    }
    Connections {
        target: books
        function onErrorOccurred(message) { sidebar.errorText = message }
    }
    ConfirmDialog {
        id: deleteDialog
        property int row: -1
        message: "The book and everything in it will be moved to the Recycle Bin."
        confirmText: "Delete"
        onConfirmed: window.deleteBook(row)
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Sidebar {
            id: sidebar
            model: books
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            onBookClicked: (row) => {
                closeEditor()
                window.openBook(row)
            }
            onCreateRequested: (name) => {
                const row = books.createBook(name)
                if (row >= 0) {
                    closeEditor()
                    window.openBook(row)
                }
            }
            onRenameRequested: (row, name) => window.renameBook(row, name)
            onDeleteRequested: (row, name) => {
                deleteDialog.row = row
                deleteDialog.title = 'Delete "' + name + '"?'
                deleteDialog.open()
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
                    bottomMargin: 8
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
                    anchors.fill: parent
                    opacity: books.count > 0 && timeline.count === 0 ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "What's on your mind?"
                            color: Theme.editorText
                            font.family: Theme.serif
                            font.pixelSize: 22
                        }
                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: "qrc:/qt/qml/Rambler/assets/arrow-down.svg"
                            sourceSize: Qt.size(48, 48)
                        }
                    }
                }
                Item {
                    id: noBooksState
                    anchors.fill: parent
                    visible: books.count === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Create your first book"
                            color: Theme.editorText
                            font.family: Theme.serif
                            font.pixelSize: 22
                        }

                        PlusButton {
                            Layout.alignment: Qt.AlignHCenter
                            size: 36
                            onClicked: sidebar.startCreating()
                        }
                    }
                }
            }

            Composer {
                visible: books.count > 0
                Layout.fillWidth: true
                Layout.leftMargin: Theme.cardLeft
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