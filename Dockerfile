FROM alpine:edge
MAINTAINER Chance Hudson <chance@commontheory.io>

RUN apk add --no-cache bash ncurses g++ automake make cmake openssl libressl-dev autoconf libtool python binaryen git gmp-dev gettext gettext-dev libintl doxygen linux-headers \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing mongo-c-driver-dev libbson-dev \
 && git config --global advice.detachedHead false

# Install secp256k1 binary
RUN git clone --depth 1 --single-branch https://github.com/cryptonomex/secp256k1-zkp.git /secp256k1-zkp \
 && cd /secp256k1-zkp \
 && bash autogen.sh \
 && ./configure \
 && make \
 && make install \
 && rm -rf /secp256k1-zkp

# Build llvm 5.0 (5.0 includes a fix for musl based libc)
RUN git clone --depth 1 --single-branch --branch release_50 https://github.com/llvm-mirror/llvm.git /llvm \
 && git clone --depth 1 --single-branch --branch release_50 https://github.com/llvm-mirror/clang.git /llvm/tools/clang \
 && cd /llvm \
 && cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=/opt/wasm -DLLVM_TARGETS_TO_BUILD= -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release  \
 && cmake --build build --target install \
 && rm -rf /llvm

# Build boost v1.67.0
RUN git clone --depth 1 --single-branch --branch boost-1.67.0 https://github.com/boostorg/boost /boost \
 && cd /boost \
 && git submodule update --init --recursive \
 && bash ./bootstrap.sh \
# Boost exits with status code 1 because of this issue https://stackoverflow.com/questions/12906829/failed-updating-58-targets-when-trying-to-build-boost-what-happened/16315499
 && ./b2 install --prefix=/usr --variant=release || true \
 && rm -rf /boost

# Build EOS
RUN git clone --depth 1 --single-branch --branch v1.2.4 https://github.com/EOSIO/eos.git \
 && mkdir /eos/build \
 && cd /eos/build \
 && git submodule update --init --recursive \
 && find /eos -type f -exec sed -i 's/find_package(LLVM 4.0/find_package(LLVM 5.0/g' {} + \
 && cmake -DLLVM_DIR=/opt/wasm/lib/cmake/llvm -DWASM_ROOT=/opt/wasm -DOPENSSL_ROOT_DIR=/usr/include/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib -DBUILD_MONGO_DB_PLUGIN=false -DCMAKE_BUILD_TYPE=Release .. \
 && make -j$( nproc )
