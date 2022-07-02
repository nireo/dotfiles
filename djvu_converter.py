import os
import sys


# change the file's extension to djvu
def changeExtension(path):
    splitted = path.split(".")
    splitted[len(splitted) - 1] = "djvu"

    return ".".join(splitted)


# convert a given file using the pdf2djvu command line tool
def convertFile(path):
    print(f"[+] converting file {path}...")
    new_path = changeExtension(path)
    cmd = f"pdf2djvu {path} -o {new_path}"
    os.system(cmd)
    print(f"[+] converted file {new_path}")
    return


# make this a separate method, such that we can call it recursively on functions
def convertDirectory(dir_path):
    print(f"[+] converting directory {dir_path}...")
    for filename in os.listdir(dir_path):
        path = os.path.join(dir_path, filename)
        if os.path.isfile(path):
            convertFile(path)
        elif os.path.isdir(path):
            convertDirectory(path)
    return


def main():
    if len(sys.argv) != 3:
        print("usage: djvu_converter.py -[dir/file] path")
    is_dir = sys.argv[1] == "-dir"
    path = sys.argv[2]

    if is_dir:
        convertDirectory(path)
    else:
        convertFile(path)
    return


if __name__ == "__main__":
    main()
