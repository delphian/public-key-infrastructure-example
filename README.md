# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

__***For HomeLab Experimentation Only***__
```
^
|
--------------------------<<<<<<<<<<<<<<<<< Did you see?
```

## Prerequisites

#### 3 Machines
 - *ub16-ca-offline*: The offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca*: Host the OCSP responder and CRL host for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home*: The intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

### On ub16-ca-offline (offline root Certificate Authority)
* Install Ubuntu Server (in our case 16)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
  * (__Never restore this machine's connection to a network__)
* From non priviledged user directory clone and enter repository
    ```bash
    git clone https://github.com/delphian/public-key-infrastructure-example.git
    cd public-key-infrastructure-example
    ```
* [Customize all files for your domain](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-all-files-for-your-domain)
* [Customize root_ca_openssl.cnf](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-openssl-config-file)
* Execute the root Certificate Authority (CA) initialization script
    ```bash
    sudo ./root_ca_initialize.sh
    ```
  * Directory structure generated at `/root/ca`
  * Generates root Certificate Authority (CA) private key and encrypts <sub><sup>(/root/ca/private/ca.guardtone.key.pem)</sup></sub>
    * (__*Do not echo the contents of this file to the terminal*__) (__*Do not transfer over a computer network*__)
    * Supply a PEM pass phrase for the root CA private key and verify. Save to a safe location
      * (__*Do not transfer over a computer network*__) (__*Do not store on a network attached device*__)
  * Generates root Certificate Authority (CA) Certificate Signing Request (CSR) and self sign with private key (creating the actual certificate) <sub><sup>(/root/ca/certs/ca.guardtone.crt.pem)</sup></sub>
    * Enter the root CA private key pass phrase
    * Enter the Distinuished Name details of the certificate holder to be incorporated into the certificate:
      * `Country Name`, `State or Province Name`, `Locality Name`, `Organization Name`, `Organization Unit Name`, `Common Name`, and contact `Email Address`. *Common Name could be `GuardTone Root Certificate Authority`*
  * Generates root Certificate Authority (CA) Certificate Revocation List (CRL) <sub><sup>(/root/ca/crl/revoked.crl)</sup></sub>
    * Enter the root CA private key pass phrase

### On ub16-ca (OCSP responder and Certficiate Revocation List host)
* Install Ubuntu Server (in our case 16) with LAMP package
* From non priviledged user directory clone and enter repository
    ```bash
    git clone https://github.com/delphian/public-key-infrastructure-example.git
    cd public-key-infrastructure-example
    ```
* [Customize all files for your domain](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-all-files-for-your-domain)
* [Customize root_ca_openssl.cnf](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-openssl-config-file)
* Execute the OCSP responder Certificate Signing Request (CSR) creation script
    ```bash
    sudo ./root_ca_create_csr_ocsp.sh
    ```
  * Directory structure generated at `/root/ca/ocsp`
  * Generates OCSP responder private key and encrypt <sub><sup>(`/root/ca/ocsp/private/ocsp.guardtone.com.key.pem`)</sup></sub>
    * (__*Do not echo the contents of this file to the terminal*__) (__*Do not transfer over a computer network*__)
    * Supply a PEM pass phrase for the OCSP responder host private key and verify. Save to a safe location
      * (__*Do not echo the contents of this file to the terminal*__) (__*Do not transfer over a computer network*__)
  * Generates OCSP responder Certificate Signing Request <sub><sup>(/root/ca/ocsp/csr/ocsp.guardtone.com.csr)</sup></sub>
    * Enter the OCSP responder private key pass phrase
    * Enter the Distinuished Name details of the certificate holder to be incorporated into the certificate:
      * `Country Name`, `State or Province Name`, `Locality Name`, `Organization Name`, `Organization Unit Name`, `Common Name`, and contact `Email Address`. __*Common Name must be `ocsp.guardtone.com`*__
    * Copy the OCSP responder Certificate Signing Request (CSR) to a usb thumbdrive
    ```bash
    sudo cp /root/ca/ocsp/csr/ocsp.guardtone.com.csr /media/usb
    ```

### On ub16-ca-offline (offline root Certificate Authority)
* Copy the Certificate Signing Request (CSR) from the usb thumbdrive to the CSR intake and execute the Certificate Signing Request (CSR) processor script
    ```bash
    sudo cp /media/usb/ocsp.guardtone.com.csr /root/ca/csr
    sudo ./root_ca_sign_csr_ocsp.sh`
    ````
  * A list of potential Certificate Signing Requests (CSRs) will be displayed.
    * Select the OCSP responder Certificate Signing Request (CSR) by typing `ocsp.guardtone.com`, omitting the .csr file extension.
  * Sign OCSP responder Certificate Signing Request (CSR) creating the __poor practice__<sup>1</sup> OCSP responder certificate <sub><sup>(/root/ca/certs/ocsp.guardtone.com.crt.pem)</sup></sub>
    * Supply the previously created PEM password of the root Certificate Authority (CA) private key
    * Confirm the signing, twice
* Copy the OCSP responder certificate, root Certificate Authority (CA) Certificate, revocation database (index.txt), and Certificate Revocation List (CRL) to a usb thumbdrive
    ```bash
    sudo cp /root/ca/certs/ocsp.guardtone.com.crt.pem /media/usb
    sudo cp /root/ca/certs/ca.guardtone.crt.pem /root/ca/crl/revoked.crl /root/ca/index.txt /media/usb
    ```

### On ub16-ca (OCSP responder and Certficiate Revocation List host)
* Copy the root Certificate Authority (CA) Certificate, OCSP responder Certificate, revocation database (index.txt), and Certificate Revocation List (CRL) from the usb thumbdrive
    ```bash
    sudo cp /media/usb/index.txt /root/ca
    sudo cp /media/usb/ca.guardtone.crt.pem /root/ca/certs
    sudo cp /media/usb/ocsp.guardtone.com.crt.pem /root/ca/ocsp/certs
    ```
* Launch OpenSSL in OCSP responder mode (as root?)
    ```bash
    sudo openssl ocsp -port 127.0.0.1:2560 -text -sha256 \
    -index "/root/ca/index.txt" \
    -CA "/root/ca/certs/ca.guardtone.crt.pem" \
    -rkey "/root/ca/ocsp/private/ocsp.guardtone.com.key.pem" \
    -rsigner "/root/ca/ocsp/certs/ocsp.guardtone.com.crt.pem" \
    -nrequest 1
    ```
  * Enter the OCSP responder host private key pass phrase

## Customize All Files for your Domain
* Replace all instances of `GuardTone` with your domain name. Eg `Google` or `MyHomeLab`
    ```bash
    sed -i -- 's/GuardTone/MyHomeLab/g' *
    ```
* Replace all instances of `guardtone` with your domain name. Eg `google` or `myhomelab`
    ```bash
    sed -i -- 's/guardtone/myhomelab/g' *
    ```

## Customize OpenSSL Config File
* Edit `openssl-root.cnf`
* Replace the geographic location variables with appropriate values
    ```bash
    countryName_default             = US
    stateOrProvinceName_default     = California
    localityName_default            = Victorville
    ```

## Resources

### Introduction
* [An Overview of Cryptography](https://www.cs.princeton.edu/~chazelle/courses/BIB/overview-crypto.pdf)
* [On the Differences between Hiding Information and Cryptography Techniques: An Overview](https://scialert.net/fulltextmobile/?doi=jas.2010.1650.1655)
* [Public Key Infrastructure
Overview](http://highsecu.free.fr/db/outils_de_securite/cryptographie/pki/publickey.pdf)
* [Design and Implementation of PKI (For Multi Domain
Environment)](https://pdfs.semanticscholar.org/cfb9/77539d4a214766adc3a4a56f57a5a464b9cf.pdf)
* [HTTPS in the Real World](https://robertheaton.com/2018/11/28/https-in-the-real-world/)

### Tutorials and Walkthroughs
* [OCSP Validation with OpenSSL](https://akshayranganath.github.io/OCSP-Validation-With-Openssl/)
* [Building an OpenSSL Certificate Authority](https://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considerations-for-elliptical-curves-27720)

### Best Practice, Common Mistakes
* <sup>[1]</sup>[Most Secure Way to do OCSP Signing](https://security.stackexchange.com/questions/15564/what-is-the-most-secure-way-to-do-ocsp-signing-without-creating-validation-loops)
* [A Best Practice for Root CA Key Update in PKI](https://link.springer.com/content/pdf/10.1007%2F978-3-540-24852-1_20.pdf)

### RFCs
* [X.509 Internet Public Key Infrastructure - Online Certificate Status Protocol - OCSP](https://tools.ietf.org/html/rfc6960)
* [Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile](https://tools.ietf.org/html/rfc5280)

### Software
* [X - Certificate and Key management](https://www.hohnstaedt.de/xca/)
