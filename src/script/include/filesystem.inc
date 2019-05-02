## -----------------------------------------------------
## openssl.
## File System functions
##
## @category  openssl
## @package   Includes
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------

## -----------------------------------------------------
## Checks whether a file exists
## -----------------------------------------------------

isExist () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: isExist <label> <filename>"
        exit 1
    fi
    if [ -f $2 ]; then
        success "$1 does exist: $2"
    else
        error "$1 does not exist: $2"
    fi
}

## -----------------------------------------------------
## Return newest file in directory
## -----------------------------------------------------

getNewestFile () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: getNewestFile <directory>"
        exit 1
    fi
    ls -t $1 | head -1
}

## -----------------------------------------------------
## Directories
## -----------------------------------------------------

removeDirectory () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: removeDirectory <path>"
        exit 1
    fi
    display -n "Removing ${1} :"
    rm -Rf "${1}"
    if [ "0" -eq "$?" ]; then
        displaySuccess "OK"
    else
        displayError "NOK"
    fi
}

cleanDirectory () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: cleanDirectory <path>"
        exit 1
    fi
    display -n "Cleaning ${1} :"
    rm -f "${1}"//*
    if [ "0" -eq "${?}" ]; then
        displaySuccess "OK"
    else
        displayError "NOK"
    fi
}

createDirectory () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: createDirectory <top directory>"
        exit 1
    fi
    display -n "Creating ${1} :"
    mkdir -p "${1}"
    if [ "0" -eq "${?}" ]; then
        displaySuccess "OK"
    else
        displayError "NOK"
    fi
}
