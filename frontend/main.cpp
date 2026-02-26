#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    //Create backend and puts it to QML
    MainWindow backend;
    engine.rootContext()->setContextProperty("backend",&backend);

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/WeatherApp/Main.qml"_s);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [](){QCoreApplication::exit(-1);},
        Qt::QueuedConnection);

    engine.load(url);

    //Fetch data automatically when app starts
    backend.fetchData();

    return app.exec();



}
