#!/bin/bash 
# This script will change the paths of the configuration files.

oldpath=$( cat conf/online_nnet2_decoding.conf | grep mfcc-config | sed "s:--mfcc-config=::" | sed s:conf/mfcc.conf:: )

if [ -z $oldpath ]; then
echo "You don't have proper configuration files. Please check if you have all the conf file or download the acoustic model again"
exit 1
fi 

for x in conf/*conf; do
  cp $x $x.orig
  sed s:$oldpath:$(pwd)/: < $x.orig > $x
done
