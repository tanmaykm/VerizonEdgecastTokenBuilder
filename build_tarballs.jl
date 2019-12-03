# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "VerizonEdgecastTokenBuilder"
version = v"0.1.0"

# Collection of sources required to build VerizonEdgecastTokenBuilder
sources = [
    "https://github.com/VerizonDigital/ectoken.git" =>
    "7b8812d476f5be5b290fe2832859b9b7636f43ae",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
tar -xzf *.tar.gz
export OPENSSL_INCLUDE="-I $WORKSPACE/srcdir/include"
export OPENSSL_LIBS="$WORKSPACE/srcdir/lib/libssl.a $WORKSPACE/srcdir/lib/libcrypto.a"
cd ectoken/c-ectoken/ecencrypt/
gcc -m64 -O2 -Wall -Werror -std=gnu99 ec_encrypt.c ectoken_v3.c base64.c -o 64/ectoken3 $OPENSSL_LIBS $OPENSSL_INCLUDE -lm
cp 64/ectoken3 $prefix/bin/
exit

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:musl),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "ectoken3", :ectoken3)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/OpenSSL-v1.1.1%2Bc%2B0/build_OpenSSL.v1.1.1+c.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

