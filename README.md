# (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧ Nixkell (◕‿◕✿)

[![CI](https://github.com/pwm/nixkell/workflows/CI/badge.svg)](https://github.com/pwm/nixkell/actions)

Get your Haskell projects up and running with no fuss using Nix.

## TL;DR

Have [nix](https://nixos.org/) and [direnv](https://direnv.net/) installed and:

```
$ git clone https://github.com/pwm/nixkell.git my-project
$ cd my-project
$ ./init.sh
$ build && run
Hello my-project!
```

## Table of Contents

* [Why Nixkell?](#why-nixkell)
* [Prerequisites](#Prerequisites)
* [How it all works?](#how-it-all-works)
* [Learn some Nix!](#learn-some-nix)
* [Licence](#licence)

## Why Nixkell?

The aim of Nixkell is to provide a seamless experience setting up Haskell projects utilising Nix. 

There are other tools for setting up Haskell projects, some of them with great user experience. Nix on the other hand historically had a reputation of being complicated, difficult to learn and not beginner friendly. So why do people use Nix despite its reputation? What are the benefits?

### 1. Nix shell

Having a dedicated per-project shell with all the tooling required to work on the project is a game-changer. You can `cd foo-project` and have everything ready to work on `foo`, then `cd ../bar-project` and have everything at hand to work on `bar`. This applies even within a single project. For example would you like to quickly upgrade or downgrade the version of GHC to test something? In Nixkell just update it in `nixkell.toml`, do `build` and everything will automatically rebuild using the updated version.

### 2. Nix shell for anyone else working on the project

It gets better. Anyone working on the project will have the same nix shell and thus the exact same tooling available. As a consequence the bar for contribution becomes a lot lower, as simply pulling a repo and entering the nix shell sets the contributor up with everything they need to get hacking.

### 3. Reproducible builds

It gets even better. Building the project itself happens the same way with the same dependencies pinned to the same versions all around. No more "Uhm, so how do I build this?".

### 4. Binary caches

You guessed it right, it gets even better. As a consequence of reproducibility, people can push the result of their builds into shared binary caches so that others can pull it, saving a ton of time not having to build it themselves. This is how the 80,000+ strong nixpkgs are distributed from `cache.nixos.org` while "binary cache as a service" solutions, like [Cachix](https://cachix.org/), are lifting productivity to new levels.

I hope this quick sales pitch convinces you to give Nix and Nixkell a try.

## Prerequisites

1. Install [nix](https://nixos.org/)

```
# For Linux and macOS < Catalina
$ sh <(curl -L https://nixos.org/nix/install)
```

```
# For macOS >= Catalina
$ sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
```

2. Verify nix and install [direnv](https://direnv.net/):

```
$ nix-env --version
$ nix-env -iA nixpkgs.direnv
```

3. Once direnv is installed you need to [enable it](https://direnv.net/docs/hook.html)  in your shell!

4. Optional: Install [cachix](https://cachix.org/) to take advantage of Nixkell's own binary cache:

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use nixkell
```

## How it all works?

Let's start with `./init.sh`. The purpose of this one-off script is to turn the cloned Nixkell repository into your own. It will:

- Delete the `.git` directory (after making sure it's really Nixkell's) and initiate a new repo
- Reset `README.md` to an empty one with your project's name
- Set your project's name in all relevant files
- Create an `.envrc` file telling direnv to use nix and watch `nixkell.toml` and `nix/sources.json`
- Fire up the nix shell (this could take a while...)
- Finally delete itself (as you won't need it anymore)

The result is a new haskell project, ready for you to get hacking! 

From now on every time you enter the project directory direnv will automatically enter the nix shell. Fair warning: Once you get used to this there is no turning back :)

A sensible next step is to open up `nixkell.toml`, the config file, in which you will see a few options to configure. These are:

- The version of GHC
- Tooling you'd like available in your nix shell
- A set of files and paths to ignore by `nix-build`, meaning that nix won't rebuild anything when you change them.

Direnv (via `.envrc`) is watching `nixkell.toml` and will automatically rebuild your nix shell whenever you edit it, say add new tooling to your env.

If you look in `nix/scripts.nix` you will see 3 tiny scripts. One is `logo` that prints a logo every time you enter the nix shell. The other two are `build` which is shorthand for `nix-build nix/release.nix` and `run` which is shorthand for `result/bin/my-project`. You can think of them as Nixkell's equivalent of `cabal build` and `cabal run my-project`.

By default we have `package.yaml` to manage project dependencies, however if you rather use `my-project.cabal` then just run `hpack`, which is available in the nix shell.

Cabal by default is also in the nix shell and can be used as usual:

```
$ hpack
$ cabal build
$ cabal run my-project
```

Note: Whilst Nix builds are reproducible, they are not incremental. For local development using Cabal arguably leads to a nicer user experiencee as it is incremental, meaning it will only rebuild what's necessary after a change. For small project it won't matter much whether you use nix (via `build`) or Cabal but for larger projects incremental rebuilds and thus Cabal is preferred for local development.

If you look into `nix/sources.json` you will see that they are pinned to exact git hashes. Reproducibility, yay! The sources file is managed by [niv](https://github.com/nmattia/niv), another tool in our nix shell. To update sources and thus rebuild your shell (as direnv is watching `nix/sources.json`):

```
$ niv update
```

As a bonus you also have a nixified CI for github actions ready to rock under `.github`.

Note: `init.sh` comments out the cachix action. To use it you need to create a cachix account and add your signing key to the repo secrets.

Finally a few words about the `nix/` directory itself:

- `default.nix` - The `index.html` of the nix world. Called from `shell.nix` and `release.nix`
- `overlays.nix` - extends nixpkgs, most importantly with our own
- `packages.nix` - The meat, where our package is being assembled
- `release.nix` - points to our package, used by `build`
- `scripts.nix` - home for `build`, `run` and `logo`
- `sources.{json,nix}` - generated by Niv
- `util.nix` - helper functions
- `shell.nix` (in the root) - entry point to the nix shell. Called by direnv upon entering the directory.

That's all there is to it really. Happy hacking!

## Learn some Nix

I found these links particularly helpful for learning about Nix. In my opinion picking up the language part is easy for people already familiar with Haskell as they have a lot in common.

- [Nix: What Even is it Though](https://www.youtube.com/watch?v=6iVXaqUfHi4)
- [Nix language one-pager](https://github.com/tazjin/nix-1p)
- [An opinionated guide](https://nix.dev/)

## Licence

[MIT](LICENSE)
