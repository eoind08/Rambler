#pragma once
#include <QAbstractListModel>
#include <QDir>
#include <QtQml/qqmlregistration.h>

class BookModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString rootPath READ rootPath CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Role { NameRole = Qt::UserRole + 1, PathRole };

    explicit BookModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString rootPath() const { return m_root.absolutePath(); }
    int count() const { return m_books.size(); }

    Q_INVOKABLE QString pathAt(int row) const;
    Q_INVOKABLE int rowOfPath(const QString &path) const;   
    Q_INVOKABLE int createBook(const QString &name);        
    Q_INVOKABLE int renameBook(int row, const QString &name); 
    Q_INVOKABLE bool deleteBook(int row);                   

signals:
    void errorOccurred(const QString &message);
    void countChanged();

private:
    struct Book { QString name; QString path; };
    int sortedPos(const QString &name) const;

    QDir m_root;
    QList<Book> m_books;
};