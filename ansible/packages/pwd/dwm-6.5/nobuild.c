#define NOBUILD_IMPLEMENTATION
#include "./nobuild.h"

#define BIN "dwm"
#define CC	"clang"
#define OLD "c.old"
#define PREFIX "/usr/local/bin/"
#define VERSION "6.4"
#define MANPREFIX "/usr/local/share/man"
#define CFLAGS	"-g",			\
	"-std=c99", 				\
	"-pedantic",				\
	"-Wall",					\
	"-I/usr/X11R6/include",		\
	"-I/usr/include/freetype2",	\
	"-D_DEFAULT_SOURCE",		\
	"-D_BSD_SOURCE",			\
	"-D_POSIX_C_SOURCE=2",		\
	"-DVERSION=\""VERSION"\" ",	\
	"-DXINERAMA",				\
	"-O3"

#define LDFLAGS "-L/usr/X11R6/lib", \
	"-lX11", 			\
	"-lXinerama", 		\
	"-lfontconfig",		\
	"-lXft", 			\
	"-lXrender",	\
	"-lxkbcommon"

static const char *SOURCES[]={"drw.c", "dwm.c", "util.c"};
static const char *OBJECTS[]={"drw.o", "dwm.o", "util.o"};

void Compile(void) {
	for(int i=0; i <= 2; i++ ){
		CMD(CC, "-c", CFLAGS, SOURCES[i]);
	}
}

void Link(void) {
	for(int i=0; i <= 2; i++ ){
		CMD(CC, "-o", BIN, OBJECTS[0], OBJECTS[1], OBJECTS[2], LDFLAGS, NULL );
	}
}

void Install(void) {
	CMD("sudo", "cp", "-f", BIN, PREFIX);
}

void Uninstall(void) {
	CMD("sudo", "rm", "-v", PREFIX""BIN);
}

void Wipe(void) {
	size_t objarr = (sizeof(OBJECTS) / sizeof(OBJECTS[1]));
	for ( unsigned long int i=0; i < objarr ; i++) {
		CMD("rm", OBJECTS[i]);
	}
	CMD("rm", BIN, "c.old");
}

//This will  only work if you set dwm loop on you startx file or equivalent
void Restart(void) {
  CMD("sudo", "killall", BIN);
}

int main(int argc, char *argv[]) {
	GO_REBUILD_URSELF(argc, argv);
	if (argc < 2 ){
		printf("Usage: %s [-r] [-i] [-c]\n", argv[0]);
		return EXIT_SUCCESS;
	}

	for (int i = 1; i < argc; i++) {
		char *arg = argv[i];

		if (arg[0] == '-') {
			for (unsigned long int j = 1; j < strlen(arg); j++) {

				switch (arg[j]) {
					case 'c': Compile();	  break;
					case 'l': Link();	      break;
					case 'i': Install();	  break;
					case 'r': Restart();	  break;
					case 'u': Uninstall(); 	break;
					case 'w': Wipe();	      break;
					default: printf("Unknown option: %c\n", arg[j]);
					break;
				}
			}
		}
	}
	return EXIT_SUCCESS;
}
