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
    QNetworkRequest ipRequest;
    ipRequest.setUrl(QUrl("https://api.ipify.org?format=json"));
    QNetworkReply *reply = m_manager->get(ipRequest);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        QString userIp = doc.object()["ip"].toString();
        qDebug() << "User IP detected:" << userIp;  // Debug line
        reply->deleteLater();

        // Now fetch weather with the real IP
        QNetworkRequest request;
        request.setUrl(QUrl("https://wheatherapp-production-5779.up.railway.app/data?ip=" + userIp));
        m_manager->get(request);
    });
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

    //Parse weather forecast
    QJsonObject weather = root["weather"].toObject();
    m_city = weather["city"].toString();
    m_temperature = QString::number(weather["temperature"].toDouble(), 'f', 1) + "°C";
    m_description = weather["description"].toString();
    m_humidity = QString::number(weather["humidity"].toInt()) + "%";
    m_feelsLike = QString::number(weather["feels_like"].toDouble(), 'f', 1) + "°C";
    m_suggestion = weather["suggestion"].toString();


    //Parse hourly forecast

    m_hourlyForecast.clear();
    QJsonArray hourlyArray = weather["hourly_forecast"].toArray();
    for (const QJsonValue &value : hourlyArray) {
        QJsonObject hour = value.toObject();
        QVariantMap hourMap;
        hourMap["time"] = hour["time"].toString();
        hourMap["temp"] = hour["temp"].toString();
        hourMap["description"] = hour["description"].toString();
        m_hourlyForecast.append(hourMap);
    }


    //Parse events data
    m_events.clear();
    QJsonArray eventsArray = root["events"].toArray();
    for (const QJsonValue &value : eventsArray) {
        QJsonObject event = value.toObject();
        QVariantMap eventMap;
        eventMap["title"] = event["title"].toString();
        eventMap["type"] = event["type"].toString();
        eventMap["reason"] = event["reason"].toString();
        eventMap["location"] = event["location"].toString();
        m_events.append(eventMap);
    }

    // Also add summary parsing
    m_summary = root["summary"].toString();

    emit dataChanged();
    reply->deleteLater();

}


void MainWindow::sendMessage(const QString &message)
{
    m_chatLoading = true;
    emit chatLoadingChanged();

    QNetworkRequest request;
    request.setUrl(QUrl("https://wheatherapp-production-5779.up.railway.app/chat"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject weather;
    weather["temperature"] = m_temperature;
    weather["feels_like"] = m_feelsLike;
    weather["description"] = m_description;
    weather["humidity"] = m_humidity;
    weather["suggestion"] = m_suggestion;

    QJsonObject location;
    location["city"] = m_city;

    QJsonObject body;
    body["message"] = message;
    body["weather"] = weather;
    body["location"] = location;

    QNetworkReply *reply = m_manager->post(request, QJsonDocument(body).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onChatResponseReceived(reply);
    });
}

void MainWindow::onChatResponseReceived(QNetworkReply *reply)
{
    m_chatLoading = false;
    emit chatLoadingChanged();

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Chat error:" << reply->errorString();
        reply->deleteLater();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonObject root = doc.object();

    m_chatResponse = root["response"].toString();
    emit chatResponseChanged();
    reply->deleteLater();
}
