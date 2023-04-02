<h1> pandoc-slides <a href="https://github.com/andros21/pandoc-slides/actions/workflows/build.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/andros21/pandoc-slides/build.yml?branch=master&label=build&logo=github" alt="build">
</a>
</h1>

A Template for RevealJS Slides written in Markdown

### Prerequisites

* container engine
    * [`docker`](https://www.docker.com/) - most popular container engine
    * [`podman`](https://podman.io/) - a daemonless container engine
* [`make`](https://www.gnu.org/s/make/manual/make.html) command - build automation tool

> **Warning:** supported platforms
>  * `amd64-unknown-linux`
>  * `arm64-unknown-linux`
>  * `amd64-apple-darwin`
>  * `arm64-apple-darwin`

### Usage

* Put the title of your slides, your name and other meta information in [`metadata.yaml`](metadata.yaml)
* Adjust optional definitions in [`metadata.yaml`](metadata.yaml) to your needs
* Fill the markdown file [`md/slides.md`](md/slides.md) with your content

    > **Hint:** you will find some help regarding the use of Markdown inside it

    > **Warning:** do not forget to reflect the changed filenames in [`Makefile`](Makefile)

* Create `pandoc-slides` container with everything you need to build slides: `make container`
* Build the slides: `make`
* Clean up
    * to remove temporary (generated) filed: `make clean`
    * to also remove the generated slides (html): `make distclean`
    * to remove container: `make containerclean`
    * to remove image: `make imageclean`

> **Note:** the above mentioned files constitute a minimal working example\
> To start your own project, simply clone this project and customize the files mentioned above

> **Note:** to upgrade to latest `pandoc-slides` image `make containerupgrade`

### Pandoc filters

Inside markdown source is possible to insert code-blocks of these available tools:
* [`matplotlib`](https://matplotlib.org/) - a comprehensive library for creating static plot in python
* [`graphviz`](https://graphviz.org/) - open source graph visualization software
* [`plantuml`](https://plantuml.com/) - easily create beautiful uml diagrams from simple text

thanks to [`pandocfilters`](https://github.com/jgm/pandocfilters) and [`imagine`](https://github.com/andros21/imagine) are rendered as image inside final html

> **Hint:** there is a special section inside [`example/slides.md`](example/slides.md)\
> for better understanding how it work and how to use it

> **Note:** `imagine` global configuration inside [`metadata.yaml`](metadata.yaml) or\
> config per block inside code-block header

> **Note:** `matplotlib` global configuration inside [`matplotlibrc`](matplotlibrc) loaded at startup

### Acknowledgements

Related project [`pandoc-thesis`](https://github.com/andros21/pandoc-thesis)
