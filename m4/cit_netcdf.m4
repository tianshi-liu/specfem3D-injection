# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for netcdf.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_NETCDF_HEADER
# ----------------------------------------------------------------------
AC_DEFUN([CIT_NETCDF_HEADER], [
  cit_save_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $NETCDF_INCLUDES"
  AC_LANG(C)
  AC_REQUIRE_CPP
  AC_CHECK_HEADER([netcdf.h], [], [
    AC_MSG_ERROR([NetCDF header not found; try --with-netcdf-incdir=<NetCDF include dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
])dnl CIT_NETCDF_HEADER


# ----------------------------------------------------------------------
# CIT_NETCDF_LIB
# ----------------------------------------------------------------------
AC_DEFUN([CIT_NETCDF_LIB], [
  cit_save_cppflags=$CPPFLAGS
  cit_save_ldflags=$LDFLAGS
  cit_save_libs=$LIBS
  CPPFLAGS="$CPPFLAGS $NETCDF_INCLUDES"
  LDFLAGS="LDFLAGS $NETCDF_LDFLAGS"
  AC_LANG(C)
  AC_REQUIRE_CPP
  AC_MSG_CHECKING([for nc_open in -lnetcdf])
  AC_CHECK_LIB(netcdf, nc_open, [],[
    AC_MSG_ERROR([NetCDF library not found; try --with-netcdf-libdir=<NetCDF lib dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
  LDFLAGS=$cit_save_ldflags
  LIBS=$cit_save_libs
])dnl CIT_NETCDF_LIB


dnl end of file
