# Getting started

## Basics

Gramm is a Matlab toolbox which allows the quick creation of complex, publication-quality figures in Matlab. One of the main design philosophies is to allow users to make plots by specifying the desired end result. This *declarative* approach is quite different from what you might be used to: specifying the steps, in an *imperative* way, to assemble a plot or visualisation.

If you haven't come across this particular set of ideas yet, it might seem a bit strange. But you will soon come to appreciate how powerful and versatile it can be for exploring data and quickly changing how things are presented.

The Matlab implementation of ``gramm()`` is inspired by the [ggplot2](http://ggplot2.org) library for ``R`` by [Hadley Wickham](http://had.co.nz).

For an excellent introduction to the general ideas, have a look at the paper *"A layered grammar of graphics"*  [[PDF]](http://vita.had.co.nz/papers/layered-grammar.pdf). If you are really keen, you can also check out Leland Wilkinson's original book [The Grammar of Graphics](https://www.cs.uic.edu/~wilkinson/TheGrammarOfGraphics/GOG.html) that laid the foundation for much of this work.

## Getting to grips with GRAMM

### Download and install

If you are running MacOS, Linux or another Unix var, you can simply get the most up-to-date version by ``git clone``:

```bash
cd ~/matlab # or your favourite place to keep code
git clone https://github.com/piermorel/gramm.git
```

If you are on Windows, or if you don't have a ``git`` client, you can alternatively download the .zip archive and unpack that.

Finally, in Matlab, you also need to add the toolbox to your path. A nice, reproducible way to to this is to add the following lines to your ``startup.m`` file

```matlab
addpath(genpath('~/matlab/gramm/'))
```

If you have done this correctly, then on restarting Matlab (or after running ``startup()``) you should be able to call up the documentation by ``doc gramm``

<img src="imgs/doc_gramm.png" width="600px">

### A first plot
