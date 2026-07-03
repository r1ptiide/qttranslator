#include "ttsmanager.h"
#include <QDebug>

TtsManager::TtsManager(QObject *parent) : QObject(parent)
{
    process = new QProcess(this);
}

void TtsManager::speak(const QString &text)
{
    if (text.isEmpty())
        return;

    QString command = QString(
                          "Add-Type -AssemblyName System.Speech; "
                          "$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; "
                          "$speak.Speak('%1')"
                          ).arg(text);

    process->start("powershell", QStringList() << "-Command" << command);
}
