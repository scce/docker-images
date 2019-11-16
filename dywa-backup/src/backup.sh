#!/bin/bash
# Basic Configuration
export XDG_CACHE_HOME=$(eval echo ~$(whoami)/.cache/)

##set -e

RESTIC_REPO=${ENV_RESTIC_REPO_URL}
DYWA_APP_LOGS_PATH=${ENV_DYWA_APP_LOGS_PATH}

RESTIC_EXECUTABLE=/usr/local/bin/restic
RESTIC_PASSWORD_FILE=/root/.repository-password

WILDFLY_STANDALONE_PATH=/opt/jboss/wildfly/standalone
WILDFLY_FILES_PATH=${WILDFLY_STANDALONE_PATH}/data/files

PGDUMP_SQL_FILE=pgdump.sql
TEMP_BACKUP_FOLDER=/home/root//.__BACKUP_/
BACKUP_REVISION_TO_RESTORE=

# wrapper for restic call
function runRestic() {
  ${RESTIC_EXECUTABLE} -r ${RESTIC_REPO} --password-file ${RESTIC_PASSWORD_FILE} "$@"
}

# initialize repository
function doInit() {
  if [ ${forceInit} -eq 1 ]; then
    echo "forcefully creating restic repository at ${RESTIC_REPO}, initializing ..."
    REPOSITORY_BACKUP=$(echo ${RESTIC_REPO} | sed -e 's;/$;;')
    if testIt -e ${RESTIC_REPO}; then
      if testIt -e ${REPOSITORY_BACKUP}.bak; then
        i=0
        while testIt -e ${REPOSITORY_BACKUP}-${i}.bak; do
          let i++
        done
        REPOSITORY_BACKUP=${REPOSITORY_BACKUP}-${i}
      fi
      echo "Creating backup of previous installed repository at ${REPOSITORY_BACKUP}.bak ..."
      move ${RESTIC_REPO} ${REPOSITORY_BACKUP}.bak
    fi
    runRestic init
    return 0
  fi
  if ! testIt -d ${RESTIC_REPO}; then
    (echo >&2 "no restic repository found at ${RESTIC_REPO}, initializing ...")
    runRestic init
  else
    (echo -e >&2 "restic repository already found at ${RESTIC_REPO}!\nUse --force-init to override existing repository")
  fi
}

# perform check on repository
function doCheck() {
  if [ ${checkData} -eq 1 ]; then
    runRestic check --read-data
  else
    runRestic check
  fi
  return $?
}

# perform installation verification
function doInstallVerification() {
  if [[ ! -x ${RESTIC_EXECUTABLE} ]]; then
    (echo >&2 "restic executable not found.")
    return 127
  fi
  if [[ ! -f ${RESTIC_PASSWORD_FILE} ]]; then
    (echo >&2 "restic passwordfile not found.")
    return 240
  fi
  if [ ${init} -ne 1 ] && ! testIt -d ${RESTIC_REPO}; then
    (echo >&2 "no repository found at ${RESTIC_REPO}! Did you initialize the repository? ($0 init)")
    return 1
  fi
  return 0
}

# perform actual backup
function doBackup() {
  BACKUPTAG=$1
  mkdir -p ${TEMP_BACKUP_FOLDER}
  /usr/bin/pg_dump dywa >${TEMP_BACKUP_FOLDER}/${PGDUMP_SQL_FILE}
  runRestic backup ${TEMP_BACKUP_FOLDER}/${PGDUMP_SQL_FILE} ${WILDFLY_FILES_PATH} ${DYWA_APP_LOGS_PATH} --tag AIO --tag "${BACKUPTAG}"
}

# interactive restore
function doRestore() {
  checkForRestore

  TAG="complete"
  if [ ${revertRestore} -eq 1 ]; then
    TAG="preRestore"
  fi

  doBackup preRestore
  rm ${TEMP_BACKUP_FOLDER} -rf --preserve-root
  runRestic restore ${BACKUP_REVISION_TO_RESTORE} --tag AIO,${TAG} --target / && /usr/bin/psql --single-transaction --variable=ON_ERROR_STOP=1 dywa <${TEMP_BACKUP_FOLDER}/${PGDUMP_SQL_FILE} && echo "Restore done."
  rm ${TEMP_BACKUP_FOLDER} -rf --preserve-root
}

