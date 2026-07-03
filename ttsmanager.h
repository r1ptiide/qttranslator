#ifndef TTSMANAGER_H
#define TTSMANAGER_H

#include <QObject>
#include <QProcess>

class TtsManager : public QObject
{
    Q_OBJECT
public:
    explicit TtsManager(QObject *parent = nullptr);

    Q_INVOKABLE void speak(const QString &text);

private:
    QProcess *process;
};

#endif // TTSMANAGER_H
