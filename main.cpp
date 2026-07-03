#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ttsmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    TtsManager ttsManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("ttsManager", &ttsManager);
    engine.load(QUrl(QStringLiteral("qrc:/Translator/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
