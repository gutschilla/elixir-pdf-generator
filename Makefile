NPM_VERSION := $(shell npm --version)
MIX_HELP    := $(shell mix help)

.PHONY: run-dev run-test
.SILENT: check_env

check_env:
ifndef NPM_VERSION
	$(error "npm required on path; SOLUTION: install nodejs https://nodejs.org/en/download/ -  should come with npm")
endif
ifndef MIX_HELP
	$(error "mix required on path; SOLUTION: install elixir https://www.erlang-solutions.com/resources/download.html - should come with mix")
endif
	echo "${NPM_VERSION} ${MIX_HELP}" > check_env

priv/node_modules: priv/package.json priv/package-lock.json
	cd priv && npm install

_build/dev: export MIX_ENV = dev
_build/dev: lib priv config/config.exs config/dev.exs
	mix compile

_build/test: export MIX_ENV = test
_build/test: lib priv config/config.exs config/test.exs
	mix compile

_build/prod: export MIX_ENV = prod
_build/prod: lib priv config/config.exs config/prod.exs
	mix compile

hex.info:
	mix hex.info > hex.info || mix local.hex --force && mix hex.info > hex.info

rebar.version:
	rebar3 version > rebar.version || mix local.rebar --force && rebar3 version > rebar.version

deps: mix.lock mix.exs # check_env hex.info rebar.version
	mix deps.get

# USER-RUNNABLE TARGETS

test: check_env _build/test
	mix test

run-test: check_env _build/test test
	mix test

run-dev: check_env _build/dev
	iex -S mix

build: check_env priv/node_modules _build/prod
