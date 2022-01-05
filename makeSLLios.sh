#!/bin/bash
#export ANDROID_NDK_ROOT=/some/where/android-ndk-10d

OPENSSL_TAG=OpenSSL_1_1_1l
OPENSSL_LIB_PREFIX=_1_1.so



TMP_DIR=../build_openssl
CROSS_TOP_SIM="`xcode-select --print-path`/Platforms/iPhoneSimulator.platform/Developer"
CROSS_SDK_SIM="iPhoneSimulator.sdk"

CROSS_TOP_IOS="`xcode-select --print-path`/Platforms/iPhoneOS.platform/Developer"
CROSS_SDK_IOS="iPhoneOS.sdk"

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

export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$BASE_PATH

GENERAL_OPTIONS="-no-stdio -no-tests -no-ui-console -no-ssl2 -no-ssl3 -no-comp -no-hw -no-engine"

function build_for ()
{
  PLATFORM=$1
  ARCH=$2
  CROSS_TOP_ENV=CROSS_TOP_$3
  CROSS_SDK_ENV=CROSS_SDK_$3
  
  echo "#####BUILD FOR $PLATFORM#####"

  export CROSS_TOP="${!CROSS_TOP_ENV}"
  export CROSS_SDK="${!CROSS_SDK_ENV}"
  export SSL_PREFIX_DIR=$BASE_DIR/$PLATFORM

  git clean -xdf
  git submodule foreach --recursive git clean -xdf
  rm -rdf $SSL_PREFIX_DIR

  echo "./Configure $GENERAL_OPTIONS $PLATFORM -arch $ARCH --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}"
  ./Configure $GENERAL_OPTIONS $PLATFORM -arch $ARCH --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
  
  echo "make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=$OPENSSL_LIB_PREFIX"
  make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=$OPENSSL_LIB_PREFIX
  make install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=$OPENSSL_LIB_PREFIX

  unset SSL_PREFIX_DIR
}

# Arm 32 build
build_for ios-cross armv7s IOS

# Arm 64 build
build_for ios64-cross arm64 IOS

