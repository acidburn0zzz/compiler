CRYSTAL ?= crystal

COMMON_SOURCES = src/version.cr
LEXER_SOURCES = $(COMMON_SOURCES) src/definitions.cr src/errors.cr src/lexer.cr src/location.cr src/token.cr
PARSER_SOURCES = $(LEXER_SOURCES) src/parser.cr src/ast.cr
SEMANTIC_SOURCES = $(PARSER_SOURCES) src/semantic.cr src/semantic/*.cr
LLVM_SOURCES = src/llvm.cr src/c/llvm.cr src/c/llvm/*.cr src/c/llvm/transforms/*.cr \
			   src/ext/llvm/di_builder.o src/ext/llvm/di_builder.cr
CODEGEN_SOURCES = $(SEMANTIC_SOURCES) src/codegen.cr src/codegen/*.cr $(LLVM_SOURCES)

.PHONY: dist ext clean test

all: bin/runic libexec/runic-lex libexec/runic-ast libexec/runic-compile

ext:
	cd src/ext && make

dist:
	mkdir -p dist
	cp VERSION dist/
	cd dist && ln -sf ../src .
	cd dist && make -f ../Makefile CRFLAGS=--release
	rm dist/src
	mkdir dist/src && cp src/intrinsics.runic dist/src/

bin/runic: src/runic.cr $(COMMON_SOURCES)
	@mkdir -p bin
	$(CRYSTAL) build -o bin/runic src/runic.cr src/version.cr $(CRFLAGS)

libexec/runic-lex: src/commands/lex.cr $(LEXER_SOURCES)
	@mkdir -p libexec
	$(CRYSTAL) build -o libexec/runic-lex src/commands/lex.cr $(CRFLAGS)

libexec/runic-ast: src/commands/ast.cr $(SEMANTIC_SOURCES)
	@mkdir -p libexec
	$(CRYSTAL) build -o libexec/runic-ast src/commands/ast.cr $(CRFLAGS)

libexec/runic-compile: ext src/commands/compile.cr $(CODEGEN_SOURCES)
	@mkdir -p libexec
	$(CRYSTAL) build -o libexec/runic-compile src/commands/compile.cr $(CRFLAGS)

clean:
	rm -rf bin/runic libexec/runic-lex libexec/runic-ast libexec/runic-compile dist
	cd src/ext && make clean

test:
	$(CRYSTAL) run `find test -iname "*_test.cr"` -- --verbose
