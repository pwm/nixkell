# (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧ Nixkell (◕‿◕✿)

[![CI](https://github.com/pwm/nixkell/workflows/CI/badge.svg)](https://github.com/pwm/nixkell/actions)

Get your Haskell projects up and running with no fuss using Nix.

## TL;DR

Have [nix](https://nixos.org/) and [direnv](https://direnv.net/) installed:

```
$ git clone https://github.com/pwm/nixkell.git world && cd world
$ ./init.sh
$ hpack && cabal build
$ cabal run world
Hello world!
```

<p align="center">
  <img width="600" src="./assets/nixkell-600-12.gif?raw=true" alt="nixkell" />
</p>

## Table of Contents

* [Elevator pitch](#elevator-pitch)
* [Prerequisites](#prerequisites)
* [How to install](#how-to-install)
* [How to use](#how-to-use)
* [How it works](#how-it-works)
* [Learn some Nix!](#learn-some-nix)
* [Licence](#licence)

## Elevator pitch

The aim of Nixkell is to provide a seamless experience setting up Haskell projects utilising Nix. 

There are other tools for setting up Haskell projects, some of them with great user experience. Nix on the other hand historically had a reputation of being complicated, difficult to learn and not beginner friendly. So why do people use Nix despite its reputation? What are the benefits?

### 1. Nix shell

Having a dedicated per-project shell with all the tooling required to work on the project is a game-changer. You can `cd foo-project` and have everything ready to work on `foo`, then `cd ../bar-project` and have everything at hand to work on `bar`. This applies even within a single project. For example would you like to quickly upgrade or downgrade the version of GHC to test something? Just update it in `nixkell.toml`, `cabal build` and everything will automatically rebuild using the choosen version.

### 2. Nix shell for anyone else working on the project

It gets better. Anyone working on the project will have the same nix shell and thus the exact same tooling available. As a consequence the bar for contribution becomes a lot lower, as simply pulling a repo and entering nix shell sets the contributor up with everything they need to get hacking.

### 3. Reproducible builds

It gets even better. When building the project itself with nix it happens the same way with the same dependencies pinned to the same versions all around on everyone's machine. No more "Uhm, so how do I build this?".

### 4. Binary caches

You guessed it right, it gets even better. As a consequence of reproducibility, people can push the result of their builds into shared binary caches where others can pull from, saving a ton of time not having to build it themselves. This is how the 80,000+ strong nixpkgs are distributed from `cache.nixos.org` while "binary cache as a service" solutions, like [Cachix](https://cachix.org/), are lifting productivity to new levels.

I hope these points convinces you to give Nix and Nixkell a try.

## Prerequisites

MacOs specific notes: 
 - you will need the Xcode Command Line Tools
 - for M1 you might want to go through Rosetta

1. Install [Nix](https://nixos.org/)

```
$ sh <(curl -L https://nixos.org/nix/install)
$ nix --version
```

2. Install [direnv](https://direnv.net/):

```
$ nix-env -iA nixpkgs.direnv
$ direnv --version
```

3. Once direnv is installed you need to [enable it](https://direnv.net/docs/hook.html) in your shell!

4. Optional: Install [cachix](https://cachix.org/) to take advantage of Nixkell's own binary cache:

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use nixkell
```

## How to install

```
$ git clone https://github.com/pwm/nixkell.git my-project
$ cd my-project
$ ./init.sh
```

The purpose of `init.sh` is to turn the cloned Nixkell repository into your own. It will:

- Delete the `.git` directory (after making sure it's really Nixkell's) and initiate a new repo
- Reset `README.md` to an empty one with your project's name
- Set your project's name (my-project in the example) in all relevant files
- Create an `.envrc` file telling direnv to use nix and watch `nixkell.toml`, `package.yaml` and `nix/*` for changes
- Fire up the nix shell (note: this can take a while...)
- Finally it deletes itself as you won't need it anymore

The end result is a new haskell project, ready for you to get hacking! 

## How to use

From now on, every time you enter the project's directory direnv will automatically enter the nix shell. Fair warning: it is easy to get used to this :)

### Direnv

Other than loading the nix shell direnv also watches some files (via `.envrc`) so when those files are changed direnv will automatically rebuild your shell to reflect those changes. If, for any reason, you want to manually reload:
```
$ direnv reload
```

### Nixkell's config

A sensible next step is to open up `nixkell.toml`, Nixkell's config file, which is one of the files direnv watches. In there you will see a few options:

- The version of GHC to use
- Tooling you'd like available in your nix shell
- A set of files and paths to ignore by `nix-build`, meaning that nix won't rebuild anything when you change these.

### Haskell

By default Nixkell uses `package.yaml` to manage haskell dependencies and utilise `hpack` to compile it to cabal. If you rather use the cabal file directly then just run `hpack`, delete `package.yaml` and add the cabal file to `.envrc` for watching. I personally prefer editing the yaml file and auto-generate the cabal file but it's entirely optional.

The usual build cycle is:
```
$ hpack
$ cabal build
$ cabal run my-project
```

To test:
```
$ cabal test --test-show-details=direct
```

To add dependencies just put them into `package.yaml` as usual and direnv will rebuild automatically.

Side note: So why are we using cabal instead of nix to build you might ask? Well, why not both? :) Nix builds are reproducible which is amazing for all the reasons detailed in the elevator pitch and are ideal for your CI. As an example check `.github/workflows/nix.yml`. On the other hand nix builds are not incremental whilst cabal builds are. Thus, for local development, cabal leads to a nicer user experience as it will only rebuild what's necessary after a change. If you look in `nix/scripts.nix` you will see a few small scripts, one of which is `build`, a shorthand for `nix-build nix/release.nix` and another is `run` which is shorthand for `result/bin/my-project`. There are Nixkell's equivalent of `cabal build` and `cabal run my-project`, respectively. To build and run your project with nix:
```
$ hpack && build && run
```

### Direct hackage/github dependencies

To add something directly from hackage:
```
cabal2nix cabal://some-package-1.2.3.4 > nix/packages/some-package.nix
```
To add something directly from github:
```
cabal2nix https://github.com/some-user/some-package > nix/packages/some-package.nix
```

In both cases direnv will rebuild automatically. This works thanks to the [packagesFromDirectory](https://github.com/NixOS/nixpkgs/blob/54d306ae9a5e53147dfa56ee2530aeb0da638b89/pkgs/development/haskell-modules/lib.nix#L391-L392) function  used in our `packages.nix`.

To tweak things further you can add things to the manual section of `ourHaskell` in `packages.nix`, eg. say you want ot remove version bound checks on `some-package`:
```
some-package = pkgs.haskell.lib.doJailbreak(hprev.some-package);
```

### Updating nixpkgs

If you look into `nix/sources.json` you will see that packages there are pinned to exact git hashes. Reproducibility, yay! The sources file itself is managed by [niv](https://github.com/nmattia/niv), another tool in our nix shell. To update sources and thus rebuild your shell (as direnv is watching `nix/sources.json`):
```
$ niv update
```

## How it works

Most of the nix code in in `nix/`:

- `default.nix` - The `index.html` of the nix world. Called from `shell.nix` and `release.nix`
- `overlays.nix` - extends nixpkgs, most importantly with our own
- `packages.nix` - The meat, where our package is being assembled
- `release.nix` - points to our package, used by the `build` script
- `scripts.nix` - home for `build`, `run` and `logo`
- `sources.{json,nix}` - generated by Niv
- `util.nix` - some internal helper functions
- `shell.nix` (in the root) - entry point to the nix shell. Called by direnv upon entering the directory.

That's all there is to it really. Ultimately Nixkell is just a skeleton, a starting point. Once set up it's up to you to mould it to whatever shape your project dictates. It is also less than 200 lines of Nix code, making it easy to just dig in and learn a bit about Nix.

Happy hacking!

## Learn some Nix

I found these links particularly helpful for learning about Nix. In my opinion picking up the language part is easy for people already familiar with Haskell as they have a lot in common.

- [Nix: What Even is it Though](https://www.youtube.com/watch?v=6iVXaqUfHi4)
- [Nix language one-pager](https://github.com/tazjin/nix-1p)
- [An opinionated guide](https://nix.dev/)

## Licence

[MIT](LICENSE)
