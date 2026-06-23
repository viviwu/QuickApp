#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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
