-module(riak_librarian).
-compile(export_all).
-define(MB, 1048576).

%% @doc Given an XML `File', the top-level `ElementName' and the
%% `KeyField' create a list of key-value pairs.  The file should have
%% the following format.
%%
%% <ElementName>
%%   <KeyField>...</KeyField>
%%   <Field2>...</Field2>
%%   ...
%% </ElementName>
%% ...

read_file_utf8(File) ->
    {ok, F} = file:open(File, [read,binary,{encoding,utf8}]),
    read_file_utf8(F, io:get_chars(F, '', ?MB), <<>>).

read_file_utf8(F, eof, Acc) ->
    file:close(F),
    Acc;
read_file_utf8(F, Bin, Acc) ->
    read_file_utf8(F, io:get_chars(F, '', ?MB), <<Acc/binary,Bin/binary>>).

load_dir(Dir, ElementName, KeyField) ->
    [File|Rest] = filelib:wildcard(filename:join([Dir, "*"])),
    io:format("FILE: ~p~n", [File]),
    Bin = read_file_utf8(File),
    Cache = docs_from_bin(Bin, ElementName, KeyField),
    {Cache, Rest}.

read_entry(_Op, {[KeyVal|Rest], Files}, _, _) ->
    {KeyVal, {Rest, Files}};

read_entry(_Op, {[], [File|Rest]}, ElementName, KeyField) ->
    io:format("FILE: ~p~n", [File]),
    Bin = read_file_utf8(File),
    Cache = docs_from_bin(Bin, ElementName, KeyField),
    read_entry(_Op, {Cache, Rest}, ElementName, KeyField);

read_entry(_Op, {[], []}, _, _) ->
    timer:sleep(1000),
    finished.

docs_from_bin(<<>>, _, _) ->
    [];

docs_from_bin(Bin, ElementName, KeyField) when is_binary(ElementName),
                                               is_binary(KeyField) ->
    Size = size(ElementName),
    Pat = <<"</",ElementName:Size/binary,">\n">>,
    Chunks = binary:split(Bin, Pat, [global]),
    io:format("# OF CHUNKS: ~p~n", [length(Chunks)]),
    [ key_value(add_end(Chunk, ElementName), KeyField)
      || Chunk <- Chunks, Chunk /= <<"">>].

key_value(Chunk, KeyField) ->
    Size = size(KeyField),
    Pat = <<"<",KeyField:Size/binary,">(.*)</",KeyField:Size/binary,">">>,
    %% io:format("pat ~p in chunk ~p~n", [Pat, Chunk]),
    {match, [Key]} = re:run(Chunk, Pat, [{capture, [1], binary}]),
    {Key, Chunk}.

add_end(Chunk, ElementName) ->
    <<Chunk/binary,"</",ElementName/binary,">\n">>.
