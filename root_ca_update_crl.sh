DIR="/root/ca"

# Abort script if any error is encountered
set -e
# Update certificate revocation list
openssl ca -config "./root_ca_openssl.cnf" -gencrl -out "${DIR}/crl/revoked.crl"
# Verify certificate revocation list
openssl crl -in "${DIR}/crl/revoked.crl" -noout -text
