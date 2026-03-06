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

    Q_PROPERTY(QString city READ city NOTIFY dataChanged)
    Q_PROPERTY(QString temperature READ temperature NOTIFY dataChanged)
    Q_PROPERTY(QString description READ description NOTIFY dataChanged)
    Q_PROPERTY(QString humidity READ humidity NOTIFY dataChanged)
    Q_PROPERTY(QString feelsLike READ feelsLike NOTIFY dataChanged)
    Q_PROPERTY(QString suggestion READ suggestion NOTIFY dataChanged)
    Q_PROPERTY(QVariantList hourlyForecast READ hourlyForecast NOTIFY dataChanged)
    Q_PROPERTY(QVariantList events READ events NOTIFY dataChanged)
    Q_PROPERTY(QString summary READ summary NOTIFY dataChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString chatResponse READ chatResponse NOTIFY chatResponseChanged)
    Q_PROPERTY(bool chatLoading READ chatLoading NOTIFY chatLoadingChanged)

public:
    explicit MainWindow(QObject *parent = nullptr);

    // Getters
    QString city() const { return m_city; }
    QString temperature() const { return m_temperature; }
    QString description() const { return m_description; }
    QString humidity() const { return m_humidity; }
    QString feelsLike() const { return m_feelsLike; }
    QString suggestion() const { return m_suggestion; }
    QVariantList hourlyForecast() const { return m_hourlyForecast; }
    QVariantList events() const { return m_events; }
    QString summary() const { return m_summary; }
    bool loading() const { return m_loading; }
    QString chatResponse() const { return m_chatResponse; }
    bool chatLoading() const { return m_chatLoading; }

    Q_INVOKABLE void fetchData();
    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void dataChanged();
    void loadingChanged();
    void chatResponseChanged();
    void chatLoadingChanged();

private slots:
    void onDataReceived(QNetworkReply *reply);
    void onChatResponseReceived(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_manager;
    QString m_city;
    QString m_temperature;
    QString m_description;
    QString m_humidity;
    QString m_feelsLike;
    QString m_suggestion;
    QString m_summary;
    QString m_chatResponse;
    QVariantList m_hourlyForecast;
    QVariantList m_events;
    bool m_loading = false;
    bool m_chatLoading = false;
};

#endif // MAINWINDOW_H
