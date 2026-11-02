#include "entrymodel.h"
#include <QDir>
#include <QFileInfo>
#include <QSaveFile>
#include <QUuid>
#include <algorithm>

namespace {
// 2026-11-02T10-17-33  (19 chars; dashes because ':' is illegal in Windows filenames)
const QString kStamp = QStringLiteral("yyyy-MM-dd'T'HH-mm-ss");
}
EntryModel::EntryModel(QObject *parent)
    : QAbstractListModel(parent)
{
}
int EntryModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_entries.size();
}
QVariant EntryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const Entry &e = m_entries[index.row()];
    switch (role) {
    case TimestampRole: return e.time.toString("d MMM HH:mm");
    case BodyRole:      return e.body;
    case FileNameRole:  return e.fileName;
    }
    return {};
}

QHash<int, QByteArray> EntryModel::roleNames() const
{
    return {{TimestampRole, "timestamp"}, {BodyRole, "body"}, {FileNameRole, "fileName"}};
}

void EntryModel::setBookPath(const QString &path)
{
    if (path == m_bookPath)
        return;
    beginResetModel();
    m_bookPath = path;
    m_entries.clear();
    load();
    endResetModel();
    emit bookPathChanged();
}

void EntryModel::load()
{
    if (m_bookPath.isEmpty())
        return;

    const QFileInfoList files = QDir(m_bookPath).entryInfoList({"*.md"}, QDir::Files, QDir::Name);
    for (const QFileInfo &fi : files) {
        QFile f(fi.absoluteFilePath());
        if (!f.open(QIODevice::ReadOnly))
            continue;

        QDateTime t = QDateTime::fromString(fi.fileName().left(19), kStamp);
        if (!t.isValid())
            t = fi.birthTime().isValid() ? fi.birthTime() : fi.lastModified();

        m_entries.append(Entry{fi.fileName(), t, QString::fromUtf8(f.readAll()).trimmed()});
    }
    std::stable_sort(m_entries.begin(), m_entries.end(),
                     [](const Entry &a, const Entry &b) { return a.time < b.time; });
}

bool EntryModel::addEntry(const QString &text)
{
    const QString body = text.trimmed();
    if (m_bookPath.isEmpty() || body.isEmpty())
        return false;

    const QDateTime now = QDateTime::currentDateTime();
    const QString id = QUuid::createUuid().toString(QUuid::WithoutBraces).left(8);
    const QString fileName = now.toString(kStamp) + '_' + id + ".md";

    QSaveFile file(QDir(m_bookPath).filePath(fileName));
    if (!file.open(QIODevice::WriteOnly))
        return false;
    file.write(body.toUtf8());
    if (!file.commit())
        return false;

    const int row = m_entries.size(); 
    beginInsertRows({}, row, row);
    m_entries.append(Entry{fileName, now, body});
    endInsertRows();
    return true;
}