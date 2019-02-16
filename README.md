# ANTLR Compiler (CMPT 379)

Four stages of developing an ANTLR-based compiler that targets the x86 architecture

# Pre-requisites

* openjdk-8-jdk
* graphviz
* ANTLR 4.5.3 (contained in lib/ folder)

# Usage

After modifying any .g4 file, run `make` to re-compile the source file. To remove all compiled java source files, run `make clean`.

# What I Learned

* Phases (lexing, syntax, semantics, intermediate codegen) of compilers
* DFAs, NFAs, regexs
* Writing context-free grammars
* Parse trees (Top-down vs bottom-up)
* Implementing scope, type hierarchy, control-flow for intermediate codegen
* Memory layout, call-return communication
* Local/peephole optimization