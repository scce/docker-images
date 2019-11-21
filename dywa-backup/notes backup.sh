> export XDG_CACHE_HOME=$(eval echo ~$(whoami)/.cache/)
- Überschreibt die Variable wenn sie vom Benutzer gesetzt wurde
- Ist unnötig, weil Programme diesen Default selber wählen

> ssh -q ${HOST} [ "${1}" "${TARGETPATH}" ]
- Funktioniert nur mit einem Backend das SSH unterstützt

> TEMP_BACKUP_FOLDER=/home/root//.__BACKUP_/
- Lässt sich nicht konfigurieren

> function doInstallVerification() {
- Sind diese Checks wirklich nötig?
