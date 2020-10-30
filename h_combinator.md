```erlang
H = fun(C, P, T) -> F = fun(G, W, S) -> G(G, W, W(S)) end, D = fun(S) -> P(Z = C(), S), Z end, W = fun(S) -> receive quit -> exit(normal) after T -> D(S) end end, register(loop, spawn(fun()->F(F,W,undefined) end)) end.
```

```erlang
C = fun() -> [(maps:from_list(case process_info(P) of undefined -> []; L -> L end))#{pid => P} || P <- processes()] end.
```

```erlang
P = fun(_, undefined) -> ok; (S, Z) -> J = lists:foldl(fun(M,O) -> maps:get(message_queue_len, M, 0)+O end, 0, Z), io:fwrite("~p~n", [J]) end.
```

```erlang
H(C, P, 2000).
```
