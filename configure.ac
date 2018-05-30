# -*- Autoconf -*-

AC_PREREQ([2.69])

AC_INIT([aws-cluster-up], [0.1], [aim@frobware.com])
AC_CONFIG_AUX_DIR([config])
AC_CANONICAL_TARGET
AC_CANONICAL_HOST
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([foreign dist-bzip2 no-dist-gzip])
AM_MAINTAINER_MODE([enable])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# Checks for programs.

AC_CHECK_PROG(VIRSH_CHECK,jq,yes)
if test x"$VIRSH_CHECK" != x"yes"; then
    AC_MSG_ERROR([Please install package jq.])
fi

AC_CHECK_PROG(VIRT_INSTALL_CHECK,aws,yes)
if test x"$VIRT_INSTALL_CHECK" != x"yes"; then
    AC_MSG_ERROR([Please install aws-cli.])
fi

AC_CHECK_PROG(GENISOIMAGE_INSTALL_CHECK,terraform,yes)
if test x"$GENISOIMAGE_INSTALL_CHECK" != x"yes"; then
    AC_MSG_ERROR([Please install terraform.])
fi

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
