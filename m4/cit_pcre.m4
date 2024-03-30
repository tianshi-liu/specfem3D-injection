# -*- Autoconf -*-


# ======================================================================
# Autoconf macros for pcre.
# ======================================================================

# ----------------------------------------------------------------------
# CIT_PCRE_HEADER
# ----------------------------------------------------------------------
AC_DEFUN([CIT_PCRE_HEADER], [
  cit_save_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $PCRE_INCLUDES"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_CHECK_HEADER([pcre.h], [], [
    AC_MSG_ERROR([pcre header not found; try --with-pcre-incdir=<pcre include dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
])dnl CIT_PCRE_HEADER


# ----------------------------------------------------------------------
# CIT_PCRE_LIB
# ----------------------------------------------------------------------
AC_DEFUN([CIT_PCRE_LIB], [
  cit_save_cppflags=$CPPFLAGS
  cit_save_ldflags=$LDFLAGS
  cit_save_libs=$LIBS
  CPPFLAGS="$CPPFLAGS $PCRE_INCLUDES"
  LDFLAGS="$LDFLAGS $PCRE_LDFLAGS"
  AC_LANG(C++)
  AC_REQUIRE_CPP
  AC_MSG_CHECKING([for real_pcre in -lpcre])
  AC_CHECK_LIB(pcre, pcre2_compile, [],[
    AC_MSG_ERROR([pcre library not found; try --with-pcre-libdir=<pcre lib dir>])
  ])dnl
  CPPFLAGS=$cit_save_cppflags
  LDFLAGS=$cit_save_ldflags
  LIBS=$cit_save_libs
])dnl CIT_PCRE


dnl end of file
