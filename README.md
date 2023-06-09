# Set up a new machine

This is where I store files to be synched between machines.
Much of this is thanks to [Jake Weisler's videos here](https://www.youtube.com/watch?v=70YMTHAZyy4&list=PL1C97G3GhlHdANMFUIXTcFr14R7b7EBj9&pp=iAQB)

## Set up SSH keys

```
# Generate your ssh key
ssh-keygen -t ed25519
# Copy the key to Github
cat .ssh/id_ed25519.pub
```

## Install nix
Install nix (package manager) per https://nixos.org/download.html

## Setup profile
Run the `setup.sh` script

--- or ---
From the `dotfiles` directory, run `nix-env -irf packages.nix` to install the default profile packages.

From the `dotfiles` directory, run `stow <dir>` for each application config desired.
