# Specfem3D injection

A copy of [![SPECFEM3D_Cartesian repository](https://github.com/SPECFEM/specfem3d)] with an implementation of wavefield injection based on interface discontinuity

## Installation
```
bash quick_install
```
- tested on intel + openmpi

## Numerical tests
Scripts for numerical tests are placed in the `test_injection/` directory


## Enabling wavefield injection
To enable wavefield injection, simply add a file in the main directory `wavefield_discontinuity_switch`, which includes two lines:
```
IS_WAVEFIELD_DISCONTINUITY # .true. or .false., whether wavefield discontinuity is enabled
IS_TOP_WAVEFIELD_DISCONTINUITY # .true. or .false., whether the top of the box is injection interface (.true.) or free surface (.false.)
```
A `wavefield_discontinuity_box` file can be read by the mesher to define the injection box, containing 6 lines (xmin, xmax, ymin, ymax, zmin, zmax). The mesher will output a `wavefield_discontinuity_boundary` file, in which each line represents a segment on the internal side of the injection interface. It is also possible to generate this file manually instead of using the mesher.

The `wavefield_discontinuity_boundary` file will be used by the partitioner.

The `generate_databases` routine generates files `proc******_wavefield_discontinuity_points`, listing the coordinates of points where background displacements and accelerations are needed, and `proc******_wavefield_discontinuity_faces`, listing the coordinates and normals of points where where background tractions are needed. The background solver should be able to read these files, and output a `proc******_wavefield_discontinuity.bin` file containing the background wavefield at each time step.

The solver reads the `proc******_wavefield_discontinuity.bin` files are performs the hybrid simulation.
