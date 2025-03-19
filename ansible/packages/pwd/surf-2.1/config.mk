# surf version
VERSION = 2.1

# Customize below to fit your system

# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
LIBPREFIX = $(PREFIX)/lib
LIBDIR = $(LIBPREFIX)/surf

# X11
X11INC = `pkg-config --cflags x11`
X11LIB = `pkg-config --libs x11`

# GTK and WebKit (using 4.1, as confirmed by your pkg-config output)
GTKINC = `pkg-config --cflags gtk+-3.0 gcr-3 webkit2gtk-4.1`
GTKLIB = `pkg-config --libs gtk+-3.0 gcr-3 webkit2gtk-4.1`

# Web extension (using 4.1, with glib-2.0 and gio-2.0 for full GLib support)
WEBEXTINC = `pkg-config --cflags webkit2gtk-4.1 webkit2gtk-web-extension-4.1 glib-2.0 gio-2.0`
WEBEXTLIBS = `pkg-config --libs webkit2gtk-4.1 webkit2gtk-web-extension-4.1 glib-2.0 gio-2.0`

# includes and libs
INCS = $(X11INC) $(GTKINC)
LIBS = $(X11LIB) $(GTKLIB) -lgthread-2.0

# flags
CPPFLAGS = -DVERSION=\"$(VERSION)\" -DGCR_API_SUBJECT_TO_CHANGE \
           -DLIBPREFIX=\"$(LIBPREFIX)\" -DWEBEXTDIR=\"$(LIBDIR)\" \
           -D_DEFAULT_SOURCE
SURFCFLAGS = -fPIC $(INCS) $(CPPFLAGS)
WEBEXTCFLAGS = -fPIC $(WEBEXTINC)

