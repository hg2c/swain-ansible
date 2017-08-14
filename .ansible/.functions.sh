#!/usr/bin/env bash
ROOT_DIR=$( cd $CWD && cd .. && pwd)
ENV_DIR=${ROOT_DIR}/environments

BOOK_DIR=${ROOT_DIR}/books
PLAY_DIR=${ROOT_DIR}/plays
PROVIDER_DIR=${ROOT_DIR}/provider
SCRIPT_DIR=${ROOT_DIR}/scripts

ANSIBLE_OPTS=""

usage()
{
    echo "Usage: $0 ENV SUB_COMMAND"
    echo
    echo "  ENV: pick from ${ENV_DIR}"
    ls ${ENV_DIR}
    echo "  SUB_COMMAND: pick from $1"
    ls $1
    echo
    exit 1
}

get_env() {
    if [ -z "$2" ]; then
        echo
        echo "  ERROR: miss arguments"
        echo
        usage $1
    fi

    FIND_ENV=$(ls ${ENV_DIR} | grep $2 | head -n 1)
    if [ -z "${FIND_ENV}" ]; then
        echo ansible-playbook -i ${ENV_DIR}/${2}/hosts
        echo
        echo "  ERROR: ${ENV_DIR}/$2 not exists"
        echo
        usage $1
    fi

    ENV=${FIND_ENV}
}


get_playbook() {
    if [ -z "$2" ]; then
        echo ansible-playbook -i ${ENV_DIR}/${FIND_ENV}/hosts
        echo
        echo "  ERROR: miss sub_command"
        echo
        usage $1
    fi

    FIND_PLAYBOOK=$(ls $1 | grep $2 | head -n 1)

    if [ -z "${FIND_PLAYBOOK}" ]; then
        echo ansible-playbook -i ${ENV_DIR}/${FIND_ENV}/hosts $2
        echo
        echo "  ERROR: $1/$2 not exists"
        echo
        usage $1
    fi

    PLAYBOOK=$1/${FIND_PLAYBOOK}

    echo ansible-playbook -i ${ENV_DIR}/${FIND_ENV}/hosts $PLAYBOOK ${ANSIBLE_OPTS}
    ansible-playbook -i ${ENV_DIR}/${FIND_ENV}/hosts $PLAYBOOK ${ANSIBLE_OPTS}
}

parse_limit_hosts() {
    tempfoo=`basename $0`
    TMPFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1

    IN=$1
    OIFS=$IFS
    IFS=',' read -ra ADDR <<< "$IN"
    for i in "${ADDR[@]}"; do
        echo "$i" >> $TMPFILE
    done
    IFS=$OIFS

    echo $TMPFILE
}

CLI_ENV=$1
CLI_CMD=$2

shift
shift

while [ $# -ge 1 ]; do
    case "$1" in
        -x|-X)
            shift
            FIND_X="$1"
            ;;
    esac

    shift
done

if [ ! -z "$FIND_X" ]; then
    LIMIT_FILE=$(parse_limit_hosts $FIND_X)
    ANSIBLE_OPTS="${ANSIBLE_OPTS} --limit @${LIMIT_FILE}"
fi
