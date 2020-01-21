# public-key-infrastructure-example
An example of public key infrastructure with an offline root certificate authority on linux

_For HomeLab Experimentation Only_

A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier. The topology of
the PKI which will be created is as follows:

Offline Root CA --------------------------------------------> Online Intermediate CA for intranet w/ OCSP & CRL
ca.guardtone.com                                              ca.home.guardtone.com
  |                                                           (ocsp.home.guardtone.com/crl.home.guardtone.com)
  |
  ---> Online OCSP Responder & CRL Host 
       (One Machine: ocsp.guardtone.com/crl.guardtone.com) 
