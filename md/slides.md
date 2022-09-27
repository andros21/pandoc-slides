## Let's test [`katex`](https://katex.org/)

One dimensional over-dumped **Lagevin's equation**:

$\lambda \dfrac{dx}{dt} = -\dfrac{dV(x)}{dx} + \eta(t)$

<br>

> Ok it works!

---

## Let's test [pandoc-filters](https://github.com/andros21/imagine)

The stationary distribution relative to stochastic process $x(t)$
described by Langevin's equation it's a **Maxwell-Boltzmann**
distribution

$$\rho(x)\propto e^{-kV(x)}$$

---

```{.matplotlib im_fmt="svg" im_out="img" caption="Maxwell-Boltzmann distribution with elastic potential"}
x = np.linspace(0, 10)

fig, ax = plt.subplots()
for k in np.arange(1, 4):
   V = np.exp(-k*x)
   ax.plot(x, V, label=f"$V(x)=-{k}x$")

ax.set_xlabel('$x$')
ax.set_ylabel('$p(x)$')
ax.legend()
```

---

Here the code used to create the plot:

```python
import numpy as np
from matplotlib import pyplot as plt

x = np.linspace(0, 10)

fig, ax = plt.subplots()
for k in np.arange(1, 4):
   V = np.exp(-k*x)
   ax.plot(x, V, label=f"$V(x)=-{k}x$")

ax.set_xlabel('$x$')
ax.set_ylabel('$p(x)$')
ax.legend()
```

---

Try to drawing a simple graph with [graphviz](https://graphviz.org)

```{.graphviz im_fmt="svg" im_out="img" caption="This graph was
created from a hand-made figure in an operating system paper"}
graph G {
   bgcolor="transparent"
   fontname="Helvetica,Arial,sans-serif"
   node [fontname="Helvetica,Arial,sans-serif"]
   edge [fontname="Helvetica,Arial,sans-serif"]
   layout=neato
   run -- intr;
   intr -- runbl;
   runbl -- run;
   run -- kernel;
   kernel -- zombie;
   kernel -- sleep;
   kernel -- runmem;
   sleep -- swap;
   swap -- runswap;
   runswap -- new;
   runswap -- runmem;
   new -- runmem;
   sleep -- runmem;
}
```

---

Here the code used to create the plot:

```{.graphviz im_out="ocb"}
graph G {
   bgcolor="transparent"
   fontname="Helvetica,Arial,sans-serif"
   node [fontname="Helvetica,Arial,sans-serif"]
   edge [fontname="Helvetica,Arial,sans-serif"]
   layout=neato
   run -- intr;
   intr -- runbl;
   runbl -- run;
   run -- kernel;
   kernel -- zombie;
   kernel -- sleep;
   kernel -- runmem;
   sleep -- swap;
   swap -- runswap;
   runswap -- new;
   runswap -- runmem;
   new -- runmem;
   sleep -- runmem;
}
```

---

At the end let's try [plantuml]()

```{.plantuml im_fmt="svg" im_out="img" width="150%" caption="Drawing
a graph from yaml file"}
@startuml
@startyaml
!theme sketchy-outline
doe: "a deer, a female deer"
ray: "a drop of golden sun"
pi: 3.14159
xmas: true
french-hens: 3
calling-birds:
   - huey
   - dewey
   - louie
   - fred
xmas-fifth-day:
   calling-birds: four
   french-hens: 3
   golden-rings: 5
   partridges:
      count: 1
      location: "a pear tree"
   turtle-doves: two
@endyaml
```

---

Here the yaml file:

```yaml
doe: "a deer, a female deer"
ray: "a drop of golden sun"
pi: 3.14159
xmas: true
french-hens: 3
calling-birds:
   - huey
   - dewey
   - louie
   - fred
xmas-fifth-day:
   calling-birds: four
   french-hens: 3
   golden-rings: 5
   partridges:
      count: 1
      location: "a pear tree"
   turtle-doves: two
```
