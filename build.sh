#!/bin/bash
[ -z $CLIBS_HOME ] && [ ! -z $MOOV_HOME ] && export CLIBS_HOME="$MOOV_HOME/clibs"
if [ -z $CLIBS_HOME ]; then
	echo "Please set CLIBS_HOME or MOOV_HOME before running this script."
	exit 1
fi
[ ! -d $CLIBS_HOME ] && mkdir -p $CLIBS_HOME

if [[ "x`uname`" == xMINGW32_NT* ]]; then
	CLIBS_HOME=$(echo "$CLIBS_HOME" | sed 's/\\/\//g' | sed -r 's/(^[^\/]):/\/\1/')
fi

if [[ "`uname`" == Darwin* ]]; then
	export LIBTOOL=`which glibtool`
	export LIBTOOLIZE=`which glibtoolize`
fi

git checkout -f
git pull git@github.com:hcatlin/libsass.git master

autoreconf -vfi || exit 1
./configure --prefix=$CLIBS_HOME || exit 1
make || exit 1
make install || exit 1
