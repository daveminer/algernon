FROM elixir:1.13.4

RUN apt-get update && apt-get install -y inotify-tools

WORKDIR "/opt/app"

COPY mix.exs mix.lock ./
RUN mix local.hex --force --if-missing
RUN mix do deps.get, deps.compile

COPY . ./

ENTRYPOINT ["/bin/bash"]
