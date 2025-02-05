#!/usr/bin/env python3

import os
import sys
import subprocess
import re

# Supported languages and their commands
LANGUAGES = {
    "php": {"start": "<php>", "end": "</php>", "command": "php"},
    "python": {"start": "<python>", "end": "</python>", "command": "python3"},
    "html": {"start": "<html>", "end": "</html>", "command": "cat"},
    "js": {"start": "<js>", "end": "</js>", "command": "node"},
}

def read_file(file_path):
    """Reads the content of a file."""
    with open(file_path, "r") as file:
        return file.read()

def extract_blocks(code):
    """Extracts code blocks for each language."""
    blocks = []
    for lang, config in LANGUAGES.items():
        pattern = re.compile(f"{re.escape(config['start'])}(.*?){re.escape(config['end'])}", re.DOTALL)
        for match in pattern.findall(code):
            blocks.append((lang, match.strip()))
    return blocks

def execute_code(lang, code):
    """Executes the given code block using the appropriate engine."""
    temp_file = f"temp.{lang}"
    with open(temp_file, "w") as file:
        file.write(code)
    command = LANGUAGES[lang]["command"]
    result = subprocess.run([command, temp_file], capture_output=True, text=True)
    os.remove(temp_file)
    return result.stdout

def execute_aya_file(file_path):
    """Executes an Arya (.aya) file."""
    if not file_path.endswith(".aya"):
        print("Error: File must have .aya extension")
        return

    code = read_file(file_path)
    blocks = extract_blocks(code)

    for lang, snippet in blocks:
        print(f"\nExecuting {lang.upper()} block...")
        output = execute_code(lang, snippet)
        print(output)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: arya <file.aya>")
    else:
        execute_aya_file(sys.argv[1])
