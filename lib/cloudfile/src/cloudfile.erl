%%% -*- erlang -*-
%%%-------------------------------------------------------------------
%%% @author Evangelos Pappas <epappas@evalonlabs.com>
%%% @copyright (C) 2014, evalonlabs
%%% Copyright 2015, evalonlabs
%%%
%%% Licensed under the Apache License, Version 2.0 (the 'License');
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an 'AS IS' BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(cloudfile).
-author("epappas").

%% API.
-export([start/0]).

%% API.
start() ->
    lager:start(),
    application:start(crypto),
    application:start(asn1),
    application:start(public_key),
    application:start(ssl),
    application:start(bcrypt),
    application:start(ranch),
    application:start(metrics),
    application:start(ssl_verify_fun),
    application:start(mimerl),
    application:start(certifi),
    application:start(hackney),
    couchbeam:start(), %% application:start(couchbeam),
    % application:start(couchbeam),

    application:start(cowlib),
    application:start(cowboy),
    application:start(erl_streams),
    application:start(cf_common),
    application:start(cfile),
    application:start(cfstore),
    application:start(cfuser),
    application:start(cloudfile).

    % hackney_trace:set_level(min),
    % ok = hackney_trace:enable(max, io).
