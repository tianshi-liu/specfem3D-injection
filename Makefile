#=====================================================================
#
#                         S p e c f e m 3 D
#                         -----------------
#
#     Main historical authors: Dimitri Komatitsch and Jeroen Tromp
#                              CNRS, France
#                       and Princeton University, USA
#                 (there are currently many more authors!)
#                           (c) October 2017
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#=====================================================================
#
# United States Government Sponsorship Acknowledged.
#
# Makefile.  Generated from Makefile.in by configure.
#######################################

FC = ifort
FCFLAGS = -g ${DEBUG_COUPLED_FLAG}
FC_DEFINE = -D
MPIFC = mpif90
MPILIBS = 

FLAGS_CHECK = -xHost -fpe0 -ftz -assume buffered_io -assume byterecl -align sequence -std08 -diag-disable 6477 -implicitnone -gen-interfaces -warn all -O3 -check nobounds -DFORCE_VECTORIZATION

FCFLAGS_f90 = -module ./obj -I./obj -I.  -I${SETUP}

FC_MODEXT = mod
FC_MODDIR = ./obj

FCCOMPILE_CHECK = ${FC} ${FCFLAGS} $(FLAGS_CHECK) $(COND_OPENMP_FFLAGS)

MPIFCCOMPILE_CHECK = ${MPIFC} ${FCFLAGS} $(FLAGS_CHECK) $(COND_OPENMP_FFLAGS)

CC = icc
CXX = mpicxx
CFLAGS = -g -O2 $(CPPFLAGS)
CPPFLAGS = -I${SETUP}  -DFORCE_VECTORIZATION $(COND_MPI_CPPFLAGS)

# all linker flags
LDFLAGS = 
MPILIBS += $(LDFLAGS) 

#######################################
####
#### MPI
####
#######################################

## serial or parallel
MPI = yes
#MPI = no

FCLINK = $(MPIFCCOMPILE_CHECK)
#FCLINK = $(FCCOMPILE_CHECK)

COND_MPI_CPPFLAGS = $(FC_DEFINE)WITH_MPI
#COND_MPI_CPPFLAGS =

# objects toggled between the parallel and serial version
COND_MPI_OBJECTS = $O/parallel.sharedmpi.o
#COND_MPI_OBJECTS = $O/serial.shared.o

MPI_INCLUDES =  -I/scinet/niagara/software/2019b/opt/intel-2019u4/openmpi/4.0.1-hpcx2.5/include

#######################################
####
#### SCOTCH
####
#######################################

SCOTCH = yes
#SCOTCH = no

USE_BUNDLED_SCOTCH = 1

SCOTCH_DIR = ./external_libs/scotch
SCOTCH_INCDIR = ./external_libs/scotch/include
SCOTCH_LIBDIR = ./external_libs/scotch/lib

SCOTCH_INC = -I${SCOTCH_INCDIR}
#SCOTCH_INC =

SCOTCH_LIBS = -L${SCOTCH_LIBDIR} -lscotch -lscotcherr
#SCOTCH_LIBS =

SCOTCH_FLAGS = $(FC_DEFINE)USE_SCOTCH $(SCOTCH_INC)
#SCOTCH_FLAGS =

## METIS
## uncomment for METIS support and re-compile
## to use it, set PARTITIONING_TYPE = 2 (in your Par_file)
# Metis v4 (using version in folder external_libs/):
#METIS_INC = $(FC_DEFINE)USE_METIS -I./external_libs/metis-4.0.3/Lib
#METIS_LIBS = -lmetis -L./external_libs/metis-4.0.3
# Metis v5 (must be installed on your system):
#METIS_INC = $(FC_DEFINE)USE_METIS
#METIS_LIBS = -lmetis

## PaToH
## uncomment for PATOH support and re-compile
## to use it, set PARTITIONING_TYPE = 3 (in your Par_file)
# PaToH v3.2 (using version in folder external_libs/):
#PATOH_INC = $(FC_DEFINE)USE_PATOH -I./external_libs/patoh/
#PATOH_LIBS = -L./external_libs/patoh/ -lpatoh -lconfig++ -lstdc++

