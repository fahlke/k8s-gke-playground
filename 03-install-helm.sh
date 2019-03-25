#!/bin/bash

# Configuration
source ./00-vars

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERT_DIR="${BASEDIR}/build/certificates"
mkdir -p "${CERT_DIR}"

TLS_CA_CONFIG="${CERT_DIR}/ca-config.json"
TLS_CA_CSR_CONFIG="${CERT_DIR}/ca-csr.json"
TLS_CA_CERT="${CERT_DIR}/ca.pem"
TLS_CA_KEY="${CERT_DIR}/ca-key.pem"
TLS_CA_CSR="${CERT_DIR}/ca.csr"

TILLER_CSR_CONFIG="${CERT_DIR}/tiller-csr.json"
TILLER_TLS_CERT="${CERT_DIR}/tiller.pem"
TILLER_TLS_KEY="${CERT_DIR}/tiller-key.pem"
TILLER_CSR="${CERT_DIR}/tiller.csr"

TILLER_HOSTNAME='tiller.k8s.int.fahlke.dev'
TILLER_SERVICE_ACCOUNT='tiller'
TILLER_SERVICE_ACCOUNT_CONFIG="${CERT_DIR}/tiller-serviceaccount.yaml"
TILLER_REPLICA_COUNT='3'


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
  -initca "${TLS_CA_CSR_CONFIG}" | cfssljson -bare "${CERT_DIR}/ca"



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
  "${TILLER_CSR_CONFIG}" | cfssljson -bare "${CERT_DIR}/tiller"



# - Server setup -
# Install tiller in K8s cluster
helm init \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --replicas "${TILLER_REPLICA_COUNT}" \
  --tiller-tls \
  --tiller-tls-verify \
  --tiller-tls-cert "${TILLER_TLS_CERT}" \
  --tiller-tls-key "${TILLER_TLS_KEY}" \
  --tls-ca-cert "${TLS_CA_CERT}" \
  --service-account "${TILLER_SERVICE_ACCOUNT}"

# verifiy proper installation by checking client and server version
helm version \
  --tls \
  --tls-ca-cert "${TLS_CA_CERT}" \
  --tls-cert "${CERT_DIR}/${USER_NAME}.pem" \
  --tls-key "${CERT_DIR}/${USER_NAME}-key.pem" \
  --tls-verify

helm repo update
