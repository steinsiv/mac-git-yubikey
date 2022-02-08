# yubikey howto
setup git verified commits with yubikey on a mac

**brew installs**
```
expect
gpg
pinentry-mac
ykman
```

## Add pinentry program to config
❯ cat .gnupg/gpg-agent.conf
```
# https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
pinentry-program /Users/SASIV/homebrew/bin/pinentry-mac
# For usability while balancing security, cache User PIN for at most a day.
default-cache-ttl 86400
max-cache-ttl 86400
```

## Configure Yubikey

see `mac_yubikey.sh`

## Add signing requirements to git config

see `mac_git.sh`
