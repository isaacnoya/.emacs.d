# Outlook OAuth2 Direct With `oama`

Outlook/Hotmail and Microsoft 365 require OAuth2/Modern Auth for IMAP and SMTP.
`oama` handles authorization and token refresh for command-line mail tools.
This keeps the mail stack small: `mu4e` -> `mbsync`/`msmtp` -> Outlook.

## Install

`oama` is not available in Homebrew. Download the latest macOS `arm64` binary
from the official releases page:

```sh
https://github.com/pdobsan/oama/releases
```

Put the executable somewhere on `PATH`, for example:

```sh
mkdir -p ~/.local/bin
chmod +x ~/Downloads/oama
mv ~/Downloads/oama ~/.local/bin/oama
```

Make sure Emacs and your shell can find it:

```sh
oama --version
```

If `~/.local/bin` is not on `PATH`, either add it to your shell startup file or
use the full path in `~/.mbsyncrc` and `~/.msmtprc`.

## Configure

Create the initial configuration:

```sh
mkdir -p ~/.config/oama
oama template
```

Edit `~/.config/oama/config.yaml` and configure the builtin `microsoft` service.
For Microsoft device-code flow, `oama` needs a `client_id`; `client_secret` is
not needed for that flow.

For a personal Outlook/Hotmail account, the Thunderbird public client ID is a
practical starting point:

```yaml
services:
  microsoft:
     client_id: 9e5f94bc-e8a4-4e73-b8be-63364c29d753
```

Authorize the account:

```sh
oama authorize microsoft isaac_nv@hotmail.es --device
```

Check that `oama` can return a token:

```sh
oama access isaac_nv@hotmail.es
```

## Mail Tools

Install the local config examples if needed:

```sh
./mail/install-local-mail-config.sh
```

The important lines are:

```text
PassCmd "oama access isaac_nv@hotmail.es"
passwordeval oama access isaac_nv@hotmail.es
```

Then sync and index mail:

```sh
mbsync -a
mu init --maildir=~/Mail --my-address=isaac_nv@hotmail.es
mu index
```

After this, open `mu4e` in Emacs with `C-c m`.

The required Microsoft scopes are:

```text
offline_access
https://outlook.office.com/IMAP.AccessAsUser.All
https://outlook.office.com/POP.AccessAsUser.All
https://outlook.office.com/SMTP.Send
```

For a future university Microsoft 365 account, authorize it with a different
email address, add another account block to `~/.mbsyncrc`, another account to
`~/.msmtprc`, and another context in `elisp/mail-config.el`.
