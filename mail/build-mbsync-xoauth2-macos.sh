#!/bin/sh
set -eu

WORKDIR="${TMPDIR:-/tmp}/mail-xoauth2-build"
PREFIX="$HOME/.emacs.d/local"

printf 'This builds a local mbsync with Cyrus SASL/XOAUTH2 support.\n'
printf 'It installs under %s and does not overwrite Homebrew mbsync.\n\n' "$PREFIX"

command -v brew >/dev/null || {
    printf 'Homebrew is required.\n' >&2
    exit 1
}

brew install cyrus-sasl autoconf automake libtool pkg-config openssl@3 berkeley-db@5 git

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR" "$PREFIX"
cd "$WORKDIR"

git clone --depth 1 https://github.com/moriyoshi/cyrus-sasl-xoauth2.git
cd cyrus-sasl-xoauth2
if [ -f autogen.sh ]; then
    sed -i.bak 's/libtoolize/glibtoolize/g' autogen.sh
fi
./autogen.sh
./configure --with-cyrus-sasl=/opt/homebrew/opt/cyrus-sasl
make
make install

cd "$WORKDIR"
curl -fsSL https://downloads.sourceforge.net/project/isync/isync/1.5.1/isync-1.5.1.tar.gz -o isync-1.5.1.tar.gz
tar -xzf isync-1.5.1.tar.gz
cd isync-1.5.1
CPPFLAGS="-I/opt/homebrew/opt/cyrus-sasl/include -I/opt/homebrew/opt/openssl@3/include -I/opt/homebrew/opt/berkeley-db@5/include" \
LDFLAGS="-L/opt/homebrew/opt/cyrus-sasl/lib -L/opt/homebrew/opt/openssl@3/lib -L/opt/homebrew/opt/berkeley-db@5/lib" \
./configure --prefix="$PREFIX" --with-sasl=/opt/homebrew/opt/cyrus-sasl --with-ssl=/opt/homebrew/opt/openssl@3
make
make install

printf '\nBuilt %s/bin/mbsync\n' "$PREFIX"
otool -L "$PREFIX/bin/mbsync"
printf '\nAdd this to your shell PATH, or let Emacs use it via mail-config.el:\n'
printf '  export PATH="%s/bin:$PATH"\n' "$PREFIX"