## compilation flag for partitioner
# default: scotch
PART_FLAGS = $(SCOTCH_FLAGS)
PART_LIBS  = $(SCOTCH_LIBS)
# metis support
PART_FLAGS += $(METIS_INC)
PART_LIBS  += $(METIS_LIBS)
# patoh support
PART_FLAGS += $(PATOH_INC)
PART_LIBS  += $(PATOH_LIBS)

#######################################
####
#### GPU
#### with configure: ./configure --with-cuda=cuda5 CUDA_FLAGS=.. CUDA_LIB=.. CUDA_INC=.. MPI_INC=.. ..
#### with configure: ./configure --with-hip HIP_FLAGS=.. HIP_LIB=.. HIP_INC=.. MPI_INC=.. ..
####
#######################################

##
## CUDA
##
#CUDA = yes
CUDA = no

#CUDA4 = yes
CUDA4 = no

#CUDA5 = yes
CUDA5 = no

#CUDA6 = yes
CUDA6 = no

#CUDA7 = yes
CUDA7 = no

#CUDA8 = yes
CUDA8 = no

#CUDA9 = yes
CUDA9 = no

#CUDA10 = yes
CUDA10 = no

#CUDA11 = yes
CUDA11 = no

#CUDA12 = yes
CUDA12 = no

# CUDA compilation with linking
#CUDA_PLUS = yes
CUDA_PLUS = no

# default cuda libraries
# runtime library -lcudart needed, others are optional -lcuda -lcublas

CUDA_FLAGS = 
CUDA_INC =  -I${SETUP}
CUDA_LINK =   -lstdc++
CUDA_DEBUG = --cudart=shared

#NVCC = nvcc
NVCC = icc

##
## GPU architecture
##
# CUDA architecture / code version
# Fermi   (not supported): -gencode=arch=compute_10,code=sm_10
# Tesla   (Tesla C2050, GeForce GTX 480): -gencode=arch=compute_20,code=sm_20
# Tesla   (cuda4, K10, Geforce GTX 650, GT 650m): -gencode=arch=compute_30,code=sm_30
# Kepler  (cuda5, K20) : -gencode=arch=compute_35,code=sm_35
# Kepler  (cuda6.5, K80): -gencode=arch=compute_37,code=sm_37
# Maxwell (cuda6.5+/cuda7, Quadro K2200): -gencode=arch=compute_50,code=sm_50
# Pascal  (cuda8,P100, GeForce GTX 1080, Titan): -gencode=arch=compute_60,code=sm_60
# Volta   (cuda9, V100): -gencode=arch=compute_70,code=sm_70
# Turing  (cuda10, T4, GeForce RTX 2080): -gencode=arch=compute_75,code=sm_75
# Ampere  (cuda11, A100, GeForce RTX 3080): -gencode=arch=compute_80,code=sm_80
# Hopper  (cuda12, H100): -gencode=arch=compute_90,code=sm_90
GENCODE_20 = -gencode=arch=compute_20,code=\"sm_20,compute_20\"
GENCODE_30 = -gencode=arch=compute_30,code=\"sm_30,compute_30\"
GENCODE_35 = -gencode=arch=compute_35,code=\"sm_35,compute_35\"
GENCODE_37 = -gencode=arch=compute_37,code=\"sm_37\"
GENCODE_50 = -gencode=arch=compute_50,code=\"sm_50,compute_50\"
GENCODE_52 = -gencode=arch=compute_52,code=\"sm_52,compute_52\"
GENCODE_60 = -gencode=arch=compute_60,code=\"sm_60,compute_60\"
GENCODE_70 = -gencode=arch=compute_70,code=\"sm_70,compute_70\"
GENCODE_75 = -gencode=arch=compute_75,code=\"sm_75,compute_75\"
GENCODE_80 = -gencode=arch=compute_80,code=\"sm_80,compute_80\"
GENCODE_90 = -gencode=arch=compute_90,code=\"sm_90,compute_90\"

