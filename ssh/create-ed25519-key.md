You can create and configure an ED25519 key with the following command:

ssh-keygen -t ed25519 -C "<comment>"

The -C flag, with a quoted comment such as an email address, is an optional way to label your SSH keys.

Example:

ssh-keygen -t ed25519 -C "julianmr97@gmail.com"
