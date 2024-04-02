#!/bin/bash
NPROC=120
echo "running example: `date`"
currentdir=`pwd`
specfem_dir=$SCRATCH/specfem3d_injection
# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

# checks if executables were compiled and available
if [ ! -e ${specfem_dir}/bin/xspecfem3D ]; then
  echo "Please compile first all binaries in the root directory, before running this example..."; echo
  exit 1
fi

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

# cleans output files
mkdir -p OUTPUT_FILES
mkdir -p DATABASES_MPI
mkdir -p MESH/
rm -rf OUTPUT_FILES/*
rm -rf DATABASES_MPI/*

# links executables
mkdir -p bin
cd bin/
rm -f *
ln -s ${specfem_dir}/bin/xmeshfem3D
ln -s ${specfem_dir}/bin/xdecompose_mesh
ln -s ${specfem_dir}/bin/xgenerate_databases
ln -s ${specfem_dir}/bin/xcombine_vol_data_vtk
ln -s ${specfem_dir}/bin/xspecfem3D
cd ../

# stores setup
cp DATA/meshfem3D_files/Mesh_Par_file OUTPUT_FILES/
cp DATA/Par_file OUTPUT_FILES/
cp DATA/CMTSOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/

sed -i "/^NPROC/c\NPROC                           = 1" DATA/Par_file
# This is a serial simulation
echo
echo "  running mesher..."
echo
./bin/xmeshfem3D

mkdir -p MESH-default
cp -f MESH/* MESH-default
cp -f MESH-default/wavefield_discontinuity_boundary .
#cp -f nummaterial_velocity_file MESH-default

sed -i "/^NPROC/c\NPROC                           = ${NPROC}" DATA/Par_file

# decomposes mesh using the pre-saved mesh files in MESH-default
echo
echo "  decomposing mesh..."
echo
./bin/xdecompose_mesh $NPROC ./MESH-default $BASEMPIDIR

# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

