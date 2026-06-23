#include "authservice.h"

#include <QTimer>

AuthService::AuthService(QObject *parent)
    : QObject(parent)
{
}

void AuthService::login(const QString &username, const QString &password)
{
    // 关键点：login() 本身不阻塞，立即返回。
    // 用 QTimer::singleShot 模拟"发出请求 -> 等待网络 -> 收到响应"的异步过程。
    // 真实场景中这一段会替换为 QNetworkAccessManager::post(...) 之类的调用，
    // 在其 finished 信号的 lambda 里做下面同样的判断和 emit。
    QTimer::singleShot(800, this, [this, username, password]() {
        if (verifyCredentials(username, password)) {
            emit loginSucceeded(username);
        } else {
            emit loginFailed(QStringLiteral("用户名或密码错误"));
        }
    });
}

bool AuthService::verifyCredentials(const QString &username, const QString &password) const
{
    // 仅用于演示：真实项目里这里应该是检查后端返回的 HTTP 状态码 / token 等。
    return !username.isEmpty() && password == QStringLiteral("1234");
}
