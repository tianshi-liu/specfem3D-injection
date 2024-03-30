# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for muParser.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_MUPARSER_HEADER
# ----------------------------------------------------------------------
AC_DEFUN([CIT_MUPARSER_HEADER], [
  cit_save_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $MUPARSER_INCLUDES"
  AC_LANG(C)
  AC_CHECK_HEADER([muParserDLL.h], [], [
    AC_MSG_ERROR([muParser header (v2.3.x or later) not found; try --with-muparser-incdir=<muParser include dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
])dnl CIT_MUPARSER_HEADER

# ----------------------------------------------------------------------
# CIT_MUPARSER_LIB
# ----------------------------------------------------------------------
AC_DEFUN([CIT_MUPARSER_LIB], [
  cit_save_cppflags=$CPPFLAGS
  cit_save_ldflags=$LDFLAGS
  cit_save_libs=$LIBS
  CPPFLAGS="$CPPFLAGS $MUPARSER_INCLUDES"
  LDFLAGS="$LDFLAGS $MUPARSER_LDFLAGS"
  AC_LANG(C++)
  AC_CHECK_LIB(muparser, mupCreate, [],[
    AC_MSG_ERROR([muParser library (v2.3.x or later) not found; try --with-muparser-libdir=<muParser lib dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
  LDFLAGS=$cit_save_ldflags
  LIBS=$cit_save_libs
])dnl CIT_MUPARSER_LIB

dnl end of file
