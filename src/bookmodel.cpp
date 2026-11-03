#include "bookmodel.h"
#include <QFile>
#include <QRegularExpression>
#include <QStandardPaths>

namespace {
// rejects empty names, illegal characters, trailing dot, Windows reserved names
bool validName(const QString &name)
{
    static const QRegularExpression bad(
        R"re([<>:"/\\|?*\x00-\x1f]|\.$|^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$)re",
        QRegularExpression::CaseInsensitiveOption);
    return !name.isEmpty() && !bad.match(name).hasMatch();
}
}

BookModel::BookModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QString docs = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    m_root.setPath(docs + "/Rambler/user");
    QDir().mkpath(m_root.absolutePath());

    const auto filters = QDir::Dirs | QDir::NoDotAndDotDot;
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

int BookModel::rowOfPath(const QString &path) const
{
    for (int i = 0; i < m_books.size(); ++i)
        if (m_books[i].path == path)
            return i;
    return -1;
}

int BookModel::sortedPos(const QString &name) const
{
    int pos = 0;
    while (pos < m_books.size()
           && QString::compare(m_books[pos].name, name, Qt::CaseInsensitive) < 0)
        ++pos;
    return pos;
}

int BookModel::createBook(const QString &rawName)
{
    const QString name = rawName.trimmed();
    if (!validName(name)) {
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
    const int pos = sortedPos(name);
    beginInsertRows({}, pos, pos);
    m_books.insert(pos, Book{name, m_root.filePath(name)});
    endInsertRows();
    emit countChanged();
    return pos;
}
int BookModel::renameBook(int row, const QString &rawName)
{
    if (row < 0 || row >= m_books.size())
        return -1;

    const QString name = rawName.trimmed();
    const QString oldName = m_books[row].name;

    if (name == oldName)   
        return row;
    if (!validName(name)) {
        emit errorOccurred(tr("That name can't be used for a folder."));
        return -1;
    }
    const bool caseOnly = name.compare(oldName, Qt::CaseInsensitive) == 0;
    if (!caseOnly && m_root.exists(name)) {
        emit errorOccurred(tr("A book with that name already exists."));
        return -1;
    }
    if (!m_root.rename(oldName, name)) {
        emit errorOccurred(tr("Couldn't rename the folder. Is it open in another program?"));
        return -1;
    }

    beginRemoveRows({}, row, row);
    m_books.removeAt(row);
    endRemoveRows();

    const int pos = sortedPos(name);
    beginInsertRows({}, pos, pos);
    m_books.insert(pos, Book{name, m_root.filePath(name)});
    endInsertRows();
    return pos; 
}

bool BookModel::deleteBook(int row)
{
    if (row < 0 || row >= m_books.size())
        return false;
    if (!QFile::moveToTrash(m_books[row].path)) {
        emit errorOccurred(tr("Couldn't move the book to the Recycle Bin."));
        return false;
    }
    beginRemoveRows({}, row, row);
    m_books.removeAt(row);
    endRemoveRows();
    emit countChanged();
    return true;
}