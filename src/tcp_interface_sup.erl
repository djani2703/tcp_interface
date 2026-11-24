%%%-------------------------------------------------------------------
%% @doc
%% TCP Interface Supervisor.
%%
%% This supervisor manages TCP server processes that use a listening socket.
%% Server workers are started dynamically via start_child/1 and are temporary,
%% so they are not restarted if they terminate.
%%
%% The supervisor uses a one_for_one strategy.
%% @end
%%%-------------------------------------------------------------------

-module(tcp_interface_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1]).
%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API
%%====================================================================

%% @doc Starts the TCP interface supervisor.
-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% @doc Starts a TCP server worker for the given listening socket.
-spec start_child(gen_tcp:socket()) -> supervisor:startchild_ret().
start_child(ListenSocket) ->
    ChildSpec =
        #{id => make_ref(),
          start => {tcp_interface_server, start_link, [ListenSocket]},
          restart => temporary,
          shutdown => brutal_kill,
          type => worker,
          modules => [tcp_interface_server]},
    supervisor:start_child(?SERVER, ChildSpec).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

-spec init(term()) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
init([]) ->
    SupFlags =
        #{strategy => one_for_one,
          intensity => 0,
          period => 1},
    {ok, {SupFlags, []}}.
