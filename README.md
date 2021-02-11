# Nixkell

Get your Haskell projects up and running with no fuss using Nix.

## TL;DR

Have [nix](https://nixos.org/) and [direnv](https://direnv.net/) installed and:

```
$ git clone https://github.com/pwm/nixkell.git <my-new-project>
$ cd <my-new-project>
$ ./init.sh
$ build && run
Hello <my-new-project>!
```

## Table of Contents

* [Why Nixkell?](#why-nixkell)
* [Prerequisites](#Prerequisites)
* [Usage](#usage)
* [Learn some Nix](#learn-some-nix)
* [Licence](#licence)

## Why Nixkell?

The aim of Nixkell is to provide a seamless experience setting up Haskell projects utilising Nix. 

There are other tools for setting up Haskell projects, some of them with amazing user experience. On the other hand Nix historically had a reputation of being complicated, difficult to learn, not beginner friendly. So why do people use Nix given there are other tools with better UX? What are the benefits?

### 1. Nix shell for you

Having a dedicated per-project shell with all the tooling required to work on the project is a game-changer once you work on more than one project. You can `cd foo-project` and have everything ready to work on `foo` and then `cd ../bar-project` and have everything at hand to work on `bar`.

### 2. Nix shell for anyone else working on the project

It gets better. Anyone working on the project will have the same nix shell from #1 and thus the exact same tooling available. As a consequence the bar for contribution becomes a lot lower as simply pulling a repo and entering the nix shell sets the user up with everything they need to get hacking.

### 3. Reproducible builds

It gets even better. Not just the shell but building the project itself happens the same way with the same dependencies pinned to the same versions all around. No more "How do I build it on my machine?".

### 4. Binary caches

Yes, it gets even better! As a consequence of #3 people can push their builds into shared binary caches so that others can pull it saving a ton of time by not having to build it themselves. [Cachix](https://cachix.org/) is a popular example of this.

I hope this quick sales pitch convinced you to give Nix and Nixkell a try.

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

## Usage

TBD

## Learn some Nix

- [Nix: What Even is it Though](https://www.youtube.com/watch?v=6iVXaqUfHi4)
- [Nix language one-pager](https://github.com/tazjin/nix-1p)
- [An opinionated guide](https://nix.dev/)

## Licence

[MIT](LICENSE)
