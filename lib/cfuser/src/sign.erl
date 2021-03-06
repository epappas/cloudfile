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
-module(sign).
-author("epappas").

%% API
-export([
    generate_rsa/1,
    generate_rsa/2,
    decode_rsa/1,
    decode_rsa/2,
    sign/2,
    sign/3,
    verify/3,
    verify/4,
    encrypt/2,
    decrypt/2
]).

%%%===================================================================
%%% API
%%%===================================================================

%% {privKey, RSA/Binary}
generate_rsa(private) -> generate_rsa(private, 2048).

generate_rsa(private, Bits) ->
    {ok, Out} = dcmd:run(io_lib:format("openssl genrsa ~p", [Bits])),
    case extract_PRIVRSA(Out) of
        [] -> {error, empty};
        Priv_RSA -> {privKey, iolist_to_binary(Priv_RSA)}
    end;

generate_rsa(public, RSAPrivateKey) ->
    {ok, Out} = dcmd:run(io_lib:format("echo \"~s\" | openssl rsa -pubout", [binary_to_list(RSAPrivateKey)])),
    case extract_PUBRSA(Out) of
        [] -> {error, empty};
        Pub_RSA -> {pubKey, iolist_to_binary(Pub_RSA)}
    end.

decode_rsa(PemBin) ->
    [RSAEntry] = public_key:pem_decode(PemBin),
    RSAKey = public_key:pem_entry_decode(RSAEntry),
    {ok, {key, RSAKey}}.

decode_rsa(PemBin, Password) ->
    [RSAEntry] = public_key:pem_decode(PemBin),
    RSAKey = public_key:pem_entry_decode(RSAEntry, Password),
    {ok, {key, RSAKey}}.

sign(Msg, RSAPrivateKey) -> {signature, public_key:sign(Msg, sha, RSAPrivateKey)}.
sign(Msg, Type, RSAPrivateKey) -> {signature, public_key:sign(Msg, Type, RSAPrivateKey)}.

verify(Msg, Signature, RSAPublicKey) -> public_key:verify(Msg, sha, Signature, RSAPublicKey).
verify(Msg, Type, Signature, RSAPublicKey) -> public_key:verify(Msg, Type, Signature, RSAPublicKey).

encrypt(Msg, {privKey, RSAPrivateKey}) -> public_key:encrypt_private(Msg, RSAPrivateKey);
encrypt(Msg, {public, RSAPublicKey}) -> public_key:encrypt_public(Msg, RSAPublicKey).

decrypt(Encrypted, {privKey, RSAPrivateKey}) -> public_key:decrypt_private(Encrypted, RSAPrivateKey);
decrypt(Encrypted, {public, RSAPublicKey}) -> public_key:decrypt_public(Encrypted, RSAPublicKey).

%%%===================================================================
%%% Internal functions
%%%===================================================================

extract_PRIVRSA(RSA_Input) ->
    RList = string:tokens(RSA_Input, "\n"),
    TargetStr = "-----BEGIN RSA PRIVATE KEY-----",
    Pred = fun(Elem) ->
        case string:equal(Elem, TargetStr) of
            true -> false;
            _ -> true
        end
    end,
    string:join(lists:dropwhile(Pred, RList), io_lib:format("~n", [])).

extract_PUBRSA(RSA_Input) ->
    RList = string:tokens(RSA_Input, "\n"),
    TargetStr = "-----BEGIN PUBLIC KEY-----",
    Pred = fun(Elem) ->
        case string:equal(Elem, TargetStr) of
            true -> false;
            _ -> true
        end
    end,
    string:join(lists:dropwhile(Pred, RList), io_lib:format("~n", [])).


%% Example of use
%% {privKey, RSAKey} = sign:generate_rsa(private).
%% {pubKey, RSAPubKey} = sign:generate_rsa(public, RSAKey).
%%
%% {keyey, RSAPrivateKey} = sign:decode_rsa(RSAKey).
%% {keyey, PubKey} = sign:decode_rsa(RSAPubKey).
%%
%% {signature, Signature} = sign:sign(<<"test">>, RSAPrivateKey).
%%
%% sign:verify(<<"test">>, Signature, PubKey) =:= true.
