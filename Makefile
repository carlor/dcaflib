
CC=dmd
SRC_FILES = containers/lookahead.d text/json.d ui/terminal.d


all: build

build:
	$(CC) -c -odbin $(SRC_FILES)

doc:
	$(CC) -D -Dddocs -o- $(SRC_FILES)

