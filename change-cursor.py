# This script changes the cursor size and the cursor name.
# I made this script because LXAppearance wasn't working
# all the time.


def change_gtk_cursor(cursor_name, cursor_size):
    with open("~/.config/gtk-3.0/settings.ini", "r+") as f:
        d = f.readlines()
        f.seek(0)
        for i in d:
            if not i.startswith("gtk-cursor-theme"):
                f.write(i)
        f.write(f"gtk-cursor-theme-name={cursor_name}")
        f.write(f"gtk-cursor-theme-size={cursor_size}")
        f.truncate()
        f.close()
    return


def change_xorg_cursor(cursor_name, cursor_size):
    with open("~/.icons/default/index.theme", "r+") as f:
        d = f.readlines()
        f.seek(0)
        for i in d:
            if not i.startswith("Inherits"):
                f.write(i)
        f.write(f"Inherits={cursor_name}")
        f.truncate()
        f.close()
    return


def main():
    cursor_name = str(input("cursor name: "))
    cursor_size = int(input("cursor size: "))

    print("changing gtk cursor...")
    change_gtk_cursor(cursor_name, cursor_size)

    print("changing xorg cursor...")
    change_xorg_cursor(cursor_name, cursor_size)

    print("done.")
    return


if __name__ == "__main__":
    main()
