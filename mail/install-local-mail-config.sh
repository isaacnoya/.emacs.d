#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

mkdir -p "$HOME/Mail/hotmail"
cp mail/mbsyncrc.example "$HOME/.mbsyncrc"
cp mail/msmtprc.example "$HOME/.msmtprc"
chmod 600 "$HOME/.mbsyncrc" "$HOME/.msmtprc"

printf 'Created %s\n' "$HOME/.mbsyncrc"
printf 'Created %s\n' "$HOME/.msmtprc"
printf 'Created %s\n' "$HOME/Mail/hotmail"
