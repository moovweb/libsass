#!/bin/bash
[ -e $HOME/gobuilds/tools/jenkins-env.sh ] && source $HOME/gobuilds/tools/jenkins-env.sh
[ -z $CLIBS_HOME ] && export CLIBS_HOME=$HOME/moovweb/clibs
[ ! -d $CLIBS_HOME ] && mkdir -p $CLIBS_HOME

#make clean
#git pull git://github.com/hcatlin/libsass.git
#git push origin master
#make install PREFIX=$CLIBS_HOME
git checkout -f
git pull git://github.com/hcatlin/libsass.git

./configure --prefix=$CLIBS_HOME
make install
