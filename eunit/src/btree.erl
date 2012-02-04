-module(btree).

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

f(X) -> X+1. %shh

reg(reserved) -> "|\\-&()".

bnf(op) -> "(\\|-|&-|\\||&)";
bnf(terms) -> "(.+)";
bnf(term) -> "([^"++reg(reserved)++"]+)";
bnf(group) -> "\\((.+)\\)".

mktree(String) ->
	Opt = [{capture, all_but_first}],
	M = 
		case re:run(String, "\\(?"++bnf(group)++bnf(op)++bnf(group)++"\\)?", Opt) of
			{match, Positions} ->
				?debugMsg(String),
				{go_on, matches_to_strings(String, Positions)};

			nomatch -> case re:run(String, "\\(?"++bnf(group)++bnf(op)++bnf(terms)++"\\)?", Opt) of
				{match, Positions} ->
					?debugMsg(String),
					{go_on, matches_to_strings(String, Positions)};

				nomatch -> case re:run(String, "\\(?"++bnf(terms)++bnf(op)++bnf(group)++"\\)?", Opt) of
					{match, Positions} ->
						?debugMsg(String),
						{go_on, matches_to_strings(String, Positions)};

					nomatch -> case re:run(String, "\\(?"++bnf(terms)++bnf(op)++bnf(terms)++"\\)?", Opt) of
						{match, Positions} ->
							?debugMsg(String),
							{go_on, matches_to_strings(String, Positions)};

						nomatch -> case re:run(String, "\\(?"++bnf(term)++"\\)?", [{capture, all}]) of
							{match, Positions} ->
								?debugMsg(bnf(term)),
								?debugMsg(String),
								case string:len(String) > (erlang:element(2, head(Positions)) - erlang:element(1, head(Positions))) of
									true -> throw({syntax, String});
									false -> ok end,
								{terminate, matches_to_strings(String, [lists:nth(2, Positions)])};

							nomatch -> throw({syntax, String})
						end
					end
				end
			end
		end,
	case M of
		{go_on, [Left,Op,Right]} -> {Op, mktree(Left), mktree(Right)};
		{terminate, [Term]} -> Term;
		_ -> throw(major_flaw)
	end.
matches_to_strings(String, Positions) -> 
	?debugFmt("~p~n", [Positions]),
	lists:map (fun({O, L}) -> string:substr(String, O+1, L) end, Positions).

head([X|_]) -> X.


%	{match, M} = re:run("beer can fly and (beer is real)a", 
%		"(\\(.)", 
%		[{capture, all_but_first}]
%	),
%	lists:map (fun({O, L}) -> 
%		string:substr("beer can fly and (beer is real)", O+1, L) end, M
%	)
