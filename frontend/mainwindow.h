#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class MainWindow : public QObject
{
    Q_OBJECT

    // C++ Weather properties in QML
    Q_PROPERTY(QString city READ city NOTIFY dataChanged)
    Q_PROPERTY(QString temperature READ temperature NOTIFY dataChanged)
    Q_PROPERTY(QString condition READ condition NOTIFY dataChanged)
    Q_PROPERTY(QString description READ description NOTIFY dataChanged)
    Q_PROPERTY(QString humidity READ humidity NOTIFY dataChanged)
    Q_PROPERTY(QString feelsLike READ feelsLike NOTIFY dataChanged)
    Q_PROPERTY(QString suggestion READ suggestion NOTIFY dataChanged)
    Q_PROPERTY(QVariantList events READ events NOTIFY dataChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)


public:
    explicit MainWindow(QObject *parent = nullptr); //constructor -> *parent = nullptr to avoid memory leaks

    //Getters
    QString city() const {return m_city;}
    QString temperature() const {return m_temperature;}
    QString condition() const{return m_condition;}
    QString description() const {return m_description;}
    QString humidity() const{ return m_humidity;}
    QString feelsLike() const { return m_feelsLike; }
    QString suggestion() const { return m_suggestion; }
    QVariantList events() const { return m_events; }
    bool loading() const { return m_loading; }

    Q_INVOKABLE void fetchData(); //bridge between c++ and qml


    ~MainWindow();

signals:
    void dataChanged();
    void loadingChanged();

private slots:
    void onDataReceived(QNetworkReply *reply); // contains the data from Flask in JSON

private:

    QNetworkAccessManager *m_manager; // this will call our flask flask server

    QString m_city;
    QString m_temperature;
    QString m_condition;
    QString m_description;
    QString m_humidity;
    QString m_feelsLike;
    QString m_suggestion;
    QVariantList m_events;
    bool m_loading = false;


};
#endif // MAINWINDOW_H
