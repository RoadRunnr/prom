-module(prom).

-export([gen/2, cnt/2]).

-define(BASE_IP, 16#0A_00_00_00).
-define(BUCKETS, [10, 30, 50, 75, 100, 1000, 2000]).

gen(Paths, Probes) ->
    prometheus_histogram:deregister(gtp_path_rtt_milliseconds),
    prometheus_histogram:declare([{name, gtp_path_rtt_milliseconds},
				  {labels, [name, ip, version, type]},
				  {buckets, ?BUCKETS},
				  {duration_unit, false},
				  {help, "GTP path round trip time"}]),
    gen_path(Paths, Probes).

gen_path(0, _) ->
    io:format("\n"),
    ok;
gen_path(Paths, Probes) ->
    if (Paths rem 100 == 0) -> io:format("Remaining: ~8w\r", [Paths]);
       true -> ok
    end,
    IP = int2ip(ipv4, ?BASE_IP + Paths),
    Name = inet:ntoa(IP),
    Version = v1,
    Type = create,
    gen_probes(Probes, [Name, IP, Version, Type]),
    gen_path(Paths - 1, Probes).


gen_probes(0, _) ->
    ok;
gen_probes(Probes, Labels) ->
    %% {Min, Max} =
    %% 	case rand:uniform(length(?BUCKETS)) of
    %% 	    1 -> {0, hd(?BUCKETS)};
    %% 	    I -> {lists:nth(I - 1, ?BUCKETS), lists:nth(I, ?BUCKETS)}
    %% 	end,
    %% RTT = Min + rand:uniform(Max - Min) - 1,
    RTT = rand:uniform(2100),
    prometheus_histogram:observe(
      gtp_path_rtt_milliseconds, Labels, RTT),
    gen_probes(Probes - 1, Labels).


cnt(Paths, Probes) ->
    prometheus_counter:deregister(gtp_path_messages_duplicates_total),
    prometheus_counter:declare([{name, gtp_path_messages_duplicates_total},
				{labels, [name, ip, version, type]},
				{help, "GTP path round trip time"}]),
    cnt_path(Paths, Probes).

cnt_path(0, _) ->
    io:format("\n"),
    ok;
cnt_path(Paths, Probes) ->
    if (Paths rem 100 == 0) -> io:format("Remaining: ~8w\r", [Paths]);
       true -> ok
    end,
    IP = int2ip(ipv4, ?BASE_IP + Paths),
    Name = inet:ntoa(IP),
    Version = v1,
    Type = create,
    Labels = [Name, IP, Version, Type],
    prometheus_counter:inc(gtp_path_messages_duplicates_total, Labels, rand:uniform(Probes)),
    cnt_path(Paths - 1, Probes).

int2ip(ipv4, IP) ->
    <<A:8, B:8, C:8, D:8>> = <<IP:32>>,
    {A, B, C, D};
int2ip(ipv6, IP) ->
    <<A:16, B:16, C:16, D:16, E:16, F:16, G:16, H:16>> = <<IP:128>>,
    {A, B, C, D, E, F, G, H}.
