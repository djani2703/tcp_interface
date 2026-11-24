%%%-------------------------------------------------------------------
%% @doc
%% TCP Interface server worker.
%%
%% Represents a single TCP listener and stores its listening socket in the
%% gen_server state.
%%
%% Workers are started dynamically by the TCP interface supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(tcp_interface_server).

-behaviour(gen_server).

%% API
-export([start_link/1]).
%% Gen Server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-type init_args() :: [gen_tcp:socket()].
-type state() :: #{listen_socket := gen_tcp:socket()}.

%%====================================================================
%% API
%%====================================================================

%% @doc Starts a TCP server process for the given listening socket.
-spec start_link(gen_tcp:socket()) -> {ok, pid()} | ignore | {error, term()}.
start_link(ListenSocket) ->
    gen_server:start_link(?MODULE, [ListenSocket], []).

%%====================================================================
%% Gen Server callbacks
%%====================================================================

-spec init(init_args()) -> {ok, state(), timeout()}.
init([ListenSocket]) ->
    {ok, #{listen_socket => ListenSocket}, 0}.

-spec handle_call(term(), gen_server:from(), state()) -> {reply, {ok, term()}, state()}.
handle_call(Message, _From, State) ->
    {reply, {ok, Message}, State}.

-spec handle_cast(term(), state()) -> {stop, normal, state()}.
handle_cast(stop, State) ->
    {stop, normal, State}.

-spec handle_info(term(), state()) -> {noreply, state()} | {stop, normal, state()}.
handle_info(timeout, #{listen_socket := ListenSocket} = State) ->
    {ok, _Socket} = gen_tcp:accept(ListenSocket),
    tcp_interface_sup:start_child(ListenSocket),
    {noreply, State};
handle_info({tcp, Socket, RawData}, State) ->
    gen_tcp:send(Socket, RawData),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State}.

-spec terminate(term(), state()) -> ok.
terminate(_Reason, _State) ->
    ok.

-spec code_change(term(), state(), term()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
