# WIP yubikey howto
Setup git verified commits with yubikey on a mac

**brew installs**
```
brew install git gpg pinentry-mac ykman
```

## Add pinentry program to config and restart agent
```
echo "pinentry-program $(which pinentry-mac)" >> $HOME/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

# 1. setup Yubikey

## example yubikey config
```sh
❯ gpg --card-status
Reader ...........: Yubico YubiKey FIDO CCID
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Name of cardholder: Stein A Sivertsen
Language prefs ...: en
Salutation .......:
URL of public key : https://github.com/steinsiv.gpg
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 1067
KDF setting ......: off
Signature key ....: 158A CB5D 9E77 DB68 FC26  A841 3344 432E 7CFA 8C38
      created ....: 2021-05-27 17:11:31
Encryption key....: A6E7 9E0F 51FF AB15 BE49  1959 4956 7ACA 7141 ABBB
      created ....: 2021-05-27 17:11:31
Authentication key: 66C6 0E0F 52F1 3826 4BB0  ED99 C0BD EA37 55E8 8B3A
      created ....: 2021-05-27 17:11:31
General key info..: pub  rsa4096/3344432E7CFA8C38 2021-05-27 Stein A Sivertsen (YubiSiggit) <steinsiv@users.noreply.github.com>
sec>  rsa4096/3344432E7CFA8C38  created: 2021-05-27  expires: 2031-05-25
                                card-no: 0006 15791967
ssb>  rsa4096/C0BDEA3755E88B3A  created: 2021-05-27  expires: 2031-05-25
                                card-no: 0006 15791967
ssb>  rsa4096/49567ACA7141ABBB  created: 2021-05-27  expires: 2031-05-25
                                card-no: 0006 15791967
```

## setup
Before setup find yourself a `user-pin` and `admin-pin` and associate it with your yubikey serial number
```sh
ykman config usb -d otp
```


## reset openpgp factory settings
ykman openpgp reset

## create keys
```sh
gpg --card-edit
```

commands in edit mode
```
    1. admin
    2. passwd
    3. key-attr 
        Signature-Key - RSA 4096
        Encryption-Key - 4096
        Authentication-Key - 4096 
    4. name
    5. url https://github.com/steinsiv.gpg
    generate
        Stein A Sivertsen
        steinsiv@users.noreply.github.com
```
### Set the touch policy to touch required for sign
```sh
ykman openpgp keys set-touch sig on
```

### Set the touch policy to touch required for encryption
```sh
ykman openpgp keys set-touch enc on
```
### Export to github
```sh
gpg --list-keys
gpg --armor --export <KEYID>
```

# 2. example git config
```sh
❯ git config --global --list
user.email=steinsiv@users.noreply.github.com
user.name=Stein A Sivertsen
user.signingkey=09442A8B08CB61E8C3754EA2AA288CD2B6F83618
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
git config --global user.signingkey 09442A8B08CB61E8C3754EA2AA288CD2B6F83618
git config --global commit.gpgsign true
git config --global tag.forceSignAnnotated true
git config --global gpg.program "$HOME/.local/bin/yubikeysign"
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
in gpgsign program: `$HOME/.local/bin/yubikeysign` to get the final program
```sh
#!/bin/bash

/usr/bin/osascript -e 'display notification "GIT wants a signed commit!" with title "Touch YubiKey 🙈"' && say sign please && gpg "$@"

if [[ "$?" -ne 0 ]]; then
    echo "Signing failed, exiting"
fi
echo "Sign completed"
```

## Check usage
```sh
❯ echo "I know it's hard to believe so I will sign this" > msg.txt
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

## script to add signing requirements to git config

see `gpg_gitconfig.sh`
