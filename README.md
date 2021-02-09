# Nixkell

A simple Haskell-Nix skeleton.

## Prerequisite

You will need [nix](https://nixos.org/) and [direnv](https://direnv.net/).

##### MacOS:

```
$ sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
$ nix-env --version
$ nix-env -iA nixpkgs.direnv
```

##### Linux:

```
$ bash <(curl -L https://nixos.org/nix/install)
$ nix-env --version
$ nix-env -iA nixpkgs.direnv
```

once done you have to [enable direnv in your shell](https://direnv.net/docs/hook.html).

## Usage

The following will set up a skeleton haskell project.

```
$ git clone git@github.com:pwm/nixkell.git <my-project>
$ cd <my-project>
$ ./init.sh
$ direnv allow
$ hpack
$ cabal2nix . > nix/packages/<my-project>.nix
$ direnv reload
$ nix-build nix/release.nix
$ result/bin/<my-project>
Hello <my-project>!
```

Happy hacking!
