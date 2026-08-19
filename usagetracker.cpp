#include "usagetracker.h"

#include <QTimer>

UsageTracker::UsageTracker(QObject *parent)
    : QObject(parent)
{
    // 每秒刷新一次 elapsedSeconds，并检查是否越过休息阈值
    m_clock = new QTimer(this);
    m_clock->setInterval(1000);
    connect(m_clock, &QTimer::timeout, this, [this]() {
        m_elapsedSeconds = static_cast<qint64>(m_timer.elapsed() / 1000);
        emit elapsedSecondsChanged();

        if (m_elapsedSeconds > 0 && m_elapsedSeconds % m_restThresholdSeconds == 0)
            emit restReminderTriggered();
    });
}

void UsageTracker::setRestThresholdSeconds(int secs)
{
    if (secs <= 0)
        return;
    if (m_restThresholdSeconds == secs)
        return;
    m_restThresholdSeconds = secs;
    emit restThresholdSecondsChanged();
}

void UsageTracker::start()
{
    m_timer.start();
    m_clock->start();
}

void UsageTracker::stop()
{
    m_clock->stop();
}

void UsageTracker::reset()
{
    stop();
    m_elapsedSeconds = 0;
    emit elapsedSecondsChanged();
}