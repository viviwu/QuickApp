#include "friendsmodel.h"

FriendsModel::FriendsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_friends = {
        { QStringLiteral("张伟"),  QStringLiteral("在线"),   QStringLiteral("#e57373"),
          QStringLiteral("热爱摄影与旅行，周末经常约朋友爬山。") },
        { QStringLiteral("李娜"),  QStringLiteral("离开"),   QStringLiteral("#64b5f6"),
          QStringLiteral("前端工程师，最近在学 Rust。") },
        { QStringLiteral("王芳"),  QStringLiteral("忙碌"),   QStringLiteral("#81c784"),
          QStringLiteral("产品经理，喜欢研究 AI 工具。") },
        { QStringLiteral("刘强"),  QStringLiteral("在线"),   QStringLiteral("#ffb74d"),
          QStringLiteral("户外爱好者，马拉松选手。") },
        { QStringLiteral("陈静"),  QStringLiteral("离线"),   QStringLiteral("#9575cd"),
          QStringLiteral("插画师，日常发布手绘练习。") },
        { QStringLiteral("杨洋"),  QStringLiteral("在线"),   QStringLiteral("#4dd0e1"),
          QStringLiteral("开源贡献者，擅长 Qt 与嵌入式。") },
    };
}

int FriendsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_friends.size();
}

QVariant FriendsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_friends.size())
        return {};
    const Friend &f = m_friends.at(index.row());
    switch (role) {
    case NameRole:          return f.name;
    case StatusRole:        return f.status;
    case AvatarColorRole:   return f.avatarColor;
    case BioRole:           return f.bio;
    default:                return {};
    }
}

QHash<int, QByteArray> FriendsModel::roleNames() const
{
    // QML delegate 里可以直接用 name / status / avatarColor / bio
    return {
        { NameRole,         "name" },
        { StatusRole,       "status" },
        { AvatarColorRole,  "avatarColor" },
        { BioRole,          "bio" },
    };
}