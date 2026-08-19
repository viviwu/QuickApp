#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 设置组织名/应用名：QML 端的 Settings（见 TechniquesLab.qml）和 C++ 的
    // QSettings 都要靠这两个名字定位持久化文件的存放位置。
    // 没设置的话会落到一个基于可执行文件名的默认位置，位置不固定、不推荐。
    app.setOrganizationName(QStringLiteral("QuickApp"));
    app.setApplicationName(QStringLiteral("QuickApp"));

    // 用 Fusion 而不是平台原生样式：LoginDialog 里给 TextField 自定义的
    // background（红色错误边框）在原生 macOS 样式下会被忽略，Fusion 支持。
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    QQmlApplicationEngine engine;

    // 注意：这里没有手动 setContextProperty("appController", ...)，
    // 因为 AppController 用了 QML_SINGLETON，由 qt_add_qml_module 自动注册，
    // QML 端直接 `import QuickApp` 后用类型名 `AppController` 当全局单例访问。
    // 如果你更习惯显式注入实例（比如要传构造参数、要在多个 engine 间共享同一实例），
    // 也可以去掉 QML_SINGLETON，改用 engine.rootContext()->setContextProperty(...)。

    engine.loadFromModule("QuickApp", "Main");
    // engine.load(QUrl(u"qrc:/qt/qml/QuickApp/qml/main.qml"_qs));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
