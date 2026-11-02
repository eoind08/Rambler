#include "bookmodel.h"
#include <QRegularExpression>
#include <QStandardPaths>

BookModel::BookModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QString docs = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_root.setPath(docs + "/Rambler/user");
    QDir().mkpath(m_root.absolutePath());

    const auto filters = QDir::Dirs | QDir::NoDotAndDotDot;
    if (m_root.isEmpty(filters))
        m_root.mkdir("Personal");

    for (const QString &name : m_root.entryList(filters, QDir::Name | QDir::IgnoreCase))
        m_books.append(Book{name, m_root.filePath(name)});
}

int BookModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_books.size();
}

QVariant BookModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_books.size())
        return {};
    const Book &b = m_books[index.row()];
    switch (role) {
    case NameRole: return b.name;
    case PathRole: return b.path;
    }
    return {};
}

QHash<int, QByteArray> BookModel::roleNames() const
{
    return {{NameRole, "name"}, {PathRole, "path"}};
}

QString BookModel::pathAt(int row) const
{
    return (row >= 0 && row < m_books.size()) ? m_books[row].path : QString();
}

int BookModel::createBook(const QString &rawName)
{
    static const QRegularExpression bad(
        R"re([<>:"/\\|?*\x00-\x1f]|\.$|^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$)re",
        QRegularExpression::CaseInsensitiveOption);

    const QString name = rawName.trimmed();
    if (name.isEmpty() || bad.match(name).hasMatch()) {
        emit errorOccurred(tr("That name can't be used for a folder."));
        return -1;
    }
    if (m_root.exists(name)) {
        emit errorOccurred(tr("A book with that name already exists."));
        return -1;
    }
    if (!m_root.mkdir(name)) {
        emit errorOccurred(tr("Couldn't create the folder."));
        return -1;
    }
    int pos = 0;
    while (pos < m_books.size()
           && QString::compare(m_books[pos].name, name, Qt::CaseInsensitive) < 0)
        ++pos;

    beginInsertRows({}, pos, pos);
    m_books.insert(pos, Book{name, m_root.filePath(name)});
    endInsertRows();
    return pos;
}