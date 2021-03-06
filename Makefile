ERL         ?= erl
ERLC		?= erlc
REBAR       ?= ./rebar
EVAL        ?= "application:start(cloudfile)."
START       ?= cloudfile
NODE        ?= cloudfile
HOSTNAME    ?= `uname -n`
REBAR       ?= "./rebar"
CONFIG      ?= "cloudfile.config"
RUN         := $(ERL) -pa lib/*/ebin -pa deps/*/ebin -smp enable -boot start_sasl -config ${CONFIG} ${ERL_ARGS}

EVAL_IGNITION   = -eval ${EVAL};
START_IGNITION  = -s ${START}
IGNITION        = ${START_IGNITION}

all:
	${REBAR} get-deps compile

quick:
	${REBAR} skip_deps=true compile

clean:
	${REBAR} clean

quick_clean:
	${REBAR} skip_deps=true clean

release:
	${REBAR} get-deps compile generate

run: quick
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@${HOSTNAME} ${IGNITION}; \
	else ${RUN} ${IGNITION}; \
	fi

test:
	@$(ERLC) -o tests/ tests/*.erl
	prove -v tests/*.t tests/**/*.t
