//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
  {"", "~/.config/dotfiles/dwmblocks/bin/disksize", 120, 3},
  {"", "~/.config/dotfiles/dwmblocks/bin/cputemp", 15, 2},
  {"", "~/.config/dotfiles/dwmblocks/bin/time", 20, 1},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
