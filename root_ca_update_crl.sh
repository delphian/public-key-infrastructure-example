# Inspired by instructions from http://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
#
# Switch to root before executing
#
# Abort script if any error is encountered
set -e
#
# Update certificate revocation list
openssl ca -config /root/ca/openssl_root.cnf -gencrl -out /root/ca/crl/revoked.crl
#
# Verify certificate revocation list
openssl crl -in /root/ca/crl/revoked.crl -noout -text
