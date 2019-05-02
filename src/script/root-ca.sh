#!/bin/sh

## -----------------------------------------------------------------------------
## openssl.
## Generation of Root CA and its CA certificate
##
## @category  openssl
## @package   Root CA
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

clear

## -----------------------------------------------------------------------------
## Includes
## -----------------------------------------------------------------------------
. "./include/string.inc"
. "./include/filesystem.inc"
. "./include/misc.inc"
. "./include/openssl.inc"
. "./include/option.inc"

## -----------------------------------------------------------------------------
## Loads common configuration
## -----------------------------------------------------------------------------
. "./config/main.cnf"
. "./config/root-ca.cnf"

## -----------------------------------------------------------------------------
## Loads configuration
## -----------------------------------------------------------------------------
m_CA_ROOT_CSR=$m_DIR_CSR/root-ca.csr
m_CA_ROOT_CRL=$m_DIR_CRL/root-ca.crl
m_CA_ROOT_DER=$m_DIR_CRT/root-ca.cer
m_CA_ROOT_P12=$m_DIR_CRT/root-ca.p12
m_CA_ROOT_PKCS1=$m_DIR_CA/private/root-ca.pkcs1.key

checkFile "\tCertificate signing request is:\t${m_CA_ROOT_CSR}"  $m_CA_ROOT_CSR
checkFile "\tPrivate PKCS1 key file is:\t${m_CA_ROOT_PKCS1}"     $m_CA_ROOT_PKCS1
checkFile "\tPublished certificate is:\t${m_CA_ROOT_DER}"        $m_CA_ROOT_DER
checkFile "\tP12 certificate is:\t\t${m_CA_ROOT_P12}"            $m_CA_ROOT_P12
checkFile "\tCertificate Revocation List is:\t${m_CA_ROOT_CRL}"  $m_CA_ROOT_CRL
pause

## -----------------------------------------------------------------------------
## Create Root CA request and key
##    With the openssl req -new command we create a private key and a
##    certificate signing request (CSR).
##    The openssl req command takes its configuration from the [req] section of
##    the configuration file.
##    This process produces two files as output:
##      1- A private key
##      2- A certificate signing request
##    These files should be kept. When the certificate you are about to create
##    expires, the request can be used again to create a new certificate with a
##    new expiry date.
##    The private key is of course necessary for SSL encryption.
## -----------------------------------------------------------------------------
if [ "${m_OPTION_KEY}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Creates request and key"

    createRequest $m_CA_ROOT_CONFIG \
                  $m_CA_ROOT_CSR \
                  $m_CA_ROOT_KEY \
                  -passout pass:$m_CA_ROOT_PWD
fi

isExist "Request" $m_CA_ROOT_CSR
isExist "PKCS#8 Key" $m_CA_ROOT_KEY
checkKey $m_CA_ROOT_KEY -passin pass:$m_CA_ROOT_PWD
pause

## -----------------------------------------------------------------------------
## Convert the key from PKCS#8 to PKCS#1 format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_PKCS1}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Convert the key from PKCS#8 to PKCS#1 format"

    convertToPKCS1 $m_CA_ROOT_KEY $m_CA_ROOT_PKCS1 -passin pass:$m_CA_ROOT_PWD -passout pass:$m_CA_ROOT_PWD
fi

isExist "PKCS#1 Key" $m_CA_ROOT_PKCS1
checkKey $m_CA_ROOT_PKCS1
pause

## -----------------------------------------------------------------------------
## Display request information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewRequest $m_CA_ROOT_CSR
    pause
fi

## -----------------------------------------------------------------------------
## Create a self-signed CA certificate
##    With the openssl ca command we issue a root CA certificate based on the
##    CSR. The root certificate is self-signed and serves as the starting point
##    for all trust relationships in the PKI. The openssl ca command takes its
##    configuration from the [ca] section of the configuration file.
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create certificate"

    createCertificate $m_CA_ROOT_CONFIG \
                      $m_CA_ROOT_CSR \
                      $m_CA_ROOT_KEY \
                      $m_CA_ROOT_CERT \
                      "root_ca_ext" \
                      -passin pass:$m_CA_ROOT_PWD \
                      -selfsign
fi

isExist "Certificate" $m_CA_ROOT_CERT
openssl verify -policy_check -x509_strict -CAfile $m_CA_ROOT_CERT $m_CA_ROOT_CERT
pause

## -----------------------------------------------------------------------------
## Display certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewCertificate $m_CA_ROOT_CERT
    pause
fi

## -----------------------------------------------------------------------------
## Create PEM bundle
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create a certificate PEM bundle"

    cat $m_CA_ROOT_KEY $m_CA_ROOT_CERT > $m_CA_ROOT_PEM
fi

isExist "Chain" $m_CA_ROOT_PEM
openssl verify -policy_check -x509_strict -CAfile $m_CA_ROOT_CERT $m_CA_ROOT_PEM
pause

## -----------------------------------------------------------------------------
## Publish certificate in DER format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_DER}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Publish certificate in DER format"

    publishCertificate $m_CA_ROOT_CERT $m_CA_ROOT_DER
fi

isExist "DER certificate" $m_CA_ROOT_DER
pause

## -----------------------------------------------------------------------------
## Bundle Certificate and key
## -----------------------------------------------------------------------------
if [ "${m_OPTION_P12}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Bundle Certificate and key"

    bundleCertificate "Wheezy Root CA" \
                      $m_CA_ROOT_CERT \
                      $m_CA_ROOT_KEY \
                      pass:$m_CA_ROOT_PWD \
                      pass:$m_CA_ROOT_PWD \
                      $m_CA_ROOT_P12
fi

isExist "Bundle" $m_CA_ROOT_P12
pause

## -----------------------------------------------------------------------------
## Display P12 certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewP12 $m_CA_ROOT_P12 -passin pass:$m_CA_ROOT_PWD
    pause
fi

## -----------------------------------------------------------------------------
## Create a list of revoked certificates
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRL}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create an empty list of revoked certificates"

    createCRL $m_CA_ROOT_CONFIG \
              $m_CA_ROOT_KEY \
              $m_CA_ROOT_CRL \
              -passin pass:$m_CA_ROOT_PWD
fi

isExist "Revoked list" $m_CA_ROOT_CRL
pause

## -----------------------------------------------------------------------------
## Display revoked certificates list information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewCRL $m_CA_ROOT_CRL
fi
