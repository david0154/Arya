import subprocess
import os

# Supported languages and their corresponding commands
LANGUAGES = {
    "php": {"start": "<php>", "end": "</php>", "command": "php"},
    "python": {"start": "<python>", "end": "</python>", "command": "python3"},
    "html": {"start": "<html>", "end": "</html>", "command": "cat"},
    "js": {"start": "<js>", "end": "</js>", "command": "node"},
    "java": {"start": "<java>", "end": "</java>", "command": "java", "compile": "javac"},
    "go": {"start": "<go>", "end": "</go>", "command": "go run"},
    "c": {"start": "<c>", "end": "</c>", "command": "gcc", "compile": "gcc -o temp_c"},
    "rust": {"start": "<rust>", "end": "</rust>", "command": "cargo run", "compile": "cargo build"},
}

def execute_code(lang, code):
    """Executes the given code block using the appropriate engine."""
    temp_file = f"temp.{lang}"
    with open(temp_file, "w") as file:
        file.write(code)
    
    if lang == "java":
        # Compile and run Java
        compile_command = LANGUAGES[lang].get("compile", "")
        if compile_command:
            subprocess.run([compile_command, temp_file], capture_output=True, text=True)
            temp_file = "temp.class"  # Java generates .class file
    elif lang == "go" or lang == "rust":
        # For Go and Rust, we can directly run without separate compilation.
        pass
    elif lang == "c":
        # Compile and run C
        subprocess.run([LANGUAGES[lang]["compile"], temp_file], capture_output=True, text=True)
        temp_file = "temp_c"  # C generates an executable
    else:
        # Default to non-compiling languages (PHP, Python, JS, HTML)
        pass

    # Execute the code
    command = LANGUAGES[lang]["command"]
    result = subprocess.run([command, temp_file], capture_output=True, text=True)
    os.remove(temp_file)  # Clean up temporary file
    return result.stdout

if __name__ == "__main__":
    code = input("Enter code to execute: ")
    lang = input("Enter language (php, python, js, java, go, c, rust): ")
    output = execute_code(lang, code)
    print(output)
