# WIP yubikey howto
Setup git verified commits with yubikey on a mac

**brew installs**
```
brew install git gpg expect pinentry-mac ykman
```

## Add pinentry program to config
```
echo "pinentry-program $(which pinentry-mac)" >> $HOME/.gnupg/gpg-agent.conf
```

## script for automatic configuration of Yubikey

see `mac_yubikey.sh`

## script to add signing requirements to git config

see `gpg_gitconfig.sh`

# example git config
```sh
❯ git config --global --list
user.email=steinsiv@users.noreply.github.com
user.name=Stein A Sivertsen
user.signingkey=158ACB5D9E77DB68FC26A8413344432E7CFA8C38
commit.gpgsign=true
tag.forcesignannotated=true
gpg.program=$HOME/.local/bin/yubikeysign
```

__**note** user.email and email on key must match!__

## create gpgsign program 
```sh
$HOME/.local/bin/yubikeysign
```

```sh
#!/bin/bash

/usr/local/bin/gpg "$@"
if [[ "$?" -ne 0 ]]; then
    echo "Signing failed, exiting"
fi
echo "Sign completed"

```

## configure git

```sh
❯ KEYID=$(gpg --card-status | ugrep "Signature key" | tr -d ' ' | cut -d ':' -f 2)
❯ git config --global user.signingkey "$KEYID"
❯ git config --global commit.gpgsign true
❯ git config --global tag.forceSignAnnotated true
❯ git config --global gpg.program "$HOME/.local/bin/yubikeysign"
```

## Add a reminder for signing
replace 
```sh
/usr/local/bin/gpg "$@"
```
with

```sh
/usr/bin/osascript -e 'display notification "GIT wants a signed commit!" with title "Touch YubiKey 🙈"' && say sign please && /usr/local/bin/gpg "$@"
```
in gpgsign program: `$HOME/.local/bin/yubikeysign` 

## Check usage
```sh
❯ echo "I know it's hard to believe so i will sign this" > msg.txt
❯ gpg -s -a msg.txt

❯ cat msg.txt.asc
-----BEGIN PGP MESSAGE-----

owEBfAKD/ZANAwAIATNEQy58+ow4Aaw1Ygdtc2cudHh0Y35/lGl0cyBoYXJkIHRv
IGJlbGlldmUgc28gaSB3aWxsIHNpZ24gdGhpcwqJAjMEAAEIAB0WIQQVistdnnfb
aPwmqEEzREMufPqMOAUCY35/lAAKCRAzREMufPqMOL30D/44H0e4ZrSyBx+yPpK4
u+q63Law4lzT2/0HpsipkbIdbw3ndPlYvhM3nq5sCh2gTS+JbBPgflafKzOBaSk5
ICbCeI471B+sSQHNd5nUHb41yqrn0l8AEZlojHB4PEqn1UliQZn2MHpXgtxNfAnT
SHE2wUZIbMGxeB6qEaSNYjolLafq6pYwkM8vXo6vK+Vf2prbI+mxX5m+lTsp3sUd
KUxu3xiyDqMjwVJeYxQGF4Ri5FcRDdC9mLtcqnp2Evk5JqZQFx6FPStNX1ICqivZ
6bj8nAE/yiGUf4XamWKwUpJZs+J7i7sJDkRipjvHboMB67FV6pco/vq5FgeF1lR/
l7dSlAWUQGiuSgv8QWOAFxbE+Y5iJCFFWA78/UpfhpSf/m7ZUGVyy98PpfKuHCjm
M17JBCFNyNrsoTvOF8+81NrenK9dLgAzI3pPhtwaGz2tD7txUwO0LUDBVPppwl81
6/YgsPDy6QpvyaRRPzZfKRLtJxD1Owm10jaIsk1cV8CEj6SmNP6zncsB2ndnUUkb
uepKSs0mCIJiQu7A/I1TNJFTVyLf/oTCJhiU8Di6tm/0E/6V5+bqIJwFmfugpVbu
yTOIKSVuOX/Db/DHayfzNuC4Ok9AZGXUGSUJQQ9BPQvpwHwN2JBY+6awDGCACxIO
LHGhbroV9utkN0S5MOvAfpVXdw==
=w7C8
-----END PGP MESSAGE-----
```
fetch public key from https://github.com/steinsiv.gpg and verify
