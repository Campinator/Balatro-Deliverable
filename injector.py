import os
import subprocess
import sys
import tempfile
import re
import shutil


class LuaPatcher:
    def __init__(self, executable_path: str, seven_zip_path: str = "7z.exe"):
        self.executable_path = executable_path

        self.modifed_files = set()
        self.seven_zip_path = seven_zip_path

        if shutil.which(self.seven_zip_path) is None:
            print("7z.exe not found in PATH")
            print("Looking in C:\\Program Files\\7-Zip")
            if shutil.which("C:\\Program Files\\7-Zip\\7z.exe") is None:
                print("7z.exe could not be found. Please check your PATH or install 7-Zip.")
                sys.exit(1)
            else:
                self.seven_zip_path = "C:\\Program Files\\7-Zip\\7z.exe"

        # open SFX to edit lua source files
        self.dir = tempfile.TemporaryDirectory()

        subprocess.run([self.seven_zip_path, "x", f"-o{self.dir.name}", self.executable_path], check=True)


    def patch_lines_in_file(self, file_path: str, target_line, new_lines: list[str]) -> None:

        with open(os.path.join(self.dir.name, file_path), "r") as file:
            lines = file.readlines()

        line_index = None

        if type(target_line) == int and target_line < len(lines):
            line_index = target_line

        if type(target_line) == str:
            for i, line in enumerate(lines):
                # compare based on regex
                if re.search(target_line, line):
                    line_index = i
                    break

        if line_index is None:
            raise ValueError(f"Target line not found in {file_path}")
        
        lines.insert(line_index + 1, *new_lines)

        with open(os.path.join(self.dir.name, file_path), "w") as file:
            file.writelines(lines)
        
        self.modifed_files.add(file_path)
        print(f"Successfully patched {file_path}")


    def patch_append_function(self, function_body: str) -> None:
        with open(os.path.join(self.dir.name, "main.lua"), "a") as file:
            file.write("\n" + function_body)
        self.modifed_files.add("main.lua")
        print(f"Successfully added function to main.lua")


    def repack(self) -> None:
        # copy self.dir to same directory as the target executable for debugging purposes
        # shutil.copytree(self.dir.name, os.path.join(os.path.dirname(self.executable_path), os.path.basename(self.dir.name)))

        for file in self.modifed_files:
            subprocess.run([self.seven_zip_path, "a", self.executable_path, os.path.join(self.dir.name, file)], check=True)
            print(f"Successfully added {file} to {self.executable_path}")

        print(f"Successfully repacked {self.executable_path}")
        self.dir.cleanup()


def main():

    # Jacob patches

    modded_global_vars = """
    G.prev_hand = {}
    G.optimal_hand = {}
    G.optimal_hand_string = "Undefined"
    G.optimal_hand_type = "Undefined"
    G.optimal_score = 0
    G.played_hand = true
    """

    modded_draw_func = open("mods/jacob_draw.lua", "r").read()

    modded_calculate_score = open("mods/calculate_score.lua", "r").read()


    if len(sys.argv) != 2 or not os.path.exists(sys.argv[1]):
        print("Usage: python injector.py <path to executable>")
        sys.exit(1)
    

    patcher = LuaPatcher(sys.argv[1])

    patcher.patch_lines_in_file("main.lua", "G:draw()", [modded_draw_func])

    patcher.patch_lines_in_file("main.lua", 129, [modded_global_vars])

    patcher.patch_append_function(modded_calculate_score)

    patcher.repack()

if __name__ == "__main__":
    main()