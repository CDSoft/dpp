% DPP - Diagram preprocessor (with pandoc in mind)
% Christophe Delord - <http://cdsoft.fr/pp>
% \exec{LANG=en date -r $(ls -t src/dpp.md src/dpp.c | head -1) +"%A %d %B %Y"}

[PP]: http://cdsoft.fr/pp "PP - Generic Preprocessor (for Pandoc)"
[DPP]: http://cdsoft.fr/pp "DPP - Diagram Preprocessor (for Pandoc)"
[dpp.tgz]: http://cdsoft.fr/dpp/dpp.tgz
[GraphViz]: http://graphviz.org/
[PlantUML]: http://plantuml.sourceforge.net/
[ditaa]: http://ditaa.sourceforge.net/
[GPP]: http://en.nothingisreal.com/wiki/GPP
[Pandoc]: http://pandoc.org/
[Bash]: https://www.gnu.org/software/bash/
[Bat]: https://en.wikipedia.org/wiki/Cmd.exe
[Python]: https://www.python.org/
[Haskell]: https://www.haskell.org/
[GitHub]: https://github.com/CDSoft/dpp

DPP - Diagram preprocessor (with pandoc in mind)
================================================

Initially, the [PP] package contained three preprocessors for [Pandoc].

I started using Markdown and [Pandoc] with [GPP].
Then I wrote [DPP] to embed diagrams in Markdown documents.
And finally [PP] which merges the functionalities of [GPP] and [DPP].

[GPP] and [DPP] are not included anymore in [PP] as `pp` can be used standalone.

[DPP] just contains `dpp` itself as well as [GPP].

`dpp` is obsolete, please consider using [PP] instead.

Open source
===========

[DPP] is an Open source software.
Any body can contribute on [GitHub] to:

- suggest or add new functionalities
- report or fix bugs
- improve the documentation
- add some nicer examples
- find new usages
- ...

Installation
============

1. Download and extract [dpp.tgz].
2. Run `make`.
3. Copy `dpp` and `gpp` (`.exe` files on Windows) where you want.

`dpp` require [Graphviz] and Java ([PlantUML] and [ditaa] are embedded in `dpp`).

Usage
=====

`dpp` is a filter and has no options.
It takes some text with embedded diagrams on `stdin` and generates a text with image links on `stdout`.
Some error messages may be written to `stderr`.

~~~~~ dot doc/img/dpp-pipe1
digraph {
    rankdir = LR
    INPUT [label="input documents" shape=folder color=blue]
    DPP [label=dpp shape=diamond]
    OUTPUT [label="output document" shape=folder color=blue]
    IMG [label="images" shape=folder color=blue]
    ERROR [label="error messages" shape=folder color=red]

    {rank=same; IMG OUTPUT ERROR}

    INPUT -> DPP [label=stdin]
    DPP -> OUTPUT [label=stdout]
    DPP -> IMG [label="file system"]
    DPP -> ERROR [label=stderr]
    IMG -> OUTPUT [label="hyper links"]
}
~~~~~

Being a filter, `dpp` can be chained with other preprocessors.
Another good generic purpose preprocessor is `pp` or `gpp`.

A classical usage of `dpp` along with `gpp` and [Pandoc] is:

~~~~~ dot doc/img/dpp-pipe2
digraph {
    rankdir = LR
    INPUT [label="input documents" shape=folder color=blue]
    PP [label=gpp shape=diamond]
    DPP [label=dpp shape=diamond]
    PANDOC [label=pandoc shape=diamond]
    IMG [label="images" shape=folder color=blue]
    OUTPUT [label="output document" shape=folder color=blue]

    {rotate=90; rank=same; PP DPP PANDOC}
    {rank=same; IMG OUTPUT}

    INPUT -> PP [label=stdin]
    PP -> DPP [label=stdout]
    DPP -> IMG [label="file system"]
    DPP -> PANDOC [label=stdout]
    PANDOC -> OUTPUT [label=stdout]
    IMG -> OUTPUT [label="hyper links"]
}
~~~~~

