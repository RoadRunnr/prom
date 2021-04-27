prom
=====

Very simple app to load prometheus.erl with synthetic data.

Build
-----

	$ rebar3 compile

Experiment
----------

```
> prom:gen(200000, 10).
Remaining:      100
ok

2> timer:tc(fun() -> prometheus_text_format:format(), ok end).
{9825835,ok}

3> Callback5 = fun (Registry, Collector) -> {Time, _} = timer:tc(fun() -> prometheus_collector:collect_mf(Registry, Collector, fun({T, _}) -> io:format("T: ~p~n", [T]), ok; (_) -> ok end) end), io:format("~p, ~p, ~p~n", [Time, Registry, Collector]) end.
#Fun<erl_eval.43.37215449>

4> timer:tc(fun() -> prometheus_registry:collect(default, Callback5) end).
87, default, prometheus_boolean
179, default, prometheus_counter
75, default, prometheus_gauge
1742844, default, prometheus_histogram
56, default, prometheus_mnesia_collector
40, default, prometheus_quantile_summary
60, default, prometheus_summary
33, default, prometheus_vm_dist_collector
224, default, prometheus_vm_memory_collector
263, default, prometheus_vm_msacc_collector
63, default, prometheus_vm_statistics_collector
1372, default, prometheus_vm_system_info_collector
{1746494,ok}
5>
```
