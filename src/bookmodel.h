#pragma once
#include <QAbstractListModel>
#include <QDir>
#include <QtQml/qqmlregistration.h>

class BookModel : public QAbstractListModel
{
    Q_OBJECT 
    QML_ELEMENT
    Q_PROPERTY(QString rootPath READ rootPath CONSTANT)

public:
    enum Role { NameRole = Qt::UserRole + 1, PathRole };

    explicit BookModel(QObject *parent = nullptr);

    // the three functions every list model must provide
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString rootPath() const { return m_root.absolutePath(); }

    Q_INVOKABLE QString pathAt(int row) const;
    Q_INVOKABLE int createBook(const QString &name);

signals:
    void errorOccurred(const QString &message);

private:
    struct Book { QString name; QString path; };
    QDir m_root;
    QList<Book> m_books;
};