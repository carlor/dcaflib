
CC=dmd
SRC_FILES = containers/lookahead.d containers/palindrome.d \
            text/json.d \
            ui/terminal.d


all: build

build:
	$(CC) -c -odbin $(SRC_FILES)

docs:
	$(CC) -D -Dddocs -o- $(SRC_FILES)

