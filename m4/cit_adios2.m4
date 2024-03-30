# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for ADIOS2.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_ADIOS2_CONFIG
# ----------------------------------------------------------------------
AC_DEFUN([CIT_ADIOS2_CONFIG], [
  dnl ADIOS 2.x comes with a program that *should* tell us how to link with it.
  AC_ARG_VAR([ADIOS2_CONFIG], [Path to adios_config program that indicates how to compile with it.])
  AC_PATH_PROG([ADIOS2_CONFIG], [adios2-config])

  if test "x$ADIOS2_CONFIG" = "x"; then
    AC_MSG_ERROR([adios2-config program not found; try setting ADIOS2_CONFIG to point to it])
  fi

  AC_LANG_PUSH([Fortran])
  FC_save="$FC"
  FCFLAGS_save="$FCFLAGS"
  LIBS_save="$LIBS"
  FC="$MPIFC" dnl Must use mpi compiler.

  dnl First check for directory with ADIOS2 modules
  AC_MSG_CHECKING([for ADIOS2 modules])
  ADIOS2_FCFLAGS=`$ADIOS2_CONFIG --fortran-flags`
  FCFLAGS="$ADIOS2_FCFLAGS $FCFLAGS"
  AC_COMPILE_IFELSE([
    AC_LANG_PROGRAM([], [[
    use adios2
    type(adios2_adios) :: adios
    ]])
  ], [
    AC_MSG_RESULT(yes)
  ], [
    AC_MSG_RESULT(no)
    AC_MSG_ERROR([ADIOS2 modules not found; is ADIOS2 built with Fortran support for this compiler?])
  ])

  dnl Now check for libraries that must be linked.
  AC_MSG_CHECKING([for ADIOS2 libraries])
  FCFLAGS="$ADIOS2_FCFLAGS $FCFLAGS_save"
  ADIOS2_LIBS=`$ADIOS2_CONFIG --fortran-libs`
  LIBS="$ADIOS2_LIBS $LIBS"
  AC_LINK_IFELSE([
    AC_LANG_PROGRAM([], [[
        use adios2
        type(adios2_adios) :: adios
        type(adios2_io)    :: io
        integer            :: ierr
        call adios2_declare_io(io, adios, "testIO", ierr)
    ]])
  ], [
    AC_MSG_RESULT(yes)
  ], [
    AC_MSG_RESULT(no)
    AC_MSG_ERROR([ADIOS2 libraries not found.])
  ])

  FC="$FC_save"
  FCFLAGS="$FCFLAGS_save"
  LIBS="$LIBS_save"
  AC_LANG_POP([Fortran])

  AC_SUBST([ADIOS2_FCFLAGS])
  AC_SUBST([ADIOS2_LIBS])
])dnl CIT_ADIOS2_CONFIG

dnl end of file
