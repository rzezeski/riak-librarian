-module(riak_librarian).
-compile(export_all).

%% @doc Given an XML `File', the top-level `ElementName' and the
%% `KeyField' create a list of key-value pairs.  The file should have
%% the following format.
%%
%% <ElementName>
%%   <field name="KeyField">...</field>
%%   <field name="...">...</field>
%%   ...
%% </ElementName>
%% ...
docs_from_file(File, ElementName, KeyField) ->
    {ok, Bin} = file:read_file(File),
    docs_from_bin(Bin, ElementName, KeyField).

docs_from_bin(Bin, ElementName, KeyField) when is_binary(ElementName),
                                               is_binary(KeyField) ->
    Size = size(ElementName),
    Chunks = binary:split(Bin, <<"</",ElementName:Size/binary,">\n">>, [global]),
    [ key_value(strip_start(Chunk, ElementName), KeyField) || Chunk <- Chunks].

key_value(Chunk, KeyField) ->
    Size = size(KeyField),
    Pat = <<"<field name=\"",KeyField:Size/binary,"\">(.*)</field>">>,
    {match, [Key]} = re:run(Chunk, Pat, [{capture, [1], binary}]),
    {Key, Chunk}.

strip_start(Chunk, ElementName) ->
    Size = size(ElementName),
    <<"<",ElementName:Size/binary,">\n",Rest/binary>> = Chunk,
    Rest.
