#! /bin/sh

OS=`uname -s`
ARCH=`uname -p`

echo "Setup development enviroment for Vega on $OS with $ARCH"

flutter doctor -v
dart pub global activate fvm
dart pub global activate --source=path ./ --executable=vtc

# eof
