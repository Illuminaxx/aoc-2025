-module(fs_ffi).
-export([read/1]).

read(Path) ->
  case file:read_file(Path) of
    {ok, Bin} -> {ok, unicode:characters_to_list(Bin)};
    {error, Reason} -> {error, Reason}
  end.
