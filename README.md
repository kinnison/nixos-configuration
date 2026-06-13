# NixOS Configuration for Daniel's systems

This repository hosts NixOS configuration, both host and user, for
me. This covers my personal laptops, desktops, etc. and also provides
a basis for any work machines I might want to use.

In addition, the home-manager modules are here to permit the configuration
of systems where I am not root.

# Licence terms

The file [`LICENCE.md`](LICENCE.md) details the licence terms for this repository.
In general the content herein is under the MIT licence, however portions may be
under their own licence if acquired from elsewhere. Please be careful when
incorporating any files into your own configs.

# Flake outputs

There are a number of `nixosConfigurations` which are the system configs
for my personal machines as well as a custom installer ISO and some test
VMs.

# How to use

If you have radicle, then you can acquire the repository by doing:

`rad clone rad:z2rxyrRCgCvYSUp5osYkuZHVv1Vzp`

If, on the other hand, you're without radicle (eg. setting up a new
system in panic mode, yes Daniel I mean you) or if you're using this
flake from another, then

`git clone https://radicle.infrafish.uk/z2rxyrRCgCvYSUp5osYkuZHVv1Vzp.git nixos-configuration`

will get you what you need.
