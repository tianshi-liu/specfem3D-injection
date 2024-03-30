# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for sqlite3.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_TIFF_HEADER
# ----------------------------------------------------------------------
AC_DEFUN([CIT_TIFF_HEADER], [
  cit_save_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $TIFF_INCLUDES"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_CHECK_HEADER([tiff.h], [], [
    AC_MSG_ERROR([tiff header not found; try --with-tiff-incdir=<tiff include dir>"])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
])dnl CIT_TIFF_HEADER


# ----------------------------------------------------------------------
# CIT_TIFF_LIB
# ----------------------------------------------------------------------
AC_DEFUN([CIT_TIFF_LIB], [
  cit_save_CPPFLAGS=$CPPFLAGS
  cit_save_LDFLAGS=$LDFLAGS
  cit_save_libs=$LIBS
  CPPFLAGS="$CPPFLAGS $TIFF_INCLUDES"
  LDFLAGS="$LDFLAGS $TIFF_LDFLAGS"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_CHECK_LIB(tiff, TIFFOpen, [],[
    AC_MSG_ERROR([tiff library not found; try --with-tiff-libdir=<tiff lib dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
  LDFLAGS=$cit_save_ldflags
  LIBS=$cit_save_libs
])dnl CIT_TIFF_LIB


dnl end of file
