import os
import os
import sys


TARGET_EXTENSION = "djvu"
PDF2DJVU_OPTIONS = "--jobs=2 --no-metadata -q"


def change_extension(file_path, new_extension):
    base_name, _ = os.path.splitext(file_path)
    return f"{base_name}.{new_extension}"


def convert_file(file_path):
    if not file_path.lower().endswith(".pdf"):
        print(f"[~] Skipping non-PDF file: {file_path}")
        return False

    print(f"[+] Converting PDF file: {file_path}...")
    new_path = change_extension(file_path, TARGET_EXTENSION)

    cmd = f'pdf2djvu "{file_path}" {PDF2DJVU_OPTIONS} -o "{new_path}"'

    try:
        exit_code = os.system(cmd)
        if exit_code == 0:
            print(f"[+] Successfully converted to: {new_path}")
        else:
            print(f"[-] Error converting file {file_path}. Exit code: {exit_code}")
    except Exception as e:
        print(f"[-] An exception occurred while trying to convert {file_path}: {e}")

    return True


def convert_directory_recursively(root_dir_path):
    print(f"[+] Starting recursive conversion in directory: {root_dir_path}...")
    files_converted_count = 0
    files_skipped_count = 0

    if not os.path.isdir(root_dir_path):
        print(
            f"[-] Error: Provided path '{root_dir_path}' is not a directory or does not exist."
        )
        return

    for dirpath, _, filenames in os.walk(root_dir_path):
        print(f"[*] Scanning directory: {dirpath}")
        for filename in filenames:
            full_file_path = os.path.join(dirpath, filename)
            if convert_file(
                full_file_path
            ):  # convert_file now returns True if conversion was attempted
                files_converted_count += 1  # This counts attempted conversions, not necessarily successful ones
            else:  # File was skipped (not a PDF)
                files_skipped_count += 1

    print(f"[+] Recursive conversion finished for directory: {root_dir_path}")
    print(
        f"[+] Summary: Attempted conversions on {files_converted_count} PDF files, skipped {files_skipped_count} non-PDF files."
    )
    return


def main():
    if len(sys.argv) != 3:
        print("Usage: python djvu_converter.py -[dir|file] <path>")
        print("Examples:")
        print("  python djvu_converter.py -file /path/to/your/document.pdf")
        print("  python djvu_converter.py -dir /path/to/your/folder_with_pdfs")
        return

    mode = sys.argv[1]
    path_arg = sys.argv[2]

    if not os.path.exists(path_arg):
        print(f"[-] Error: The specified path '{path_arg}' does not exist.")
        return

    if mode == "-dir":
        if not os.path.isdir(path_arg):
            print(
                f"[-] Error: '{path_arg}' is not a directory. Use -file for single files."
            )
            return
        convert_directory_recursively(path_arg)
    elif mode == "-file":
        if not os.path.isfile(path_arg):
            print(f"[-] Error: '{path_arg}' is not a file. Use -dir for directories.")
            return
        convert_file(path_arg)
    else:
        print(f"[-] Error: Invalid mode '{mode}'. Use -dir or -file.")
        print("Usage: python djvu_converter.py -[dir|file] <path>")

    return


if __name__ == "__main__":
    main()
