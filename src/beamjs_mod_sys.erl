-module(beamjs_mod_sys).
-export([exports/1,init/1]).
-behaviour(erlv8_module).
-include_lib("erlv8/include/erlv8.hrl").

init(_VM) ->
	reloader:start().

exports(_VM) ->
	{beamjs,_,Version} = lists:keyfind(beamjs,1,application:which_applications()),
	?V8Obj([{"print", fun print/2},
			{"inspect", fun inspect/2},
			{"beamjs", ?V8Obj([{"version", Version},
							   {"reload", fun reload/2}])}]).

print(#erlv8_fun_invocation{ vm = VM} = _Invocation, [Expr]) ->
	io:format("~s",[erlv8_vm:to_detail_string(VM,Expr)]),
	undefined.

inspect(#erlv8_fun_invocation{ vm = VM} = _Invocation, [Expr]) ->
	lists:flatten(io_lib:format("~s",[beamjs_js_formatter:format(VM, Expr)])).

reload(#erlv8_fun_invocation{} = _Invocation, []) ->
	?V8Arr(lists:map(fun ({_,_}=O) -> ?V8Obj([O]) end,reloader:reload_modules(reloader:all_changed()))).
