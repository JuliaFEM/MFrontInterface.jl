# MFrontInterface

[![Build Status](https://travis-ci.com/JuliaFEM/MFrontInterface.jl.svg?branch=master)](https://travis-ci.com/JuliaFEM/MFrontInterface.jl)
[![Coveralls](https://coveralls.io/repos/github/JuliaFEM/MFrontInterface.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaFEM/MFrontInterface.jl?branch=master)
[![][docs-stable-img]][docs-stable-url]
[![][docs-latest-img]][docs-latest-url]

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliafem.github.io/MFrontInterface.jl/stable
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://juliafem.github.io/MFrontInterface.jl/latest


## Citation

If you like our package, please consider citing with the infromation in [CITATION.bib](https://github.com/JuliaFEM/MFrontInterface.jl/blob/master/CITATION.bib):

```
@inproceedings{frondelius2019mfrontinterface,
    title={MFrontInterface.jl: MFront material models in Julia{FEM}},
    author={Tero Frondelius and Thomas Helfer and Ivan Yashchuk and Joona Vaara  and Anssi Laukkanen},
    editor={H. Koivurova and A. H. Niemi},
    booktitle={Proceedings of the 32nd Nordic Seminar on Computational Mechanics},
    year={2019},
    place={Oulu}
}
```

## Example of usage

```
using MFrontInterface

norton = raw"""
@DSL Implicit;
@Author Thomas Helfer;
@Date 3 / 08 / 2018;
@Behaviour NortonTest;
@Description {
  "This file implements the Norton law "
  "using the StandardElastoViscoplasticity brick"
}

@ModellingHypotheses{".+"};
@Epsilon 1.e-16;

@Brick StandardElastoViscoPlasticity{
  stress_potential : "Hooke" {young_modulus : 150e9, poisson_ratio : 0.3},
  inelastic_flow : "Norton" {criterion : "Mises", A : 1.0e-10, n : 1.2, K : 1}
};
""";

path = mfront(norton)

mat = MFrontMaterialModel(lib_path=path, behaviour_name="NortonTest")
```
