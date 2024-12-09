# NixOS System Configurations

The following taken from the original [README](https://github.com/mitchellh/nixos-config/blob/main/README.md)
still holds for this repository:

> This repository contains my NixOS system configurations. This repository
isn't meant to be a turnkey solution to copying my setup or learning Nix,
so I want to apologize to anyone trying to look for something "easy". I've
tried to use very simple Nix practices wherever possible, but if you wish
to copy from this, you'll have to learn the basics of Nix, NixOS, etc.
>
> I don't claim to be an expert at Nix or NixOS, so there are certainly
improvements that could be made! Feel free to suggest them, but please don't
be offended if I don't integrate them, I value having my config work over
having it be optimal.

This configuration is simpler than https://github.com/mitchellh/nixos-config
because my workflow is different. I don't use the VM setup (yet) so all that
part is unused for now.

This code uses simple templating to inject some information that you might not
want to have in a public repo. Look in the code for `@@<something>@@` to see
what you can configure or look at the [JSON schema](config.schema.json).
The [`secret/config.json`](secret/config.json) configuration file is encrypted
using [git-crypt](https://github.com/AGWA/git-crypt) so that it can be included
in the repo.

There's a more general way to handle users e.g. if you have a personal laptop
and a work machine with different users and you want the same configuration.
To do this, just provide a different value for the `@@system.user@@` configuration
property in your `secret/config.json`.

## How I Work

TODO

## Setup (macOS/Darwin)

This uses the [nix-darwin](https://github.com/LnL7/nix-darwin) project.
I manage as much as I can with Nix, e.g. apps, system settings,
Homebrew, etc. The configuration doesn't yet cover 100% of my set up though.

To utilize the Mac setup, first install Nix using some Nix installer.
There are two great installers right now:
[nix-installer](https://github.com/DeterminateSystems/nix-installer)
by Determinate Systems and [Flox](https://floxdev.com/). The point of both
for my configs is just to get the `nix` CLI with flake support installed.

Once installed, clone this repo and run `make`. If there are any errors,
follow the error message (some folders may need permissions changed,
some files may need to be deleted). That's it.

**WARNING: Don't do this without reading the source.** This repository
is and always has been _my_ configurations. If you blindly run this,
your system may be changed in ways that you don't want.
