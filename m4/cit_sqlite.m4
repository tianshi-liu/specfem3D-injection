# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for sqlite3.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_SQLITE_HEADER
# ----------------------------------------------------------------------
AC_DEFUN([CIT_SQLITE3_HEADER], [
  cit_save_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $SQLITE3_INCLUDES"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_CHECK_HEADER([sqlite3.h], [], [
    AC_MSG_ERROR([sqlite3 header not found; try --with-sqlite-incdir=<sqlite3 include dir>"])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
])dnl CIT_SQLITE3_HEADER


# ----------------------------------------------------------------------
# CIT_SQLITE_LIB
# ----------------------------------------------------------------------
AC_DEFUN([CIT_SQLITE3_LIB], [
  cit_save_CPPFLAGS=$CPPFLAGS
  cit_save_LDFLAGS=$LDFLAGS
  cit_save_libs=$LIBS
  CPPFLAGS="$CPPFLAGS $SQLITE3_INCLUDES"
  LDFLAGS="$LDFLAGS $SQLITE3_LDFLAGS"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_CHECK_LIB(sqlite3, sqlite3_open, [],[
    AC_MSG_ERROR([sqlite3 library not found; try --with-sqlite-libdir=<sqlite3 lib dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
  LDFLAGS=$cit_save_ldflags
  LIBS=$cit_save_libs
])dnl CIT_SQLITE3_LIB


dnl end of file
