#!/bin/bash

scriptdir=$HOME/scripts
bindir=$HOME/bin

# Help message
if [ "X-h" == "X$1" ]; then
    echo ""
    echo "Usage: ./install.sh [scriptdir [bindir]]"
    echo "       scriptdir - where you keep scripts"
    echo "       bindir    - where you keep binaries"
    echo "Default is to place the script in $scriptdir and the bindary in $bindir"
    echo ""
    echo "There is no need to use this install script - you can simply run the"
    echo "monitorig.pl script without installing it"
    echo ""
fi

# Check parameters
if [ "X" != "X$1" ]; then
    scriptdir=$1
fi

if [ "X" != "X$2" ]; then
    bindir=$2
fi

# Make directories
if [ ! -d $bindir ]; then
    echo "Creating $bindir"
    mkdir -p $bindir
    if [ ! -d $bindir ]; then
        echo "Failed to create $bindir"
        exit 1
    fi
fi

if [ ! -d $scriptdir ]; then
    echo "Creating $scriptdir"
    mkdir -p $scriptdir
    if [ ! -d $scriptdir ]; then
        echo "Failed to create $scriptdir"
        exit 1
    fi
fi

# Copy file and create link
cp monitorig.pl $scriptdir
(cd $bindir; ln -sf $scriptdir/monitorig.pl monitorig)

