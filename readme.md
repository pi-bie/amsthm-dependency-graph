# amsthm-dependency-graph
A shell script for unix. 
It will exctract all custom defined amsthm environments from
a tex file, check for labels in these environments and then
output relations between these based on \ref's not preceded
by a % in the same line in the proof-environments, while
ignoring references to undefined labels/labels that have not
been assigned to amsthm environments.
The output will then be exported to a file in
[Graph Modelling Language](https://en.wikipedia.org/wiki/Graph_Modelling_Language).

# Usage
Make sure you have made the shell script executable.
Then run
```
./extract-ref.sh <infile> <outfile>
```
As parameters, you should supply a tex file as input file, and give the name of a gml file as output. Note that any existing file named outfile will be overwritten.

The file `foo.tex` provides a minimal working example.

You can then use tools as yEd or Gephi to view resulting graph.

Using [Graphviz](https://graphviz.org/), you might want to run
```
./extract-ref.sh foo.tex foo.gml
gml2gv foo.gml | dot -Tpng -o foo.png
```
to produce a png file showing the implications between the theorems of your tex file.

## Ideas for future features
* add shapes or colors depending on \theoremstyle
* consider references to equations, add support for \eqref
* consider bibliography items and add support for \cite etc.

## Possible issues
* only tested on Ubuntu 20.04.1 running GNU bash, Version 5.0.17(1)-release (x86_64-pc-linux-gnu)
* as the script does not parse the tex-file, the regex might not succeed in finding all defined environments, all labels and all (correct) references

