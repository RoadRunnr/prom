%%%-------------------------------------------------------------------
%% @doc prom public API
%% @end
%%%-------------------------------------------------------------------

-module(prom_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile(
		 [
		  {'_', [{"/metrics/[:registry]", prometheus_cowboy2_handler, []}]}
		 ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}],
				 #{env => #{dispatch => Dispatch}}),
    prom_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).

%% internal functions
