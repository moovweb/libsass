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

# make an output folder just for this lib
rm -rf "$CLIBS_HOME/output/libsass"
mkdir -p "$CLIBS_HOME/output/libsass"

./configure --prefix="$CLIBS_HOME/output/libsass" || exit 1
make || exit 1
make install || exit 1

# empty the dumping ground and re-copy all the latest clib outputs into it
rm -rf "$CLIBS_HOME/include"
rm -rf "$CLIBS_HOME/lib"
for f in "$CLIBS_HOME/output/*/*"
do
  cp -R $f $CLIBS_HOME
  cp -R $f $CLIBS_HOME
done
