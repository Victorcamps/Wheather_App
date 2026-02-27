#include "mainwindow.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>


MainWindow::MainWindow(QObject *parent):QObject(parent){
    m_manager = new QNetworkAccessManager(this);

    connect(m_manager, &QNetworkAccessManager::finished,
            this, &MainWindow::onDataReceived);
}

void MainWindow::fetchData()
{
    m_loading = true;
    emit loadingChanged();

    QNetworkRequest request;
    request.setUrl(QUrl("http://localhost:5000/data"));
    m_manager->get(request);
}

void MainWindow::onDataReceived(QNetworkReply *reply){
    m_loading = false;
    emit loadingChanged();

    if(reply->error() != QNetworkReply::NoError){
        qDebug() << "Network error: " << reply->errorString();
        reply->deleteLater();
        return;
    }

    //Read and Parse JSON data
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonObject root = doc.object();

    QJsonObject weather = root["weather"].toObject();
    m_city = weather["city"].toString();
    m_temperature = QString::number(weather["temperature"].toDouble(),'f',1) + "°C";
    m_condition = weather["condition"].toString();
    m_description = weather["description"].toString();
    m_humidity = QString::number(weather["humidity"].toInt()) + "%";
    m_feelsLike = QString::number(weather["feels_like"].toDouble(), 'f', 1) + "°C";
    m_suggestion = weather["suggestion"].toString();
    m_clouds = QString::number(weather["clouds"].toInt()) + "%";

    //Parse events data
    m_events.clear();

    QJsonArray eventsArray = root["events"].toArray();
    for(const QJsonValue &value:eventsArray){
        QJsonObject event = value.toObject();
        QVariantMap eventMap;
        eventMap["title"] = event["title"].toString();
        eventMap["date"] = event["date"].toString();
        eventMap["location"] = event["location"].toString();
        eventMap["type"] = event["type"].toString();
        m_events.append(eventMap);
    }

    emit dataChanged();
    reply->deleteLater();

}