# cuda preprocessor flag
# CUDA version 12.0
##GENCODE = $(GENCODE_90) $(FC_DEFINE)GPU_DEVICE_Hopper
# CUDA version 11.0
##GENCODE = $(GENCODE_80) $(FC_DEFINE)GPU_DEVICE_Ampere
# CUDA version 10.0
##GENCODE = $(GENCODE_75) $(FC_DEFINE)GPU_DEVICE_Turing
# CUDA version 9.0
##GENCODE = $(GENCODE_70) $(FC_DEFINE)GPU_DEVICE_Volta
# CUDA version 8.0
##GENCODE = $(GENCODE_60) $(FC_DEFINE)GPU_DEVICE_Pascal
# CUDA version 7.x
##GENCODE = $(GENCODE_52) $(FC_DEFINE)GPU_DEVICE_Maxwell
# CUDA version 6.5
##GENCODE = $(GENCODE_37) $(FC_DEFINE)GPU_DEVICE_K80
# CUDA version 5.x
##GENCODE = $(GENCODE_35) $(FC_DEFINE)GPU_DEVICE_K20
# CUDA version 4.x
##GENCODE = $(GENCODE_30)
## old CUDA toolkit versions < 5
#GENCODE = $(GENCODE_20)

# CUDA flags and linking
#NVCC_FLAGS_BASE = $(CUDA_FLAGS) $(CUDA_INC) $(CUDA_DEBUG) $(MPI_INCLUDES) $(COND_MPI_CPPFLAGS)
##NVCC_FLAGS = $(NVCC_FLAGS_BASE) -dc $(GENCODE)
#NVCC_FLAGS = $(NVCC_FLAGS_BASE) -DUSE_OLDER_CUDA4_GPU $(GENCODE)

##NVCCLINK_BASE = $(NVCC) $(CUDA_FLAGS) $(CUDA_INC) $(MPI_INCLUDES) $(COND_MPI_CPPFLAGS)
##NVCCLINK = $(NVCCLINK_BASE) -dlink $(GENCODE)
#NVCCLINK = $(NVCCLINK_BASE) -DUSE_OLDER_CUDA4_GPU $(GENCODE)

NVCC_FLAGS = $(MPI_INCLUDES) $(COND_MPI_CPPFLAGS)
NVCCLINK = $(NVCC) $(NVCC_FLAGS)

##
## HIP
##
#HIP = yes
HIP = no

# GPU architecture / code version
# see: https://llvm.org/docs/AMDGPUUsage.html
# Radeon Instinct MI8:   --amdgpu-target=gfx803
# Radeon Instinct MI25:	 --amdgpu-target=gfx900
# Radeon Instinct MI50:  --amdgpu-target=gfx906
# Radeon Instinct MI100: --amdgpu-target=gfx908
# Radeon Instinct MI210/250/250X: --amdgpu-target=gfx90a
GENCODE_AMD_MI8 = --amdgpu-target=gfx803
GENCODE_AMD_MI25 = --amdgpu-target=gfx900
GENCODE_AMD_MI50 = --amdgpu-target=gfx906
GENCODE_AMD_MI100 = --amdgpu-target=gfx908
GENCODE_AMD_MI250 = --amdgpu-target=gfx90a

# default targets
# AMD default MI50 & MI100
##GENCODE_HIP = $(GENCODE_AMD_MI50) $(GENCODE_AMD_MI100)
##HIP_CFLAG_ENDING = -x hip
# NVIDIA default Tesla
##GENCODE_HIP = $(GENCODE_30)
##HIP_CFLAG_ENDING =      # no need for ending

