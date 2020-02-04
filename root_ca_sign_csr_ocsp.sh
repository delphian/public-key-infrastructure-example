# Sign the OCSP CSR, generating a valid certificate good for 14 days, using 
# ocsp options in the configuration file (ocsp|v3_intermediate_ca|server_cert)
openssl ca -config "./root_ca_openssl.cnf" \
           -extensions ocsp \
	   -days 14 \
	   -md sha384 \
	   -in "/root/ca/csr/ocsp.ca.guardtone.com.csr" \
	   -out "/root/ca/certs/ocsp.ca.guardtone.com.crt.pem"
# Review signed OCSP certificate
openssl x509 -noout -text -in "/root/ca/certs/ocsp.ca.guardtone.com.crt.pem"
