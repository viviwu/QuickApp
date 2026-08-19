#pragma once

#include <QElapsedTimer>
#include <QObject>
#include <qqml.h>

class QTimer;

// UsageTracker 记录 App 使用时长，超过休息阈值后发出 restReminderTriggered 信号。
// 作为 QML 单例暴露给 QML：任何页面 `import QuickApp` 后都能拿到同一个实例，
// 不关心是哪个页面在计时，与登录状态无关。
class UsageTracker : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // 已持续使用秒数，MainWindow 可以实时显示"本次使用 N 秒"
    Q_PROPERTY(qint64 elapsedSeconds READ elapsedSeconds NOTIFY elapsedSecondsChanged)
    // 休息阈值（秒），方便测试时临时改小（默认 300 = 5 分钟）
    Q_PROPERTY(int restThresholdSeconds READ restThresholdSeconds WRITE setRestThresholdSeconds NOTIFY restThresholdSecondsChanged)

public:
    explicit UsageTracker(QObject *parent = nullptr);

    qint64 elapsedSeconds() const { return m_elapsedSeconds; }
    int restThresholdSeconds() const { return m_restThresholdSeconds; }
    void setRestThresholdSeconds(int secs);

    // 开始/停止计时。进入主界面时 start()，退出登录时 stop()。
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void reset();

signals:
    void elapsedSecondsChanged();
    void restThresholdSecondsChanged();
    void restReminderTriggered();

private:
    QElapsedTimer m_timer;
    QTimer *m_clock = nullptr;
    qint64 m_elapsedSeconds = 0;
    int m_restThresholdSeconds = 300;
};