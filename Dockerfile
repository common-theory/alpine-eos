FROM commontheory/alpine-llvm-4
MAINTAINER Chance Hudson <chance@commontheory.io>

# Install some packages and don't warn about detached head state
RUN apk add --no-cache bash ncurses g++ automake make cmake openssl openssl-dev autoconf libtool python binaryen git gmp-dev gettext gettext-dev libintl doxygen linux-headers libexecinfo-dev clang-dev --force \
 # && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing mongo-c-driver-dev libbson-dev \
 && git config --global advice.detachedHead false

# Install secp256k1 binary
RUN git clone --depth 1 --single-branch https://github.com/cryptonomex/secp256k1-zkp.git /secp256k1-zkp \
 && cd /secp256k1-zkp \
 && bash autogen.sh \
 && ./configure \
 && make \
 && make install \
 && rm -rf /secp256k1-zkp

# Build boost v1.67.0
RUN git clone --depth 1 --single-branch --branch boost-1.67.0 https://github.com/boostorg/boost /boost \
 && cd /boost \
 && git submodule update --init --recursive \
 && bash ./bootstrap.sh \
# Boost exits with status code 1 because of this issue
# https://stackoverflow.com/questions/12906829/failed-updating-58-targets-when-trying-to-build-boost-what-happened/16315499
 && ./b2 install --prefix=/usr --variant=release || true \
 && rm -rf /boost

# Clone EOS
RUN git clone --depth 1 --single-branch --branch v1.2.4 https://github.com/EOSIO/eos.git \
 && cd /eos \
 && git submodule update --init --recursive

RUN apk add --no-cache llvm-dev

# Build EOS
RUN mkdir /eos/build \
 && cd /eos/build \
 && cmake -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_CC_COMPILER=/usr/bin/clang -DLLVM_DIR=/usr/lib/cmake/llvm -DWASM_ROOT=/usr -DOPENSSL_ROOT_DIR=/usr/include/openssl -DBUILD_MONGO_DB_PLUGIN=false -DCMAKE_BUILD_TYPE=Release .. \
 && make
