## -----------------------------------------------------
## openssl.
## String functions
##
## @category  openssl
## @package   Includes
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------

## -----------------------------------------------------
## Defines colors
## -----------------------------------------------------
COLORRED="$(/usr/bin/tput setaf 1)"
COLORGREEN="$(/usr/bin/tput setaf 2)"
COLORRESET="$(/usr/bin/tput sgr0)"

## -----------------------------------------------------
## Write functions
## -----------------------------------------------------

writeToLog () {
    if [ -n "$1" ]; then
        echo $@ >> "${m_LOGFILE}"
    fi
    return 0
}

## -----------------------------------------------------
## Display functions
## -----------------------------------------------------

displayError () {
    if [ -n "$1" ]; then
        echo ${COLORRED}$@${COLORRESET}
    fi
    return 0
}

displaySuccess () {
    if [ -n "$1" ]; then
        echo ${COLORGREEN}$@${COLORRESET}
    fi
    return 0
}

display () {
    if [ -n "$1" ]; then
        echo $@
    fi
    return 0
}

## -----------------------------------------------------
## Log functions
## -----------------------------------------------------

error () {
    if [ -n "$1" ]; then
        writeToLog $@
        displayError $@
    fi
    return 0
}

notice () {
    if [ -n "$1" ]; then
        writeToLog $@
        display $@
    fi
    return 0
}

success () {
    if [ -n "$1" ]; then
        writeToLog $@
        displaySuccess $@
    fi
    return 0
}

checkDir () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: checkDir <label> <path>"
        exit 1
    fi
    if [ -d $2 ]; then
        success $1
    else
        error $1
    fi
    return 0
}

checkFile () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: checkFile <label> <path>"
        exit 1
    fi
    if [ -f $2 ]; then
        success $1
    else
        error $1
    fi
    return 0
}