# specific targets
##GENCODE_HIP = $(GENCODE_AMD_MI8)      # --with-hip=MI8 ..
##GENCODE_HIP = $(GENCODE_AMD_MI25)    # --with-hip=MI25 ..
##GENCODE_HIP = $(GENCODE_AMD_MI50)    # --with-hip=MI50 ..
##GENCODE_HIP = $(GENCODE_AMD_MI100)  # --with-hip=MI100 ..
##GENCODE_HIP = $(GENCODE_AMD_MI250)  # --with-hip=MI250 ..

##GENCODE_HIP = $(GENCODE_35)         # --with-hip=cuda5 ..
##GENCODE_HIP = $(GENCODE_37)         # --with-hip=cuda6 ..
##GENCODE_HIP = $(GENCODE_52)         # --with-hip=cuda7 ..
##GENCODE_HIP = $(GENCODE_60)         # --with-hip=cuda8 ..
##GENCODE_HIP = $(GENCODE_70)         # --with-hip=cuda9 ..
##GENCODE_HIP = $(GENCODE_75)         # --with-hip=cuda10 ..
##GENCODE_HIP = $(GENCODE_80)         # --with-hip=cuda11 ..
##GENCODE_HIP = $(GENCODE_90)         # --with-hip=cuda12 ..

HIP_FLAGS = 
HIP_INC =  $(MPI_INCLUDES)

#HIPCC = 
HIPCC = icc

#HIP_CFLAGS = $(HIP_FLAGS) $(HIP_INC) $(GENCODE_HIP)
#HIP_LINK =  

HIP_CFLAGS =
HIP_LINK =

## linking with hipcc instead of mpif90
## openMPI
#MPI_LIB_PATH = -L$(shell ${MPIFC} --showme:libdirs)
#MPI_LIBS += $(shell ${MPIFC} --showme:libs)
#MPI_LIBS += $(shell mpicxx --showme:libs)
#SET_MPI_LIB = ${MPI_LIB_PATH} $(shell echo ${MPI_LIBS} | sed -e 's/\b\([a-z]\+\)[ ,\n]\1/\1/g'|sed 's/[^ ]* */-l&/g')
#FCLINK = $(HIPCC) $(SET_MPI_LIB)
## mpich
# from: mpif90 -link_info
#FCLINK = $(HIPCC) -L/usr/lib/x86_64-linux-gnu -lmpichfort -lmpich -lgfortran -lm -shared-libgcc

# checks if any GPU flag set
ifeq ($(CUDA), no)
	ifeq ($(HIP), no)
		NO_GPU = yes
	endif
endif
ifneq ($(NO_GPU), yes)
  HAS_GPU = yes
endif

#######################################
####
#### OpenMP
#### with configure: ./configure --enable-openmp OMP_FCFLAGS=".." OMP_LIB=..
####
#######################################

#OPENMP = yes
OPENMP = no

#FCFLAGS += $(FC_DEFINE)USE_OPENMP -qopenmp

#OMP_LIBS = $(OMP_LIB)
OMP_LIBS =

#######################################
####
#### VTK
#### with configure: ./configure --enable-vtk --with-vtk-version=5.8 ..
####
#######################################

#VTK = yes
VTK = no

VTK_MAJOR_VERSION = 

# additional libraries
ifeq ($(VTK),yes)
  ifeq ($(shell test $(VTK_MAJOR_VERSION) -gt 5; echo $$?),0)
    VTKLIBS = -lvtkRenderingOpenGL2-7.0
  endif
endif

#FCCOMPILE_CHECK += $(FC_DEFINE)VTK_VIS
#CPPFLAGS += 
#VTKLIBS +=  

#######################################
####
#### ADIOS
#### with configure: ./configure --with-adios ADIOS_CONFIG=..
####
#######################################

#ADIOS = yes
ADIOS = no

#ADIOS_DEF = $(FC_DEFINE)USE_ADIOS
ADIOS_DEF =

#FCFLAGS_f90 +=  $(ADIOS_DEF)
#MPILIBS += 

#######################################
####
#### ADIOS2
#### with configure: ./configure --with-adios2 ADIOS2_CONFIG=..
####
#######################################

