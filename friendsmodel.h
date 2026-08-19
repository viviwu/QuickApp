#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QString>
#include <QVector>
#include <qqml.h>

// FriendsModel 提供好友列表数据（QAbstractListModel），QML 端直接用
// `FriendsModel {}` 作为 ListView 的 model，delegate 里访问
// model.name / model.status / model.avatarColor / model.bio。
class FriendsModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Role {
        NameRole = Qt::DisplayRole,   // "name"
        StatusRole = Qt::UserRole + 1,   // "status"
        AvatarColorRole,                // "avatarColor"
        BioRole,                        // "bio"
    };
    Q_ENUM(Role)

    explicit FriendsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    struct Friend {
        QString name;
        QString status;
        QString avatarColor;
        QString bio;
    };
    QVector<Friend> m_friends;
};