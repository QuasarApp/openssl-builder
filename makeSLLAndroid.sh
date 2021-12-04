#!/bin/bash
#export ANDROID_NDK_ROOT=/some/where/android-ndk-10d

OPENSSL_TAG=OpenSSL_1_1_1l



export ANDROID_NDK_ROOT="$HOME/AndroidSDK/ndk/21.4.7075529"
export ANDROID_SDK_ROOT="$HOME/AndroidSDK"
export JAVA_HOME="/usr"
export ANDROID_HOME="$HOME/AndroidSDK"
export ANDROID_API_VERSION="27"
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT


BASE_DIR=$(dirname "$(readlink -f "$0")")
BASE_PATH=$PATH

cd $BASE_DIR

if [ -d "$BASE_DIR/openssl" ]; then

  echo "opens ssl alredy cloned"
else
    git clone https://github.com/openssl/openssl.git
fi

rm -rdf $BASE_DIR/amd64Build
rm -rdf $BASE_DIR/aarch64Build
rm -rdf $BASE_DIR/arm86Build
rm -rdf $BASE_DIR/amd86Build

cd openssl
OLD_PWD=$PWD

git clean -xdf
git submodule foreach --recursive git clean -xdf
git checkout $OPENSSL_TAG
git submodule update --init --recursive

export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$BASE_PATH

GENERAL_OPTIONS="-no-stdio -no-tests -no-ui-console -no-ssl2 -no-ssl3 -no-comp -no-hw -no-engine"

# Arm 64 build
export SSL_PREFIX_DIR=$BASE_DIR/aarch64Build

./Configure $GENERAL_OPTIONS android-arm64 -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=.so
make install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=.so

git clean -xdf
git submodule foreach --recursive git clean -xdf


# Arm 32 build
export SSL_PREFIX_DIR=$BASE_DIR/arm86Build

./Configure $GENERAL_OPTIONS android-arm -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=.so
make install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=.so

git clean -xdf
git submodule foreach --recursive git clean -xdf


# Amd 64 build
export SSL_PREFIX_DIR=$BASE_DIR/amd64Build

./Configure $GENERAL_OPTIONS android-x86_64 -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=.so
make install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=.so

git clean -xdf
git submodule foreach --recursive git clean -xdf

# Amd 64 build
export SSL_PREFIX_DIR=$BASE_DIR/amd86Build

./Configure $GENERAL_OPTIONS android-x86 -D__ANDROID_API__=$ANDROID_API_VERSION --prefix=${SSL_PREFIX_DIR} --openssldir=${SSL_PREFIX_DIR}
make -j${nproc} SHLIB_VERSION_NUMBER= SHLIB_EXT=.so
make install_sw SHLIB_VERSION_NUMBER= SHLIB_EXT=.so

git clean -xdf
git submodule foreach --recursive git clean -xdf