#ADIOS2 = yes
ADIOS2 = no

#ADIOS2_DEF = $(FC_DEFINE)USE_ADIOS2
ADIOS2_DEF =

#FCFLAGS_f90 +=  $(ADIOS2_DEF)
#MPILIBS += 

#CPPFLAGS += 
#MPILIBS += 

#MPICC = mpicc
MPICC = $(CC)

#######################################
####
#### ASDF
#### with configure: ./configure --with-asdf ASDF_LIBS=..
####
#######################################

#ASDF = yes
ASDF = no

#FCFLAGS += @ASDF_FCFLAGS@
#MPILIBS +=  -lasdf -lhdf5hl_fortran -lhdf5_hl -lhdf5 -lstdc++

#######################################
####
#### HDF5 (parallel)
#### with configure: ./configure --with-hdf5 HDF5_LIBS=.. HDF5_FCFLAGS=.. HDF5_INC=..
####
#######################################

#HDF5 = yes
HDF5 = no

# adds compiler flag
#FCFLAGS +=   $(FC_DEFINE)USE_HDF5
#LDFLAGS +=  -lhdf5_fortran -lhdf5hl_fortran    # -lhdf5_hl -lhdf5 -lstdc++

#######################################
####
#### directories
####
#######################################

## compilation directories
# B : build directory
B = .
# E : executables directory
E = $B/bin
# O : objects directory
O = $B/obj
# S_TOP : source file root directory
S_TOP = .
# L : libraries directory
L = $B/lib
# setup file directory
SETUP = $B/setup
# output file directory
OUTPUT = $B/OUTPUT_FILES


#######################################
####
#### targets
####
#######################################

# code subdirectories
SUBDIRS = \
	auxiliaries \
	check_mesh_quality \
	decompose_mesh \
	generate_databases \
	gpu \
	meshfem3D \
	shared \
	specfem3D \
	tomography/postprocess_sensitivity_kernels \
	tomography \
	$(EMPTY_MACRO)

# default targets for the pure Fortran version
DEFAULT = \
	xdecompose_mesh \
	xmeshfem3D \
	xgenerate_databases \
	xspecfem3D \
	$(EMPTY_MACRO)

# targets requiring MPI
ifeq ($(MPI),yes)
DEFAULT += xdecompose_mesh_mpi xinverse_problem_for_model
SUBDIRS += inverse_problem_for_model
endif

default: $(DEFAULT)

all: default aux check_mesh postprocess tomography

backup:
	cp -rp src setup DATA/Par_file* Makefile bak