For instance, on any good Unix like system, you can use this command:

~~~~~ {.bash}
$ gpp documents... | dpp | pandoc -f markdown -t html5 -o document.html
~~~~~

Design
------

`dpp` was initially a preprocessor for [GraphViz] diagrams.
It now also comes with [PlantUML], [ditaa] and scripting capabilities.
`dpp` requires [GraphViz] and Java to be installed,
[PlantUML] and [ditaa] are embedded in `dpp`.

Optionally, `dpp` can call [Bash], [Bat], [Python] or [Haskell] to execute general scripts.

~~~~~ uml doc/img/dpp-design

package DPP {
    stdin -> [Main Processor]
    [Main Processor] -> stdout
    [PlantUML.jar]
    [ditaa.jar]
}

node "Operating System" {
    [GraphViz]
    [Java]
    [Bash]
    [Bat]
    [Python]
    [Haskell]
}

database "Filesystem" {
    folder "input" {
        [Markdown with diagrams]
    }
    folder "output" {
        [images]
        [Markdown with image links]
    }
}

[Markdown with diagrams] --> stdin
[Main Processor] --> [GraphViz]
[Main Processor] --> [Java]
[Main Processor] --> [Bash]
[Main Processor] --> [Bat]
[Main Processor] --> [Python]
[Main Processor] --> [Haskell]
[Java] --> [PlantUML.jar]
[Java] --> [ditaa.jar]
stdout --> [Markdown with image links]
[GraphViz] --> [images]
[PlantUML.jar] -> [images]
[ditaa.jar] -> [images]
[Bash] -> stdout
[Bat] -> stdout
[Python] -> stdout
[Haskell] -> stdout

~~~~~

~~~~~ uml doc/img/dpp-design2

box "input" #Green
    participant stdin
end box
box "DDP" #LightBlue
    participant DPP
    participant "PlantUML or ditaa"
end box
box "external dependencies" #Yellow
    participant Java
    participant GraphViz
    participant "script languages"
end box
box "outputs" #Green
    participant stdout
    participant images
end box

group Normal text line
    stdin -> DPP : non diagram text line
    activate DPP
    DPP -> stdout : unmodified line
    deactivate DPP
end
...
group GraphViz diagram
    stdin -> DPP : diagram
    activate DPP
    DPP -> GraphViz : call
    activate GraphViz
    GraphViz -> images : PNG image
    deactivate GraphViz
    DPP -> stdout : hyper link
    deactivate DPP
end
...
group "PlantUML or ditaa" diagram
    stdin -> DPP : diagram
    activate DPP
    DPP -> Java : call
    activate Java
    Java -> "PlantUML or ditaa" : call
    activate "PlantUML or ditaa"
    "PlantUML or ditaa" -> images : PNG image
    deactivate "PlantUML or ditaa"
    deactivate Java
    DPP -> stdout : hyper link
    deactivate DPP
end
...
group script languages (Bash, Bat, Python or Haskell)
    stdin -> DPP : script
    activate DPP
    DPP -> "script languages" : call
    activate "script languages"
    "script languages" -> stdout : script output
    deactivate "script languages"
    deactivate DPP
end

~~~~~

Syntax
======

## Diagrams

Diagrams are written in code blocks.
The first line contains:

- the diagram generator
- the image name (without the extension)
- the legend (optional)

Block delimiters are made of three or more tilda or back quotes, at the beginning of the line (no space and no tab).
Both lines must have the same number of tilda or back quotes.

    ~~~~~ dot path/imagename optional legend
    graph {
        "source code of the diagram"
    }
    ~~~~~

This extremely meaningful diagram is rendered as `path/imagename.png`
and looks like:

~~~~~ dot doc/img/dpp-syntax optional legend
graph {
    "source code of the diagram"
}
~~~~~

The image link in the output markdown document may have to be different than the
actual path in the file system. This happens when then `.md` or `.html` files are not
generated in the same path than the source document. Brackets can be used to
specify the part of the path that belongs to the generated image but not to the
link in the output document. For instance a diagram declared as:

    ~~~~~ dot [mybuildpath/]img/diag42
    ...
    ~~~~~

