import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.LocalStorage 2.15

ApplicationWindow {
    id: window
    width: 900
    height: 700
    visible: true
    title: "translator app"
    property var db: null

    Component.onCompleted: {
        initdb()
        load_history()
    }

    function initdb() {
        db = LocalStorage.openDatabaseSync("translations", "1.0", "history", 1000000)
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS translations (id INTEGER PRIMARY KEY AUTOINCREMENT, original TEXT, translated TEXT, source TEXT, target TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)")
        })
    }

    function save_translation(original, translated, src, dst) {
        db.transaction(function(tx) {
            tx.executeSql("INSERT INTO translations (original, translated, source, target) VALUES (?, ?, ?, ?)",
                         [original, translated, src, dst])
        })
        load_history()
    }

    function load_history() {
        history_model.clear()
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT id, original, translated, source, target FROM translations ORDER BY timestamp DESC LIMIT 30")
            for (var i = 0; i < rs.rows.length; i++) {
                var row = rs.rows.item(i)
                history_model.append({
                    dbId: row.id,
                    original: row.original,
                    translated: row.translated,
                    source: row.source,
                    target: row.target
                })
            }
        })
    }

    function delete_translation(id) {
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM translations WHERE id = ?", [id])
        })
        load_history()
    }

    function translate() {
        var text = inputt.text.trim()
        if (!text) return
        var from = srccombo.currentText
        var to = tarcombo.currentText

        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://api.mymemory.translated.net/get?q=" + encodeURIComponent(text) + "&langpair=" + from + "|" + to)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    outputt.text = response.responseData.translatedText
                } else {
                    outputt.text = "помилка при перекладі"
                }
            }
        }
        xhr.send()
    }

    ListModel { id: history_model }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        RowLayout {
            ComboBox { id: srccombo; model: ["en", "uk", "ru", "de", "fr"]; currentIndex: 0 }
            Label { text: ">" }
            ComboBox { id: tarcombo; model: ["uk", "en", "ru", "de", "fr"]; currentIndex: 0 }
            Button { text: "Перекласти"; onClicked: translate() }
            Button { text: "Озвучити"; onClicked: ttsManager.speak(outputt.text) }

            Button {
                id: save_button
                text: "Зберегти"

                contentItem: Text {
                    text: save_button.text
                    font: save_button.font
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (inputt.text && outputt.text) {
                        save_translation(inputt.text, outputt.text, srccombo.currentText, tarcombo.currentText)
                    }
                }
            }
        }

        TextArea {
            id: inputt
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            placeholderText: "Введіть текст..."
            wrapMode: TextArea.Wrap
        }

        TextArea {
            id: outputt
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            readOnly: true
            wrapMode: TextArea.Wrap
        }

        Label { text: "Історія перекладів:" }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: history_model
            spacing: 1

            delegate: Rectangle {
                width: parent.width
                height: 60
                color: index % 2 === 0 ? "#f0f0f0" : "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "[" + model.source + ">" + model.target + "] " + model.original.substring(0, 60)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: model.translated.substring(0, 60)
                            color: "green"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Button {
                        id: delete_button
                        text: "X"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30

                        contentItem: Text {
                            text: delete_button.text
                            font: delete_button.font
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            delete_translation(model.dbId)
                        }
                    }
                }
            }
        }
    }
}
