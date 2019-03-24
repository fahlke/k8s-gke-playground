#!/bin/bash

# Configuration
source ./00-vars

TEMP="/tmp/k8s"
BASE_DIR="${TEMP}/certificates"
mkdir -p "${BASE_DIR}"

TLS_CA_CONFIG="${BASE_DIR}/ca-config.json"
TLS_CA_CSR_CONFIG="${BASE_DIR}/ca-csr.json"
TLS_CA_CERT="${BASE_DIR}/ca.pem"
TLS_CA_KEY="${BASE_DIR}/ca-key.pem"
TLS_CA_CSR="${BASE_DIR}/ca.csr"

TILLER_CSR_CONFIG="${BASE_DIR}/tiller-csr.json"
TILLER_TLS_CERT="${BASE_DIR}/tiller.pem"
TILLER_TLS_KEY="${BASE_DIR}/tiller-key.pem"
TILLER_CSR="${BASE_DIR}/tiller.csr"

TILLER_HOSTNAME='tiller.k8s.int.fahlke.dev' #35.231.177.50
TILLER_SERVICE_ACCOUNT='tiller'
TILLER_SERVICE_ACCOUNT_CONFIG="${BASE_DIR}/tiller-serviceaccount.yaml"

USER_NAME='alexander.fahlke'
USER_CERT_CONFIG="${BASE_DIR}/${USER_NAME}-config.json"





cat > "${TILLER_SERVICE_ACCOUNT_CONFIG}" <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: "${TILLER_SERVICE_ACCOUNT}"
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: "${TILLER_SERVICE_ACCOUNT}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: "${TILLER_SERVICE_ACCOUNT}"
    namespace: kube-system
EOF
kubectl apply -f "${TILLER_SERVICE_ACCOUNT_CONFIG}"






# - Server setup -
# Install tiller in K8s cluster
helm init \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --tiller-tls \
  --tiller-tls-verify \
  --tiller-tls-cert "${TILLER_TLS_CERT}" \
  --tiller-tls-key "${TILLER_TLS_KEY}" \
  --tls-ca-cert "${TLS_CA_CERT}" \
  --service-account "${TILLER_SERVICE_ACCOUNT}"

exit 0


# - Certificate Authority -
cat > "${TLS_CA_CONFIG}" <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "tiller-server": {
        "usages": ["signing", "key encipherment", "server auth"],
        "expiry": "8760h"
      },
      "helm-user-account": {
        "usages": ["client auth"],
        "expiry": "2160h"
      },
      "helm-service-account": {
        "usages": ["client auth"],
        "expiry": "2160h"
      }
    }
  }
}
EOF

cat > "${TLS_CA_CSR_CONFIG}" <<EOF
{
  "CN": "tiller:ca",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [{
      "C":  "DE",
      "ST": "Lower Saxony",
      "L":  "Uelzen",
      "O":  "Tiller",
      "OU": "CA"
  }]
}
EOF
cfssl gencert \
  -initca "${TLS_CA_CSR_CONFIG}" | cfssljson -bare "${BASE_DIR}/ca"



# - Server and client Certificates -
# Tiller Server certificate
cat > "${TILLER_CSR_CONFIG}" <<EOF
{
  "CN": "tiller:server",
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
      "OU": "Server"
  }]
}
EOF
cfssl gencert \
  -ca="${TLS_CA_CERT}" \
  -ca-key="${TLS_CA_KEY}" \
  -config="${TLS_CA_CONFIG}" \
  -profile="tiller-server" \
  -hostname="${TILLER_HOSTNAME}" \
  "${TILLER_CSR_CONFIG}" | cfssljson -bare "${BASE_DIR}/tiller"

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
  "${USER_CERT_CONFIG}" | cfssljson -bare "${BASE_DIR}/${USER_NAME}"



# - Server setup -
# Install tiller in K8s cluster
helm init \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --tiller-tls \
  --tiller-tls-verify \
  --tiller-tls-cert "${TILLER_TLS_CERT}" \
  --tiller-tls-key "${TILLER_TLS_KEY}" \
  --tls-ca-cert "${TLS_CA_CERT}" \
  --service-account "${TILLER_SERVICE_ACCOUNT}"