will be actually generated in:

    mybuildpath/img/diag42.png

and the link in the output document will be:

    img/diag42.png

For instance, if you use Pandoc to generate HTML documents with diagrams in a
different directory, there are two possibilities:

1. the document is a self contained HTML file (option `--self-contained`), i.e.
   the CSS and images are stored inside the document:
    - the CSS path shall be the actual path where the CSS file is stored
    - the image path in diagrams shall be the actual path where the images are
      stored (otherwise Pandoc won't find them)
    - e.g.: `outputpath/img/diag42`

2. the document is not self contained, i.e. the CSS and images are stored apart
   from the document:
    - the CSS path shall be relative to the output document
    - the image path in diagrams shall be relative to output document in HTML
      links and shall also describe the actual path where the images are stored.
    - e.g.: `[outputpath/]img/diag42`

The diagram generator can be:

- dot
- neato
- twopi
- circo
- fdp
- sfdp
- patchwork
- osage
- uml
- ditaa

`dpp` will not create any directory, the path where the image is written must already exist.

~~~~~ dot doc/img/dpp-generators
digraph {

    subgraph cluster_cmd {
        label = "diagram generators"
        dot neato twopi circo fdp sfdp patchwork osage uml ditaa
    }

    DPP [shape=diamond]
    dot neato twopi circo fdp sfdp patchwork osage uml ditaa
    GraphViz [shape=box]
    PlantUML [shape=box]
    DITAA [shape=box label=ditaa]

    DPP -> {dot neato twopi circo fdp sfdp patchwork osage uml ditaa}
    dot -> GraphViz
    neato -> GraphViz
    twopi -> GraphViz
    circo -> GraphViz
    fdp -> GraphViz
    sfdp -> GraphViz
    patchwork -> GraphViz
    osage -> GraphViz
    uml -> PlantUML
    ditaa -> DITAA
}
~~~~~

## Scripts

Scripts are also written in code blocks.
The first line contains only the kind of script.

    ~~~~~ bash
    echo Hello World!
    ~~~~~

With no surprise, this script generates:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~ bash
echo Hello World!
~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The script language can be:

- bash (or sh)
- bat (DOS/Windows batch language)
- python
- haskell

`dpp` will create a temporary script before calling the associated interpretor.

~~~~~ dot doc/img/dpp-scripts
digraph {

    subgraph cluster_cmd {
        label = "script languages"
        bash sh bat python haskell
    }

    DPP [shape=diamond]
    bash sh bat python haskell
    Bash [shape=box label="bash\nor bash.exe"]
    Sh [shape=box label="sh\nor sh.exe"]
    Bat [shape=box label="wine cmd /c\nor cmd /c"]
    Python [shape=box label="python\nor python.exe"]
    Haskell [shape=box label="runhaskell\nor runhaskell.exe"]

    DPP -> {bash sh bat python haskell}
    bash -> Bash
    sh -> Sh
    bat -> Bat
    python -> Python
    haskell -> Haskell
}
~~~~~

## Verbatim copy

Blocks can also contain verbatim text that is preserved in the output.

    `````````` quote
    ~~~ bash
    # this bash script example won't be executed!
    # but only colorized by Pandoc.
    ~~~
    ``````````

becomes

`````````` quote
~~~ bash
# this bash script example won't be executed!
# but only colorized by Pandoc.
~~~
``````````

Examples
========

The [source code](dpp.md) of this document contains some diagrams.

Here are some simple examples.
For further details about diagrams' syntax, please read the documentation of
[GraphViz], [PlantUML] and [ditaa].

## Graphviz

[GraphViz] is executed when one of these keywords is used:
`dot`, `neato`, `twopi`, `circo`, `fdp`, `sfdp`, `patchwork`, `osage`

    ~~~~~ twopi doc/img/dpp-graphviz-example This is just a GraphViz diagram example
    digraph {
        O -> A
        O -> B
        O -> C
        O -> D
        D -> O
        A -> B
        B -> C
        C -> A
    }
    ~~~~~

- `twopi` is the kind of graph (possible graph types: `dot`, `neato`, `twopi`, `circo`, `fdp`, `sfdp`, `patchwork`).
- `doc/img/dpp-graphviz-example` is the name of the image. `dpp` will generate `doc/img/dpp-graphviz-example.dot` and `doc/img/dpp-graphviz-example.png`.
- the rest of the first line is the legend of the graph.
- other lines are written to `doc/img/dpp-graphviz-example.dot` before running [Graphviz].

You can use `dpp` in a pipe before [Pandoc][] (as well as `pp` or `gpp`) for instance):

