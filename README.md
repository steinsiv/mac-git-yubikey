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
```
echo "pinentry-program $HOME/homebrew/bin/pinentry-mac" >> $HOME/.gnupg/gpg-agent.conf
```

## Configure Yubikey

see `mac_yubikey.sh`

## Add signing requirements to git config

see `gpg_gitconfig.sh`
