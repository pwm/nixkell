# Nixkell

A simple Haskell-Nix skeleton.

## Prerequisites

You will need [nix](https://nixos.org/) and [direnv](https://direnv.net/).

```
# Linux
$ sh <(curl -L https://nixos.org/nix/install)
```

```
# MacOS
$ sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
```

Verify nix and install direnv:

```
$ nix-env --version
$ nix-env -iA nixpkgs.direnv
```

Once direnv is installed you need to [enable it in your shell](https://direnv.net/docs/hook.html).

## Usage

Setting up a new haskell project, eg. `my-project`, with its own env goes as:

```
$ git clone git@github.com:pwm/nixkell.git my-project
$ cd my-project # ignore the red direnv message
$ vim nixkell.toml # optional: set GHC version, etc...
$ ./init.sh
```

Once it finished setting up you can compile your project with:

```
$ comp
```

`comp` takes care of calling `hpack`, `cabal2nix` and `nix-build` for you.

Once compiled run the program with:

```
$ result/bin/my-project
Hello my-project!
```

Whenever you add new packages to the env in `nixkell.toml` run:

```
$ direnv reload
```

Otherwise just do your usual haskell dev flow!

Note: 
By default nixkell uses `package.yaml` but if you rather directly use `my-project.cabal` that's perfectly fine. Also by default `cabal` is available in the nix shell so instead of `comp` you can also just use cabal:

```
$ cabal build
$ cabal run -- my-project
```

## Learn some Nix

- [Nix: What Even is it Though](https://www.youtube.com/watch?v=6iVXaqUfHi4)
- [Nix language one-pager](https://github.com/tazjin/nix-1p)
- [An opinionated guide](https://nix.dev/)

Happy hacking!