~~~~~ {.bash}
pp file.md | dpp | pandoc -s -S --self-contained -f markdown -t html5 -o file.html

or

cat file.md | gpp -T -x | dpp | pandoc -s -S --self-contained -f markdown -t html5 -o file.html
~~~~~

Once generated the graph looks like:

~~~~~ twopi doc/img/dpp-graphviz-example This is just a GraphViz diagram example
digraph {
    O -> A
    O -> B
    O -> C
    O -> D
    D -> O
    A -> B
    B -> C
    C -> A
}
~~~~~

[GraphViz] must be installed.

## PlantUML

[PlantUML] is executed when the keyword `uml` is used.
The lines `@startuml` and `@enduml` required by [PlantUML] are added by `dpp`.

    ~~~~~ uml doc/img/dpp-plantuml-example This is just a PlantUML diagram example
    Alice -> Bob: Authentication Request
    Bob --> Alice: Authentication Response
    Alice -> Bob: Another authentication Request
    Alice <-- Bob: another authentication Response
    ~~~~~

Once generated the graph looks like:

~~~~~ uml doc/img/dpp-plantuml-example This is just a PlantUML diagram example
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response
Alice -> Bob: Another authentication Request
Alice <-- Bob: another authentication Response
~~~~~

[PlantUML](http://plantuml.sourceforge.net) is written in Java and is embedded in `dpp`.
Java must be installed.

## Ditaa

[ditaa] is executed when the keyword `ditaa` is used.

    ~~~~~ ditaa doc/img/dpp-ditaa-example This is just a Ditaa diagram example
        +--------+   +-------+    +-------+
        |        | --+ ditaa +--> |       |
        |  Text  |   +-------+    |diagram|
        |Document|   |!magic!|    |       |
        |     {d}|   |       |    |       |
        +---+----+   +-------+    +-------+
            :                         ^
            |       Lots of work      |
            +-------------------------+
    ~~~~~

Once generated the graph looks like:

~~~~~ ditaa doc/img/dpp-ditaa-example This is just a Ditaa diagram example
    +--------+   +-------+    +-------+
    |        | --+ ditaa +--> |       |
    |  Text  |   +-------+    |diagram|
    |Document|   |!magic!|    |       |
    |     {d}|   |       |    |       |
    +---+----+   +-------+    +-------+
        :                         ^
        |       Lots of work      |
        +-------------------------+
~~~~~

[ditaa](http://plantuml.sourceforge.net) is written in Java and is embedded in `dpp`.
Java must be installed.

## Bash

[Bash] is executed when the keyword `bash` is used.

    ~~~~~ bash
    echo "Hi, I'm $SHELL $BASH_VERSION"
    RANDOM=42 # seed
    echo "Here are a few random numbers: $RANDOM, $RANDOM, $RANDOM"
    ~~~~~

This script outputs:

~~~~~~~~~~
~~~~~ bash
echo "Hi, I'm $SHELL $BASH_VERSION"
RANDOM=42 # seed
echo "Here are a few random numbers: $RANDOM, $RANDOM, $RANDOM"
~~~~~
~~~~~~~~~~

**Note**: the keyword `sh` executes `sh` which is generally a link to `bash`.

## Bat

[Bat] is executed when the keyword `bat` is used.

    ~~~~~ bat
    echo Hi, I'm %COMSPEC%
    ver
    if not "%WINELOADER%" == "" (
        echo This script is run from wine under Linux
    ) else (
        echo This script is run from a real Windows
    )
    ~~~~~

This script outputs:

~~~~~~~~~~
~~~~~ bat
echo Hi, I'm %COMSPEC%
ver
if "%WINELOADER%" == "" (
    echo This script is run from a real Windows
) else (
    echo This script is run from wine under Linux
)
~~~~~
~~~~~~~~~~

## Python

[Python] is executed when the keyword `python` is used.

    ~~~~~ python
    import sys
    import random

    if __name__ == "__main__":
        print("Hi, I'm Python %s"%sys.version)
        random.seed(42)
        randoms = [random.randint(0, 1000) for i in range(3)]
        print("Here are a few random numbers: %s"%(", ".join(map(str, randoms))))
    ~~~~~

This script outputs:

~~~~~~~~~~
~~~~~ python
import sys
import random

if __name__ == "__main__":
    print("Hi, I'm Python %s"%sys.version)
    random.seed(42)
    randoms = [random.randint(0, 1000) for i in range(3)]
    print("Here are a few random numbers: %s"%(", ".join(map(str, randoms))))
~~~~~
~~~~~~~~~~

## Haskell

[Haskell] is executed when the keyword `haskell` is used.

    ~~~~~ haskell
    import System.Info
    import Data.Version
    import Data.List

    primes = filterPrime [2..]
        where filterPrime (p:xs) =
                p : filterPrime [x | x <- xs, x `mod` p /= 0]

    version = showVersion compilerVersion
    main = do
        putStrLn $ "Hi, I'm Haskell " ++ version
        putStrLn $ "The first 10 prime numbers are: " ++
                    intercalate " " (map show (take 10 primes))
    ~~~~~

This script outputs:

~~~~~~~~~~
~~~~~ haskell
import System.Info
import Data.Version
import Data.List

primes = filterPrime [2..]
    where filterPrime (p:xs) =
            p : filterPrime [x | x <- xs, x `mod` p /= 0]

version = showVersion compilerVersion
main = do
    putStrLn $ "Hi, I'm Haskell " ++ version
    putStrLn $ "The first 10 prime numbers are: " ++
                intercalate " " (map show (take 10 primes))
~~~~~
~~~~~~~~~~

Licenses
========

PP/DPP
------

Copyright (C) 2015, 2016 Christophe Delord <br>
<http://www.cdsoft.fr/dpp>

DPP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DPP is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with DPP.  If not, see <http://www.gnu.org/licenses/>.

PlantUML
--------

PlantUML.jar is integrated in [DPP].
[PlantUML] is distributed under the [GPL license](http://www.gnu.org/copyleft/gpl.html).
See <http://plantuml.sourceforge.net/faq.html>.

ditaa
-----

ditaa.jar is integrated in [DPP].
[ditaa] is distributed under the [GNU General Public License version 2.0 (GPLv2)](http://sourceforge.net/directory/license:gpl/).
See <http://sourceforge.net/projects/ditaa/>.

GPP
---

[GPP] is included in the binary distribution of DPP.
I have just recompiled the original sources of [GPP].

GPP was written by Denis Auroux <auroux@math.mit.edu>.
Since version 2.12 it has been maintained by Tristan Miller <psychonaut@nothingisreal.com>.

Copyright (C) 1996-2001 Denis Auroux.<br>
Copyright (C) 2003, 2004 Tristan Miller.

Permission is granted to anyone to make or distribute verbatim copies
of this document as received, in any medium, provided that the
copyright notice and this permission notice are preserved, thus giving
the recipient permission to redistribute in turn.

Permission is granted to distribute modified versions of this
document, or of portions of it, under the above conditions, provided
also that they carry prominent notices stating who last changed them.

Feedback
========

Your feedback and contributions are welcome.
You can contact me at <http://cdsoft.fr>