ifdef CLEAN
clean:
	@echo "cleaning by CLEAN"
	-rm -f $(foreach dir, $(CLEAN), $($(dir)_OBJECTS) $($(dir)_MODULES) $($(dir)_SHARED_OBJECTS) $($(dir)_TARGETS))
	-rm -f ${E}/*__genmod.*
	-rm -f ${O}/*__genmod.*
	-rm -f ${O}/*.smod
	-rm -f ${O}/*.lst
else
clean:
	@echo "cleaning all"
	-rm -f $(foreach dir, $(SUBDIRS), $($(dir)_OBJECTS) $($(dir)_MODULES) $($(dir)_TARGETS))
	-rm -f ${E}/*__genmod.*
	-rm -f ${O}/*__genmod.*
	-rm -f ${O}/*.smod
	-rm -f ${O}/*.lst
endif

realclean: clean
ifeq (${USE_BUNDLED_SCOTCH},1)
	@echo "cleaning bundled Scotch in directory: ${SCOTCH_DIR}/src"
	$(MAKE) -C ${SCOTCH_DIR}/src realclean
endif
	-rm -rf $E/* $O/*

# unit testing
# If the first argument is "test"...
ifeq (test,$(findstring test,firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  TEST_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # turn them into do-nothing targets
  $(eval $(TEST_ARGS):;@:)
endif

tests:
	@echo "testing in directory: ${S_TOP}/tests/"
	cd ${S_TOP}/tests; ./run_all_tests.sh $(TEST_ARGS)
	@echo ""

help:
	@echo "usage: make [executable]"
	@echo ""
	@echo "supported main executables:"
	@echo "    xdecompose_mesh"
	@echo "    xmeshfem3D"
	@echo "    xgenerate_databases"
	@echo "    xspecfem3D"
	@echo ""
	@echo "defaults:"
	@echo "    xdecompose_mesh"
ifeq ($(MPI),yes)
	@echo "    xdecompose_mesh_mpi"
endif
	@echo "    xmeshfem3D"
	@echo "    xgenerate_databases"
	@echo "    xspecfem3D"
ifeq ($(MPI),yes)
	@echo ""
	@echo "    xinverse_problem_for_model"
endif
	@echo ""
	@echo "    xconvolve_source_timefunction"
	@echo "    xcreate_movie_shakemap_AVS_DX_GMT"
	@echo ""
	@echo "    xcheck_mesh_quality"
	@echo "    xconvert_skewness_to_angle"
	@echo ""
	@echo "additional executables:"
	@echo "- auxiliary executables: [make aux]"
	@echo "    xcombine_surf_data"
	@echo "    xcombine_vol_data"
	@echo "    xcombine_vol_data_vtk"
	@echo "    xcombine_vol_data_vtu"
ifeq ($(ADIOS), yes)
	@echo "    xcombine_vol_data_adios"
	@echo "    xcombine_vol_data_vtk_adios"
	@echo "    xcombine_vol_data_vtu_adios"
endif
ifeq ($(ADIOS2), yes)
	@echo "    xcombine_vol_data_adios"
	@echo "    xcombine_vol_data_vtk_adios"
	@echo "    xcombine_vol_data_vtu_adios"
endif
	@echo ""
	@echo "    xconvolve_source_timefunction"
	@echo "    xcreate_movie_shakemap_AVS_DX_GMT"
	@echo ""
ifeq ($(MPI),yes)
	@echo "    xproject_and_combine_vol_data_on_regular_grid"
	@echo ""
endif

	@echo "- check mesh executables: [make check_mesh]"
	@echo "    xcheck_mesh_quality"
	@echo "    xconvert_skewness_to_angle"
	@echo ""
	@echo "- sensitivity kernel postprocessing tools: [make postprocess]"
	@echo "    xclip_sem"
	@echo "    xcombine_sem"
	@echo "    xsmooth_sem"
	@echo ""
	@echo "- tomography tools: [make tomography]"
	@echo "    xmodel_update"
	@echo "    xsum_kernels"
	@echo "    xsum_preconditioned_kernels"
	@echo ""
	@echo "for unit testing:"
	@echo "    tests"
	@echo ""

.PHONY: all default backup clean realclean help tests

#######################################

# Get dependencies and rules for building stuff
include $(patsubst %, ${S_TOP}/src/%/rules.mk, $(SUBDIRS))

#######################################

##
## Shortcuts
##

# Shortcut for: <prog>/<xprog> -> bin/<xprog>
define target_shortcut
$(patsubst $E/%, %, $(1)): $(1)
.PHONY: $(patsubst $E/%, %, $(1))
$(patsubst $E/x%, %, $(1)): $(1)
.PHONY: $(patsubst $E/x%, %, $(1))
endef

# Shortcut for: dir -> src/dir/<targets in here>
define shortcut
$(1): $($(1)_TARGETS)
.PHONY: $(1)
$$(foreach target, $$(filter $E/%,$$($(1)_TARGETS)), $$(eval $$(call target_shortcut,$$(target))))
endef

$(foreach dir, $(SUBDIRS), $(eval $(call shortcut,$(dir))))

# testing
test : tests

# Other old shortcuts
bak: backup
mesh: $E/xmeshfem3D
gen: $E/xgenerate_databases
spec: $E/xspecfem3D
dec: $E/xdecompose_mesh

.PHONY: bak mesh gen spec dec

