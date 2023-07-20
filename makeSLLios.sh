#!/bin/bash
#export ANDROID_NDK_ROOT=/some/where/android-ndk-10d

OPENSSL_TAG=openssl-3.0.9
OPENSSL_LIB_PREFIX=_3.so



TMP_DIR=../build_openssl
CROSS_TOP_SIM="`xcode-select --print-path`/Platforms/iPhoneSimulator.platform/Developer"
CROSS_SDK_SIM="iPhoneSimulator.sdk"

CROSS_TOP_IOS="`xcode-select --print-path`/Platforms/iPhoneOS.platform/Developer"
CROSS_SDK_IOS="iPhoneOS.sdk"
export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"

export CROSS_COMPILE=`xcode-select --print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/

realpath() {
    path=`eval echo "$1"`
    folder=$(dirname "$path")
    echo $(cd "$folder"; pwd)/$(basename "$path"); 
}
BASE_DIR=$(dirname "$(realpath "$0")")
BASE_PATH=$PATH

cd $BASE_DIR

if [ -d "$BASE_DIR/openssl" ]; then

  echo "opens ssl alredy cloned"
else
    git clone https://github.com/openssl/openssl.git
fi

cd openssl
OLD_PWD=$PWD

git clean -xdf
git submodule foreach --recursive git clean -xdf
git checkout $OPENSSL_TAG
git submodule update --init --recursive

GENERAL_OPTIONS="-fembed-bitcode -no-shared -no-tests -no-ui-console -no-ssl3 -no-comp -no-engine"

function build_for ()
{
  PLATFORM=$1
  CROSS_TOP_ENV=CROSS_TOP_$2
  CROSS_SDK_ENV=CROSS_SDK_$2
  
  echo "#####BUILD FOR $PLATFORM#####"

  export CROSS_TOP="${!CROSS_TOP_ENV}"
  export CROSS_SDK="${!CROSS_SDK_ENV}"
  export SSL_PREFIX_DIR=$BASE_DIR/$PLATFORM
  git clean -xdf
  git submodule foreach --recursive git clean -xdf
  rm -rdf $SSL_PREFIX_DIR

  echo "./Configure $GENERAL_OPTIONS $PLATFORM --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}"
  ./Configure $GENERAL_OPTIONS $PLATFORM --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
  
  echo "make -j12 
  make -j12 
  make install_sw 

  unset SSL_PREFIX_DIR
}

# Arm 32 build
build_for ios-cross IOS

# Arm 64 build
build_for ios64-cross IOS

# create configuration fpor build for simulators
patch Configurations/10-main.conf < ../patch-conf.patch
# Amd 64 build
build_for ios64sim-cross SIM
