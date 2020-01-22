# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

### _For HomeLab Experimentation Only_

### Machines Required
 - *ub16-ca-offline*: The offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca*: Host the OCSP responder and CRL for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home*: The intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

#### ON UB16-CA-OFFLINE
* Install Ubuntu Server (in our case 16)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
  * __Never restore this machine's connection to a network__
* From non priviledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
* Enter script repository `cd public-key-infrastructure-example`
* Switch to root `sudo su -`
* Execute `./root_ca_initialize.sh`
  * Create directory structure at `/root/ca`
  * Create root Certificate Authority (CA) private key and encrypt (/root/ca/private/ca.*DOMAIN*.key.pem)
    * (__Do not echo the contents of this file to the terminal__) (__Do not transfer over a computer network__)
    * Supply a PEM password for the root CA private key and save to a safe location
      * (__Do not transfer over a computer network__) (__Do not store on a network attached device__)
   * Create root Certificate Authority (CA) certificate and self sign with private key (/root/ca/private/ca.*DOMAIN*.crt.pem)
   * Create root Certificate Authority (CA) Certificate Revocation List (CRL) (/root/ca/crl/revoked.crl)

#### ON UB16-CA
* Install Ubuntu Server (in our case 16) with LAMP package
* From non priviledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
* Enter script repository `cd public-key-infrastructure-example`
* Switch to root `sudo su -`
* Execute `./ocsp_create_csr.sh`
  * Create directory structure at `/root/ca`
  * Create OCSP responder host private key and encrypt (`/root/ca/private/ocsp.*DOMAIN*.com.key.pem`)
    * (__Do not echo the contents of this file to the terminal__) (__Do not transfer over a computer network__)
    * Supply a PEM password for the OCSP responder host private key and save to a safe location
      * (__Do not echo the contents of this file to the terminal__) (__Do not transfer over a computer network__)
  * Create OCSP responder host Certificate Signing Request (`./ocsp.*DOMAIN*.com.csr`)
* Copy the OCSP responder host Certificate Signing Request (CSR) (`./ocsp.*DOMAIN*.com.csr`) to a usb thumbdrive

#### ON UB16-CA-OFFLINE
* Copy the Certificate Signing Request (CSR) from the usb thumbdrive to `/root/ca/csr`
* Execute `./root_ca_sign_ocsp_csr.sh`
  * A list of potential Certificate Signing Requests (CSRs) will be displayed.
    * Select the OCSP host Certificate Signing Request (CSR) by typing `ocsp.*DOMAIN*.com`, omitting the .csr file extension.
  * Sign OCSP host Certificate Signing Request (CSR) creating the OCSP host certificate (`/root/ca/certs/ocsp.*DOMAIN*.com.crt.pem`)
    * Supply the previously created PEM password of the root Certificate Authority (CA) private key
* Copy the OCSP responder host certificate (`/root/ca/certs/ocsp.*DOMAIN*.com.crt.pem`) to a usb thumbdrive

#### ON UB16-CA

## Resources
 * [X - Certificate and Key management](https://www.hohnstaedt.de/xca/)
