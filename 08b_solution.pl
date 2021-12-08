# vim: set filetype=prolog

# How to run:
# * load with SWI prolog interpreter (others might work, not tested),
#   e.g.: swipl -s 08b_solution.pl
# * issue: run(Solution).

run(Solution) :-
  read_patterns(Patterns),
  solve_all(Patterns, Outputs),
  !, % assume unique solution for each puzzle
  sum_numbers(Outputs, Solution).

read_patterns(Patterns) :-
  read_file_to_string("08input.txt", String, []),
  split_string(String, "\n", "\n", Lines),
  lines_to_patterns(Lines, Patterns).

lines_to_patterns([], []).
lines_to_patterns([Line|T], [Patterns|NT]) :-
  line_to_patterns(Line, Patterns),
  lines_to_patterns(T, NT).

line_to_patterns(Line, [InputPatterns, OutputPatterns]) :-
  split_string(Line, "|", " ", [InputString, OutputString]),
  segment_to_patterns(InputString, InputPatterns),
  segment_to_patterns(OutputString, OutputPatterns).

segment_to_patterns(String, Patterns) :-
  split_string(String, " ", " ", PatternStrings),
  parse_patterns(PatternStrings, Patterns).

parse_patterns([], []).
parse_patterns([H|T], [NH|NT]) :-
  parse_pattern(H, NH),
  parse_patterns(T, NT).

parse_pattern(String, Pattern) :-
  string_chars(String, Pattern).

%%%%%%%

sum_numbers(Outputs, Solution) :-
  sum_numbers_ctr(Outputs, 0, Solution).

sum_numbers_ctr([], C, C).
sum_numbers_ctr([H|T], C, Solution) :-
  get_as_number(H, Num),
  NewC is C + Num,
  sum_numbers_ctr(T, NewC, Solution).

% this is very roundabout, maybe there is a better way...
get_as_number(L, Num) :-
  atomic_list_concat(L, Atom),
  atom_string(Atom, String),
  number_string(Num, String).

%%%%%%%

solve_all([], []).
solve_all([H|T], [NH|NT]) :-
  [InputPatterns, OutputPatterns] = H,
  solve_single(InputPatterns, OutputPatterns, NH),
  solve_all(T, NT).

solve_single(InputPatterns, OutputPatterns, OutputDigits) :-
  match_wires(InputPatterns, Wires),
  match_outputs(OutputPatterns, Wires, OutputDigits).

% returns a permutation of wires such that:
% * the first element is the wire that goes to signal a
% * the second element is the wire that goes to signal b
% * etc.
match_wires(Patterns, Wires) :-
  permutation([a,b,c,d,e,f,g], Wires),
  match_patterns(Patterns, Wires).

match_patterns([], _).
match_patterns([H|T], Wires) :-
  match_pattern(H, Wires),
  match_patterns(T, Wires).

match_pattern(Pattern, Wires) :-
  % match signals A-G to wires
  [A, B, C, D, E, F, G] = Wires,
  (
    permutation(Pattern, [A, B, C, E, F, G]); % 0
    permutation(Pattern, [C, F]); % 1
    permutation(Pattern, [A, C, D, E, G]); % 2
    permutation(Pattern, [A, C, D, F, G]); % 3
    permutation(Pattern, [B, C, D, F]); % 4
    permutation(Pattern, [A, B, D, F, G]); % 5
    permutation(Pattern, [A, B, D, E, F, G]); % 6
    permutation(Pattern, [A, C, F]); % ]7
    permutation(Pattern, [A, B, C, D, E, F, G]); % 8
    permutation(Pattern, [A, B, C, D, F, G]) % 9
  ).

match_outputs([], _, []).
match_outputs([H|T], Wires, [NH|NT]) :-
  match_output(H, Wires, NH),
  match_outputs(T, Wires, NT).

match_output(Pattern, Wires, Digit) :-
  % match signals A-G to wires
  [A, B, C, D, E, F, G] = Wires,
  (
    (Digit = 0, permutation(Pattern, [A, B, C, E, F, G]));
    (Digit = 1, permutation(Pattern, [C, F]));
    (Digit = 2, permutation(Pattern, [A, C, D, E, G]));
    (Digit = 3, permutation(Pattern, [A, C, D, F, G]));
    (Digit = 4, permutation(Pattern, [B, C, D, F]));
    (Digit = 5, permutation(Pattern, [A, B, D, F, G]));
    (Digit = 6, permutation(Pattern, [A, B, D, E, F, G]));
    (Digit = 7, permutation(Pattern, [A, C, F]));
    (Digit = 8, permutation(Pattern, [A, B, C, D, E, F, G]));
    (Digit = 9, permutation(Pattern, [A, B, C, D, F, G]))
  ).
