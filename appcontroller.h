#pragma once

#include <QObject>
#include <QString>
#include <qqml.h>

#include "authservice.h"

// AppController 是 C++ 业务层暴露给 QML 的唯一入口。
// QML 端只通过这个对象的 property / signal / Q_INVOKABLE 与 C++ 通信，
// 不直接接触 AuthService，方便以后替换底层实现而不影响 UI。
class AppController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // 登录是否正在进行中，用于 LoginDialog 显示 loading / 禁用按钮
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    // 登录成功后置 true，Main.qml 据此切换到 MainWindow
    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY loggedInChanged)
    // 当前登录用户名，登录成功后 MainWindow 可以显示欢迎信息
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY currentUserChanged)

public:
    explicit AppController(QObject *parent = nullptr);

    bool busy() const { return m_busy; }
    bool loggedIn() const { return m_loggedIn; }
    QString currentUser() const { return m_currentUser; }

    // 供 LoginDialog 的登录按钮调用
    Q_INVOKABLE void login(const QString &username, const QString &password);

    // 供 MainWindow 的"退出登录"调用（顺手补上，方便完整体验一次状态切换）
    Q_INVOKABLE void logout();

signals:
    // 登录失败时单独发出，LoginDialog 监听这个信号来清空密码框 + 显示错误提示
    // 故意不用 errorChanged 这种"属性变化"信号，因为同一个错误信息可能连续出现两次
    // （比如连续两次输错密码），属性绑定不会重复触发，专门用 signal 更可靠。
    void loginFailed(const QString &reason);

    void busyChanged();
    void loggedInChanged();
    void currentUserChanged();

private:
    void setBusy(bool busy);
    void setLoggedIn(bool loggedIn);
    void setCurrentUser(const QString &user);

    AuthService m_authService;
    bool m_busy = false;
    bool m_loggedIn = false;
    QString m_currentUser;
};
