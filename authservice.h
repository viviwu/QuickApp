#pragma once

#include <QObject>
#include <QString>

// AuthService 封装"发起登录请求"这件事本身。
// 这里用 QTimer 模拟网络延时；接入真实后端时，
// 把 login() 内部换成 QNetworkAccessManager / gRPC 调用，
// 在收到响应的回调里 emit loginSucceeded / loginFailed 即可，
// 对外接口和信号不需要变。
class AuthService : public QObject
{
    Q_OBJECT

public:
    explicit AuthService(QObject *parent = nullptr);

    // 发起一次异步登录请求。立即返回，结果通过信号通知。
    void login(const QString &username, const QString &password);

signals:
    void loginSucceeded(const QString &username);
    void loginFailed(const QString &reason);

private:
    // 演示用的"假校验"：username 非空 且 password == "1234" 视为成功。
    bool verifyCredentials(const QString &username, const QString &password) const;
};