# interactive
function checkForRestore() {
  if [ ${yes} -eq 0 ]; then
    read -e -t 10 -n1 -p "Restoring backup results in removal of existing state. Continue? [y/n]" resume
    case $resume in
    y | Y | J | j\n) echo ;;
    *) exit 1 ;;
    esac
  fi

  if systemctl is-active --quiet wildfly.service; then
    read -e -t 10 -n1 -p "You should stop the wildfly service prior to restoring. Continue anyhow?[y/n]" resume
    case $resume in
    y | Y | J | j\n) echo ;;
    *) exit 1 ;;
    esac ## check if wildfly is off soft error
  fi

  /usr/bin/pg_dump dywa &>/dev/null || (echo postgres service must run on restore exiting ... && exit 1) ## postgres has to run in order to get restore working
}

# perform cleanup
function doCleanup() {
  runRestic forget --keep-last 12 --keep-daily 3 --keep-weekly 3 --keep-monthly 1 --keep-yearly 1 --prune
}

function printHelp() {

  echo "
Performs backup and restore operations on specified backup repository.
  Operations:
  -i, --init                  Initialize a new backup repository, operation is idempotent unless --force-init flag is set.
  -b, --backup                Create a new backup for database,wildfly files and logs.
  -c, --cleanup               Removes no longer needed snapshots.
  -C, --check                 Checks the underlying backup repository for consistency.
  -h, --help                  Prints this help text.
  -s, --snapshots             Lists all existing snapshots of given repository.
  -r, --restore [#revision]   restore #revision, if none given restore latest snapshot, see also --revert-restore.
  Flags:
  --revert-restore            Undoes the previous restore operation.
  --force-init                Initilize a new repository even if a valid repository exists.
                              A backup of the overwritten repository is created.
  --check-data                Also check repository data files for inconsistencies.
  -y, --yes                   Answer prompts directly with yes

At least one operation must be given."

}

# execute test command on local/remote host
function testIt() {
  if [ $# -eq 2 ]; then
    if [ "${2#sftp:}" != "${2}" ]; then
      local HOST=$(echo "${2}" | cut -d':' -f2)
      local TARGETPATH=$(echo "${2}" | cut -d':' -f3)
      ssh -q ${HOST} [ "${1}" "${TARGETPATH}" ]
      return $?
    else
      [ ${1} "${2}" ]
      return $?
    fi
  fi
  return -6
}

# execute mv command on local/remote host
function move() {
  if [ $# -eq 2 ]; then
    if [ "${2#sftp:}" != "${2}" ]; then
      HOST=$(echo "${2}" | cut -d':' -f2)
      TARGETPATH=$(echo "${2}" | cut -d':' -f3)
      SOURCEPATH=$(echo "${1}" | cut -d':' -f3)
      ssh -q ${HOST} mv "${SOURCEPATH}" "${TARGETPATH}"
      return $?
    else
      mv "${1}" "${2}"
      return $?
    fi
  fi
  return -6
}

## main starts here

init=0
backup=0
clean=0
forceInit=0
check=0
checkData=0
revertRestore=0
snapshots=0
restore=0
yes=0
until [ "x${1}" == "x" ]; do
  case ${1} in
  "-i" | "--init")
    init=1
    ;;
  "--force-init")
    forceInit=1
    ;;
  "-b" | "--backup")
    backup=1
    ;;
  "-c" | "--cleanup")
    clean=1
    ;;
  "-C" | "--check")
    check=1
    ;;
  "-h" | "--help")
    printHelp
    ;;
  "--revert-restore")
    revertRestore=1
    ;;
  "-s" | "--snapshots")
    snapshots=1
    ;;
  "--check-data")
    checkData=1
    ;;
  "-y" | "--yes")
    yes=1
    ;;
  "-r" | "--restore")
    shift
    if [ "x${BACKUP_REVISION_TO_RESTORE}" == "x" -a ${revertRestore} -eq 0 ]; then
      if [ "x${1}" == "x" ]; then
        echo "No revision for restoring given, restoring latest version."
        BACKUP_REVISION_TO_RESTORE="latest"
      else
        BACKUP_REVISION_TO_RESTORE=${1}
      fi
      restore=1
    else
      echo "Only one revision for restoration is accepted."
      exit 1
    fi
    ;;
  esac
  # Go to next parameter
  shift
done
doInstallVerification

STATUS=$?
[[ ${STATUS} > 0 ]] && exit ${STATUS}

if [ ${restore} -eq 1 ]; then doRestore; fi
if [ ${init} -eq 1 ]; then doInit; fi
if [ ${snapshots} -eq 1 ]; then runRestic snapshots; fi
if [ ${backup} -eq 1 ]; then doBackup "complete"; fi
if [ ${clean} -eq 1 ]; then doCleanup; fi
if [ ${check} -eq 1 ]; then doCheck; fi
