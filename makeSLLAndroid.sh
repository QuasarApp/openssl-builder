#!/bin/bash
#export ANDROID_NDK_ROOT=/some/where/android-ndk-10d

OPENSSL_TAG=openssl-3.0.9
OPENSSL_LIB_PREFIX=_3.so



export ANDROID_NDK_ROOT="$HOME/AndroidSDK/ndk/25.2.9519653"
export ANDROID_SDK_ROOT="$HOME/AndroidSDK"
export JAVA_HOME="/usr"
export ANDROID_HOME="$HOME/AndroidSDK"
export ANDROID_API_VERSION="26"
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT


BASE_DIR=$(dirname "$(readlink -f "$0")")
BASE_PATH=$PATH

cd $BASE_DIR

if [ -d "$BASE_DIR/openssl" ]; then

  echo "opens ssl alredy cloned"
else
    git clone https://github.com/openssl/openssl.git
fi

cd openssl
OLD_PWD=$PWD

git fetch
git clean -xdf
git checkout .
git submodule foreach --recursive git clean -xdf
git submodule foreach --recursive git checkout .
git checkout $OPENSSL_TAG
git submodule update --init --recursive

export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$BASE_PATH

GENERAL_OPTIONS="-no-tests -no-ui-console -no-ssl3 -no-comp -no-engine"

function build_for ()
{
  cd $BASE_DIR/openssl

  PLATFORM=$1
  echo "#####BUILD FOR $PLATFORM#####"

  export SSL_PREFIX_DIR=$BASE_DIR/$PLATFORM

  git clean -xdf
  git submodule foreach --recursive git clean -xdf
  rm -rdf $SSL_PREFIX_DIR

  echo "./Configure $GENERAL_OPTIONS $PLATFORM -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}"
  ./Configure $GENERAL_OPTIONS $PLATFORM -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
  
  echo "make -j$nproc "
  make -j$nproc build_libs
  make install_sw 

  cd $SSL_PREFIX_DIR/lib
  ln -s libcrypto.so libcrypto_android.so
  ln -s libssl.so libssl_android.so

  unset SSL_PREFIX_DIR
}

# Arm 64 build
build_for android-arm64

# Arm 32 build
build_for android-arm

# Amd 64 build
build_for android-x86_64

# Amd 64 build
build_for android-x86
