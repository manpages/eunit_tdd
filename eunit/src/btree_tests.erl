-module(btree_tests).

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

mktree_simple_test() ->
	?debugHere,
	?assert (btree:mktree("A") =:= "A"),
ok.

mktree_tree_test() ->
	?debugHere,
	?assert (btree:mktree("A|B&(foo bar|D)") =:= 
		{"&", 
			{"|", "A", "B"}, 
			{"|", "foo bar", "D"}
		}
	),
ok.

mktree_malformed_test() ->
	?debugHere,
	?assertException (_, {syntax, _}, btree:mktree("A|")),
ok.
