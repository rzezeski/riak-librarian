all: compile

compile:
	mkdir -p ebin
	erlc -o ebin riak_librarian.erl

clean:
	rm -rf ebin

