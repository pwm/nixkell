# Nixkell

install nix + direnv

```
git clone git@github.com:pwm/nixkell.git <my-project>
$ ./init.sh <my-project>
$ direnv allow
$ hpack
$ cabal2nix . > nix/packages/<my-project>.nix
$ direnv reload
$ nix-build nix/release.nix
$ result/bin/<my-project>
Hello <my-project>!
```
