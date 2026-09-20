AC_INIT([gnome-config], [1.0])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_WITH([claudedir],
    [AS_HELP_STRING([--with-claudedir=DIR], [Path to claude])],
    [claudedir="$withval"],
    [claudedir="$HOME/.claude"]
)
AC_SUBST([claudedir])

AC_ARG_WITH([copilotdir],
    [AS_HELP_STRING([--with-copilotdir=DIR], [Path to copilot])],
    [copilotdir="$withval"],
    [copilotdir="$HOME/.copilot"]
)
AC_SUBST([copilotdir])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
