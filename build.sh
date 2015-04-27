#!/bin/bash

# Provide a all lowercased OS name for everyone that sources us.
if [[ "x`uname`" == xMINGW32_NT* ]]; then
  export OS_NAME="windows"
else
  export OS_NAME=`uname | tr '[:upper:]' '[:lower:]'`
fi

if [ `uname -m` == "x86_64" ]; then
  export ARCH=amd64
else
  export ARCH=i386
fi

if [[ $1 == "jenkins" ]]; then
  export CLIBS_HOME="$HOME/userContent/clibs/$OS_NAME-$ARCH"
else
  [ -z $CLIBS_HOME ] && [ ! -z $MOOV_HOME ] && export CLIBS_HOME=$MOOV_HOME/clibs
fi

if [ -z $CLIBS_HOME ]; then
	echo "Please set CLIBS_HOME or MOOV_HOME before running this script."
	exit 1
fi

if [ ! -d $CLIBS_HOME ]; then
  mkdir -p $CLIBS_HOME
  if [ $? != 0 ]; then
    "Couldn't create $CLIBS_HOME directory"
    exit 1
  fi
fi

if [[ "x`uname`" == xMINGW32_NT* ]]; then
	CLIBS_HOME=$(echo "$CLIBS_HOME" | sed 's/\\/\//g' | sed -r 's/(^[^\/]):/\/\1/')
fi

if [[ "`uname`" == Darwin* ]]; then
	export LIBTOOL=`which glibtool`
	export LIBTOOLIZE=`which glibtoolize`
fi

# submodule setup for sass2scss support
git submodule init || exit 1
git submodule update || exit 1

autoreconf -vfi || exit 1

# make an output folder just for this lib
rm -rf "$CLIBS_HOME/output/libsass" || exit 1
mkdir -p "$CLIBS_HOME/output/libsass" || exit 1

./configure --prefix="$CLIBS_HOME/output/libsass" || exit 1
make || exit 1
make install || exit 1

# force-copy new libs back to clibs output directory
# do not remove anything from output directory, so that we can parallelize clibs compilation
for dir in "lib" "include"
do
  for f in "$CLIBS_HOME/output/libsass/$dir/*"
  do
    echo "Moving $f to $CLIBS_HOME/$dir"
    mkdir -p "$CLIBS_HOME/$dir" || exit 1
    # rsync -Klr --force is like 'cp -Rf', but can overwrite dir symlinks
    rsync -Klr --force $f "$CLIBS_HOME/$dir" || exit 1
    if [[ "x`uname`" == xMINGW32_NT* ]]; then
      cp -f $CLIBS_HOME/output/libsass/bin/*.dll "$CLIBS_HOME/lib" || exit 1
    fi
  done
done
