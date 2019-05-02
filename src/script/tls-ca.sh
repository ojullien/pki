#!/bin/sh

## -----------------------------------------------------------------------------
## openssl.
## Generation of a signing CA and its CA certificate
##
## @category  openssl
## @package   TLS CA
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
. "./config/tls-ca.cnf"

## -----------------------------------------------------------------------------
## Loads configuration
## -----------------------------------------------------------------------------
m_CA_TLS_CSR=$m_DIR_CSR/tls-ca.csr
m_CA_TLS_CRL=$m_DIR_CRL/tls-ca.crl
m_CA_TLS_DER=$m_DIR_CRT/tls-ca.cer
m_CA_TLS_P12=$m_DIR_CRT/tls-ca.p12
m_CA_TLS_PKCS1=$m_DIR_CA/private/tls-ca.pkcs1.key

checkFile "\tCertificate signing request is:\t${m_CA_TLS_CSR}" $m_CA_TLS_CSR
checkFile "\tPrivate PKCS1 key file is:\t${m_CA_TLS_PKCS1}"    $m_CA_TLS_PKCS1
checkFile "\tPublished certificate is:\t${m_CA_TLS_DER}"       $m_CA_TLS_DER
checkFile "\tP12 certificate is:\t\t${m_CA_TLS_P12}"           $m_CA_TLS_P12
checkFile "\tCertificate Revocation List is:\t${m_CA_TLS_CRL}" $m_CA_TLS_CRL
pause

## -----------------------------------------------------------------------------
## Create Signing CA request and key
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

    createRequest $m_CA_TLS_CONFIG \
                  $m_CA_TLS_CSR \
                  $m_CA_TLS_KEY \
                  -passout pass:$m_CA_TLS_PWD
fi

isExist "Request" $m_CA_TLS_CSR
isExist "Key" $m_CA_TLS_KEY
checkKey $m_CA_TLS_KEY -passin pass:$m_CA_TLS_PWD
pause

## -----------------------------------------------------------------------------
## Convert the key from PKCS#8 to PKCS#1 format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_PKCS1}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Convert the key from PKCS#8 to PKCS#1 format"

    convertToPKCS1 $m_CA_TLS_KEY $m_CA_TLS_PKCS1 -passin pass:$m_CA_TLS_PWD -passout pass:$m_CA_TLS_PWD
fi

isExist "PKCS#1 Key" $m_CA_TLS_PKCS1
checkKey $m_CA_TLS_PKCS1
pause

## -----------------------------------------------------------------------------
## Display request information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewRequest $m_CA_TLS_CSR
    pause
fi

## -----------------------------------------------------------------------------
## Create CA certificate
##    With the openssl ca command we issue a certificate based on the CSR.
##    The command takes its configuration from the [ca] section of the
##    configuration file. Note that it is the root CA that issues the signing CA
##    certificate!
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create certificate"

    createCertificate $m_CA_ROOT_CONFIG \
                      $m_CA_TLS_CSR \
                      $m_CA_ROOT_KEY \
                      $m_CA_TLS_CERT \
                      "signing_ca_ext" \
                      -passin pass:$m_CA_ROOT_PWD
fi

isExist "Certificate" $m_CA_TLS_CERT
openssl verify -policy_check -x509_strict -CAfile $m_CA_ROOT_CERT $m_CA_TLS_CERT
pause

## -----------------------------------------------------------------------------
## Display certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewCertificate $m_CA_TLS_CERT
    pause
fi

## -----------------------------------------------------------------------------
## Create PEM bundle
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create a certificate chain file"

    cat $m_CA_TLS_CERT $m_CA_ROOT_CERT > $m_CA_TLS_PEM
fi

isExist "Chain" $m_CA_TLS_PEM
openssl verify -policy_check -x509_strict -CAfile $m_CA_ROOT_CERT $m_CA_TLS_PEM
pause

## -----------------------------------------------------------------------------
## Publish certificate in DER format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_DER}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Publish certificate in DER format"

    publishCertificate $m_CA_TLS_CERT $m_CA_TLS_DER
fi

isExist "DER certificate" $m_CA_TLS_DER
pause

## -----------------------------------------------------------------------------
## Bundle Certificate, key and the CA chain for distribution
## -----------------------------------------------------------------------------
if [ "${m_OPTION_P12}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Bundle Certificate and key"

    openssl pkcs12 -export \
                   -name "Wheezy TLS CA" \
                   -caname "Wheezy Root CA" \
                   -inkey $m_CA_TLS_KEY \
                   -in $m_CA_TLS_CERT \
                   -certfile $m_CA_ROOT_PEM \
                   -passin pass:$m_CA_TLS_PWD \
                   -passout pass:$m_CA_TLS_PWD \
                   -out $m_CA_TLS_P12
fi

isExist "Bundle" $m_CA_TLS_P12
pause

## -----------------------------------------------------------------------------
## Display P12 certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewP12 $m_CA_TLS_P12 -passin pass:$m_CA_TLS_PWD
    pause
fi

## -----------------------------------------------------------------------------
## Create a list of revoked certificates
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRL}" -eq "1" ]; then
    display "-----------------------------------------------------"

    if [ "${m_OPTION_KEY}" -eq "1" -o "${m_OPTION_CRT}" -eq "1" ]; then
        notice "Create an empty list of revoked certificates"
    else
        notice "Update the list of revoked certificates"
    fi

    createCRL $m_CA_TLS_CONFIG \
              $m_CA_TLS_KEY \
              $m_CA_TLS_CRL \
              -passin pass:$m_CA_TLS_PWD
fi

isExist "Revoked list" $m_CA_TLS_CRL
pause

## -----------------------------------------------------------------------------
## Display revoked certificates list information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewCRL $m_CA_TLS_CRL
fi
