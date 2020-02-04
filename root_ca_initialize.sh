# Initialize a Certificate Authority
mkdir -p "/root/ca/private" "/root/ca/csr" "/root/ca/certs" "/root/ca/crl"
touch "/root/ca/index.txt"
echo 1000 > "/root/ca/serial"
echo 1000 > "/root/ca/crlnumber"
openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "/root/ca/private/ca-offline.guardtone.com.key.pem"
openssl req -config "./root_ca_openssl.cnf" \
            -new -x509 -sha384 \
	    -extensions v3_ca \
	    -key "/root/ca/private/ca-offline.guardtone.com.key.pem" \
	    -out "/root/ca/certs/ca-offline.guardtone.com.crt.pem"
openssl ca -config "./root_ca_openssl.cnf" -gencrl -out "/root/ca/crl/revoked.crl"
