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
-module(crypto_util).
-author("epappas").

%% API
-export([
  uuid/0,
  hashPass/3,
  hash_sha256/1
]).

uuid() ->
  uuid:to_string(uuid:uuid3(uuid:uuid4(), uuid:to_string(uuid:uuid1()))).

hashPass(Password, Salt, 0) ->
  hash_sha256(lists:concat([Password, Salt]));

hashPass(Password, Salt, Factor) when (Factor rem 2) > 0 ->
  hashPass(hash_sha256(lists:concat([Password, Salt])), Salt, Factor - 1);

hashPass(Password, Salt, Factor) ->
  hashPass(hash_sha256(lists:concat([Salt, Password])), Salt, Factor - 1).

hash_mail(Email) ->
    lists:concat([hash_sha256(Email), hash_md5(Email)]).

hash_sha256(Str) ->
  HashBin =  crypto:hash(sha256, Str),
  HashList = binary_to_list(HashBin),
  lists:flatten(list2hex(HashList)).

hash_md5(Str) ->
  HashBin =  crypto:hash(md5, Str),
  HashList = binary_to_list(HashBin),
  lists:flatten(list2hex(HashList)).

list2hex(List) -> lists:map(fun(X) -> int2hex(X) end, List).

int2hex(N) when N < 256 -> [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 -> $0+N;

hex(N) when N >= 10, N < 16 -> $a + (N-10).
