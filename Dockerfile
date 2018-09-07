FROM alpine:edge
MAINTAINER Chance Hudson

RUN apk add --no-cache git bash ncurses \
 && git clone https://github.com/EOSIO/eos.git \
 && cd /eos \
 && git config --global advice.detachedHead false \
 && git checkout tags/v1.2.4 \
 && git submodule update --init --recursive

RUN apk add --no-cache g++ automake make cmake llvm-dev llvm openssl libressl-dev autoconf libtool

# Install secp256k1 binary
RUN git clone https://github.com/bitcoin-core/secp256k1.git \
 && cd /secp256k1 \
 && bash ./autogen.sh \
 && bash ./configure \
 && make \
 && ./tests \
 && make install

RUN apk add --no-cache clang python
# RUN apk add --no-cache emscripten emscripten-libs-asmjs emscripten-libs-wasm --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN git clone https://github.com/WebAssembly/binaryen.git /binaryen \
 && cd /binaryen \
 && git checkout tags/1.38.12 \
 && cmake . \
 && make

# Install webassembly binary toolkit
RUN git clone --recursive https://github.com/WebAssembly/wabt /wabt \
 && cd /wabt \
 && git checkout tags/1.0.5 \
 && make clang-release

RUN mkdir /eos/build \
 && cd /eos/build \
 # && cmake -DBINARYEN_BIN=/eos/binaryen/bin -DWASM_ROOT=/eos/wasm-compiler/llvm -DOPENSSL_ROOT_DIR=/usr/include/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib -DBUILD_MONGO_DB_PLUGIN=true -DCMAKE_BUILD_TYPE=Release ..
