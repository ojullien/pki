#!/bin/sh

## -----------------------------------------------------
## OpenSSL.
## Create and operate Public Key Infrastructures.
## Create directories.
##
## @category  openssl
## @package   Reset
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------

clear

## -----------------------------------------------------
## Includes
## -----------------------------------------------------
. "./include/string.inc"
. "./include/filesystem.inc"
. "./include/misc.inc"
. "./include/openssl.inc"

## -----------------------------------------------------
## Loads configuration
## -----------------------------------------------------
. "./config/main.cnf"
pause

## -----------------------------------------------------
## Tasks
## -----------------------------------------------------
display "-----------------------------------------------------"

removeDirectory $m_DIR_CERTS
removeDirectory $m_DIR_CA
cleanDirectory $m_DIR_SCRIPT/log

createDirectory $m_DIR_CA/private
chmod 700 $m_DIR_CA/private
createDirectory $m_DIR_CA/db
createDirectory $m_DIR_CRT
createDirectory $m_DIR_CRL
createDirectory $m_DIR_CSR

# The database files must exist before the openssl ca command can be used.
for sArg in ${m_CA_NAMES}
do
    createDatabases $m_DIR_CA/db $sArg
    createDirectory $m_DIR_CA/archive/$sArg
done
