%%%-------------------------------------------------------------------
%% @doc
%% TCP Interface OTP application.
%%
%% On startup, the application opens a TCP listening socket on the configured
%% port (8080 by default), then starts the supervisor and TCP server process.
%% On shutdown, it closes the listening socket.
%% @end
%%%-------------------------------------------------------------------

-module(tcp_interface_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(DEFAULT_PORT, 8080).
-define(LISTEN_OPTS, [{active, true}, {reuseaddr, true}]).

%%====================================================================
%% Application callbacks
%%====================================================================

%% @doc Starts the TCP listener and its supervision tree.
-spec start(application:start_type(), term()) ->
               {ok, pid(), gen_tcp:socket()} | {error, term()}.
start(_StartType, _StartArgs) ->
    Port = application:get_env(tcp_interface, port, ?DEFAULT_PORT),
    case gen_tcp:listen(Port, ?LISTEN_OPTS) of
        {ok, ListenSocket} ->
            start_listener(ListenSocket);
        {error, Reason} ->
            {error, {listen_failed, Port, Reason}}
    end.

%% @doc Stops the application by closing its listening socket.
-spec stop(gen_tcp:socket()) -> ok.
stop(ListenSocket) ->
    gen_tcp:close(ListenSocket).

%%====================================================================
%% Internal functions
%%====================================================================

-spec start_listener(gen_tcp:socket()) -> {ok, pid(), gen_tcp:socket()} | {error, term()}.
start_listener(ListenSocket) ->
    case tcp_interface_sup:start_link() of
        {ok, Pid} ->
            start_acceptor(Pid, ListenSocket);
        ignore ->
            gen_tcp:close(ListenSocket),
            {error, supervisor_start_ignored};
        Error ->
            gen_tcp:close(ListenSocket),
            Error
    end.

-spec start_acceptor(pid(), gen_tcp:socket()) ->
                        {ok, pid(), gen_tcp:socket()} | {error, term()}.
start_acceptor(SupPid, ListenSocket) ->
    case tcp_interface_sup:start_child(ListenSocket) of
        {ok, _ChildPid} ->
            {ok, SupPid, ListenSocket};
        ignore ->
            gen_tcp:close(ListenSocket),
            {error, acceptor_start_ignored};
        Error ->
            gen_tcp:close(ListenSocket),
            Error
    end.
