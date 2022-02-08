#!/bin/bash

# Simplified version customized for mac. Originally from: https://github.com/DataDog/yubikey

### PREREQUISITES BEFORE ADDING KEY TO GIT
# 1. brew install expect gpg pinentry-mac ykman
# 2. The yubikey must already be configured for opengpg, see `gpg_yubikey.sh`

# sign all commits, global config
KEYID=$(gpg --card-status | ugrep "Signature key" | tr -d ' ' | cut -d ':' -f 2)
git config --global user.signingkey "$KEYID"
git config --global commit.gpgsign true
git config --global tag.forceSignAnnotated true
echo

## The NOTIFICATION message 
set +e
read -r -d '' NOTIFICATION_CMD << EOF
say 'sign!' && osascript -e 'display notification "git wants to sign a commit!" with title "Touch your YubiKey 🙈"'
gpg "\$@"
if [[ "\$?" -ne 0 ]]; then
    echo "Signing failed, exiting"
fi
echo "Sign completed"
EOF
set -e
NOTIFICATION_SCRIPT_PATH="$HOME/.local/bin/yubinotif"
echo -e "$NOTIFICATION_CMD" > "$NOTIFICATION_SCRIPT_PATH"
chmod u+x "$NOTIFICATION_SCRIPT_PATH"
git config --global --add gpg.program "$NOTIFICATION_SCRIPT_PATH"
echo "Global sign notification have been set up in git with $NOTIFICATION_SCRIPT_PATH"
echo

# EXPORT GPG public key to GITHUB.
echo "To export your GPG public key for use in GitHub, run the following command, and insert key on github.com"
echo "gpg --armor --export $KEYID"
echo

