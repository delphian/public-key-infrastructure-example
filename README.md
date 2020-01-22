# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

### _For HomeLab Experimentation Only_

### Machines Required
 - *ub16-ca-offline*: The offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca*: The OCSP and CRL host for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home*: The intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

#### UB16-CA-OFFLINE SETUP
* Install Ubuntu (in our case 16)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
  * __Never restore this machine's connection to a network__
* From non privledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
* Enter repository `cd public-key-infrastructure-example`
* Switch to root `sudo su -`
* Execute `./root_ca_initialize.sh`
  * Create directory structure at `/root/ca`
  * Create root Certificate Authority (CA) private key and encrypt (ca.*DOMAIN*.key.pem file)
    * __Do not echo the contents of this file to the terminal__
    * __Do not transfer over a computer network__
    * Supply a PEM password for the root CA private key and save to a safe location
      * __Do not transfer over a computer network__
      * __Do not store on a network attached device__
   * Create root Certificate Authority (CA) certificate and self sign with private key (ca.*DOMAIN*.crt.pem file)
   * Create root Certificate Authority (CA) Certificate Revocation List (CRL) (revoked.crl file)

## Resources
 * [X - Certificate and Key management](https://www.hohnstaedt.de/xca/)
