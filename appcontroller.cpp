#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject(parent)
{
    // AppController 在构造时把自己"接在" AuthService 的异步结果上。
    // 这条连线是整个登录流程异步通知的关键：
    // AuthService 跑完计时器/网络请求后 emit 的信号，
    // 在这里被翻译成 AppController 对外的状态变化和信号。
    connect(&m_authService, &AuthService::loginSucceeded, this,
            [this](const QString &username) {
                setBusy(false);
                setCurrentUser(username);
                setLoggedIn(true);
            });

    connect(&m_authService, &AuthService::loginFailed, this,
            [this](const QString &reason) {
                setBusy(false);
                emit loginFailed(reason);
            });
}

void AppController::login(const QString &username, const QString &password)
{
    if (m_busy) {
        // 防止用户连续点击登录按钮发出重复请求
        return;
    }
    setBusy(true);
    m_authService.login(username, password);
}

void AppController::logout()
{
    setLoggedIn(false);
    setCurrentUser(QString());
}

void AppController::setBusy(bool busy)
{
    if (m_busy == busy)
        return;
    m_busy = busy;
    emit busyChanged();
}

void AppController::setLoggedIn(bool loggedIn)
{
    if (m_loggedIn == loggedIn)
        return;
    m_loggedIn = loggedIn;
    emit loggedInChanged();
}

void AppController::setCurrentUser(const QString &user)
{
    if (m_currentUser == user)
        return;
    m_currentUser = user;
    emit currentUserChanged();
}
