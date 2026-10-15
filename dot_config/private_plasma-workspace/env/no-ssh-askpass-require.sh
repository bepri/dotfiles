#!/bin/sh
# Plasma sets SSH_ASKPASS_REQUIRE=prefer session-wide when ksshaskpass is
# installed, which makes ssh route passphrase prompts (including the YubiKey
# PIN prompt) through ksshaskpass. ksshaskpass can't parse the FIDO2
# "Enter PIN for authenticator:" prompt and spams the terminal. Unset it so
# ssh falls back to prompting on the tty directly.
unset SSH_ASKPASS_REQUIRE
