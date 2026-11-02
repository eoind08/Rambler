#pragma once
#include <QAbstractListModel>
#include <QDateTime>
#include <QtQml/qqmlregistration.h>

class EntryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString bookPath READ bookPath WRITE setBookPath NOTIFY bookPathChanged)

public:
    enum Role { TimestampRole = Qt::UserRole + 1, BodyRole, FileNameRole };

    explicit EntryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString bookPath() const { return m_bookPath; }
    void setBookPath(const QString &path);

    Q_INVOKABLE bool addEntry(const QString &text);

signals:
    void bookPathChanged();

private:
    struct Entry { QString fileName; QDateTime time; QString body; };
    void load();

    QString m_bookPath;
    QList<Entry> m_entries;
};