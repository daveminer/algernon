# Algernon

Demonstrations of [Axon](https://github.com/elixir-nx/axon) and [Nx](https://github.com/elixir-nx/nx).

# Environment Setup

```
brew install openssl@1.1 kerl gnupg \
  coreutils automake libyaml \
  readline libxslt libtool unzip curl
```

```
brew uninstall elixir erlang
```

```
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git

```

```
asdf plugin-update erlang
asdf plugin-update elixir
```

```
export CFLAGS="-O2 -g -fno-stack-check"
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --with-ssl=$(brew --prefix openssl@1.1)"
```

`asdf install`

might need this from project root: `asdf local elixir 1.13`



## Application Instructions

From the root directory:

Install the deps: `mix deps.get` 

Start an IEX session: `iex -S mix`

Run the test model: `iex(1)> BasicExample.start()`

The next example is under development: `SimpleMovingAverage.start()`
