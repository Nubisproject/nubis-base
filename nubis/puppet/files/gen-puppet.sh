#!/bin/bash

set -e

# shellcheck disable=SC1091
[ -e /usr/local/lib/nubis/nubis-lib.sh ] && . /usr/local/lib/nubis/nubis-lib.sh || exit 1

# /usr/local/bin isn't set yet in our PATH
export PATH=/usr/local/bin:$PATH

eval "$(nubis-metadata)"

if [ -z "${NUBIS_SUDO_GROUPS}" ]; then
    NUBIS_SUDO_GROUPS_TMP="[]"
else
    NUBIS_SUDO_GROUPS_TMP=$(echo "${NUBIS_SUDO_GROUPS}" | sed -e's/^/["/g' | sed -e's/$/"]/' | sed -e's/,/","/g' )
fi

if [ -z "${NUBIS_USER_GROUPS}" ]; then
    NUBIS_USER_GROUPS_TMP="[]"
else
    NUBIS_USER_GROUPS_TMP=$(echo "${NUBIS_USER_GROUPS}" | sed -e's/^/["/g' | sed -e's/$/"]/' | sed -e's/,/","/g')
fi

cat <<EOF > /etc/nubis/puppet/nubis_users.pp
# Generated by gen-puppet.sh
class { 'nubis_users::setup':
    global_admins => [],
    sudo_users    => ${NUBIS_SUDO_GROUPS_TMP},
    nubis_users   => ${NUBIS_USER_GROUPS_TMP},
}
EOF

puppet apply --modulepath=/etc/puppet/modules /etc/nubis/puppet/nubis_users.pp