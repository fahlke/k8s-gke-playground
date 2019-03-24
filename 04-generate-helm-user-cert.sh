#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: 04-generate-helm-user-cert.sh <firstname.lastname>"
  exit
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERT_DIR="${BASEDIR}/build/certificates"
USER_CERT_DIR="${BASEDIR}/build/certificates/users"
mkdir -p "${USER_CERT_DIR}"

# write out user config
TLS_CA_CERT="${CERT_DIR}/ca.pem"
TLS_CA_KEY="${CERT_DIR}/ca-key.pem"
TLS_CA_CONFIG="${CERT_DIR}/ca-config.json"

TILLER_HOSTNAME='tiller.k8s.int.fahlke.dev' #35.231.177.50

USER_NAME="$1"
USER_CONFIG="${USER_CERT_DIR}/${USER_NAME}.rc"
USER_CERT_CONFIG="${USER_CERT_DIR}/${USER_NAME}-config.json"
USER_CERT="${USER_CERT_DIR}/${USER_NAME}.pem"
USER_CERT_KEY="${USER_CERT_DIR}/${USER_NAME}-key.pem"


# Helm client (user) certificate
cat > "${USER_CERT_CONFIG}" <<EOF
{
  "CN": "helm:user:account:${USER_NAME}",
  "hosts":[],
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [{
      "C":  "DE",
      "ST": "Lower Saxony",
      "L":  "Uelzen",
      "O":  "Tiller",
      "OU": "User"
  }]
}
EOF
cfssl gencert \
  -ca="${TLS_CA_CERT}" \
  -ca-key="${TLS_CA_KEY}" \
  -config="${TLS_CA_CONFIG}" \
  -profile="helm-user-account" \
  -hostname="${TILLER_HOSTNAME}" \
  "${USER_CERT_CONFIG}" | cfssljson -bare "${USER_CERT_DIR}/${USER_NAME}"



# create user config for exporting the Helm environment variables
tee "${USER_CONFIG}" >/dev/null <<EOF
unset HELM_TLS_ENABLE
unset HELM_TLS_CA_CERT
unset HELM_TLS_CERT
unset HELM_TLS_KEY

export HELM_TLS_ENABLE='true'
export HELM_TLS_CA_CERT="${TLS_CA_CERT}"
export HELM_TLS_CERT="${USER_CERT}"
export HELM_TLS_KEY="${USER_CERT_KEY}"
EOF

echo -e "\nnow run: source ${USER_CONFIG}"