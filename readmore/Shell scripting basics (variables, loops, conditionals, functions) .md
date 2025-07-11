All right, let's break down shell scripting basics, from the fundamentals to more advanced concepts, covering variables, loops, conditionals, and functions. This will focus on Bash (Bourne Again SHell), which is the default shell on Ubuntu and most Linux distributions.

## Shell Scripting Basics (Bash)

Shell scripting allows you to automate tasks, combine multiple commands, and perform complex operations by writing sequences of commands that the shell can execute. It's an incredibly powerful tool for system administration, development, and daily tasks.

### Part 1: Fundamentals (Beginner)

#### Theory

  * **What is a Shell Script?**
    A shell script is a plain text file containing a sequence of commands that are executed by the shell, just as if you typed them directly into the terminal.

  * **Shebang (`#!`):**
    The very first line of a shell script should be the "shebang" (or "hashbang"). It tells the operating system which interpreter to use to execute the script.

      * `#!/bin/bash`: For Bash scripts (most common).
      * `#!/bin/sh`: For POSIX-compliant shell scripts (more portable, but fewer Bash-specific features).

  * **Comments:**
    Lines starting with `#` are comments and are ignored by the shell. Use them to explain your code.

  * **Executing a Script:**

    1.  **Make it Executable:** `chmod +x your_script.sh`
    2.  **Run it:**
          * `./your_script.sh` (if in the current directory)
          * `/path/to/your_script.sh` (using its full path)
          * `bash your_script.sh` (explicitly run with bash, even if not executable)

#### Practical Knowledge

**1. Basic "Hello World" Script:**

Create a file named `hello.sh`:

```bash
#!/bin/bash
# This is my first shell script

echo "Hello, world!"
echo "Today is $(date)"
```

Execute it:

```bash
chmod +x hello.sh
./hello.sh
```

Output:

```
Hello, world!
Today is Fri Jun 28 06:50:01 PM +0545 2024
```

*(Self-correction: The date will be the actual current date and time.)*

**2. Variables:**

Variables store data. In Bash, variables are typeless (they store everything as strings).

  * **Defining:** `VARIABLE_NAME="value"` (no spaces around `=`)
  * **Accessing:** `${VARIABLE_NAME}` or `$VARIABLE_NAME` (curly braces are good practice for clarity).
  * **Read-only:** `readonly VARIABLE_NAME`

<!-- end list -->

```bash
#!/bin/bash

NAME="Alice"
AGE=30 # Numbers are also treated as strings by default

echo "My name is $NAME."
echo "I am $AGE years old."

# Variables from command-line arguments
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@" # Or $*
echo "Number of arguments: $#"

# Arithmetic operations (requires double parentheses)
NUM1=10
NUM2=5
SUM=$((NUM1 + NUM2))
echo "Sum: $SUM"

# User input
read -p "What is your favorite color? " COLOR
echo "Your favorite color is $COLOR."
```

Save as `vars.sh`, make executable, and run with arguments:

```bash
./vars.sh apple banana
```

**3. Command Substitution:**

Use backticks `` `command` `` or `$(command)` to capture the output of a command and use it as a string. `$(command)` is preferred as it's nestable and generally clearer.

```bash
#!/bin/bash

CURRENT_DIR=$(pwd)
LISTING=$(ls -lh)

echo "You are currently in: $CURRENT_DIR"
echo "Files in this directory:"
echo "$LISTING"
```

### Part 2: Conditionals and Control Flow (Intermediate)

#### Theory

  * **Conditional Statements (`if`, `elif`, `else`):**
    Allow your script to make decisions based on whether a condition is true or false.

      * Syntax: `if condition; then commands; fi`
      * Conditions are typically enclosed in `[ ]` (test command) or `[[ ]]` (Bash-specific, more powerful).
      * **Test Operators:**
          * **String comparison:** `= (equals), != (not equals), < (less than), > (greater than)`
          * **Numeric comparison:** `-eq (equals), -ne (not equals), -gt (greater than), -ge (greater or equal), -lt (less than), -le (less or equal)`
          * **File tests:** `-f (file exists and is regular), -d (directory exists), -e (file/dir exists), -r (readable), -w (writable), -x (executable)`
          * **Logical operators (`[[ ]]`):** `&& (AND), || (OR)`

  * **Case Statements:**
    Provide a multi-way branching mechanism, similar to `switch` in other languages. Useful for handling multiple possible values of a variable.

#### Practical Knowledge

**1. `if-else` Example:**

```bash
#!/bin/bash

read -p "Enter a number: " NUMBER

if [[ "$NUMBER" -gt 10 ]]; then
    echo "$NUMBER is greater than 10."
elif [[ "$NUMBER" -eq 10 ]]; then
    echo "$NUMBER is exactly 10."
else
    echo "$NUMBER is less than 10."
fi

# File existence check
if [[ -f "hello.sh" ]]; then
    echo "hello.sh exists and is a regular file."
fi

if [[ ! -d "non_existent_dir" ]]; then
    echo "non_existent_dir does not exist as a directory."
fi
```

**2. `case` Statement Example:**

```bash
#!/bin/bash

read -p "Enter 'start', 'stop', or 'restart': " ACTION

case "$ACTION" in
    start)
        echo "Starting service..."
        # Add actual start command here
        ;;
    stop)
        echo "Stopping service..."
        # Add actual stop command here
        ;;
    restart)
        echo "Restarting service..."
        # Add actual restart command here
        ;;
    *) # Default case
        echo "Invalid action: $ACTION. Please use start, stop, or restart."
        ;;
esac
```

### Part 3: Loops (Intermediate)

#### Theory

  * **`for` loop:** Iterates over a list of items (words, numbers, files).
  * **`while` loop:** Continues as long as a condition is true.
  * **`until` loop:** Continues as long as a condition is false.

#### Practical Knowledge

**1. `for` Loop (Iterating over items):**

```bash
#!/bin/bash

echo "Iterating over a list of fruits:"
for FRUIT in apple banana cherry; do
    echo "I like $FRUIT."
done

echo "Iterating over files in current directory:"
for FILE in *; do # * expands to all files/directories
    echo "Found file: $FILE"
done

# C-style for loop (Bash specific)
echo "Counting from 1 to 5:"
for (( i=1; i<=5; i++ )); do
    echo "Count: $i"
done
```

**2. `while` Loop (Conditional Loop):**

```bash
#!/bin/bash

COUNT=1
while [[ "$COUNT" -le 5 ]]; do
    echo "Count is: $COUNT"
    ((COUNT++)) # Increment COUNT
    sleep 0.5   # Pause for 0.5 seconds
done

# Read file line by line
echo "Reading file line by line:"
while IFS= read -r LINE; do
    echo "Line: $LINE"
done < "hello.sh" # Redirect hello.sh into the loop
```

**3. `until` Loop:**

```bash
#!/bin/bash

# Loop until a file exists
echo "Waiting for 'ready_file.txt' to appear..."
until [[ -f "ready_file.txt" ]]; do
    echo "Still waiting..."
    sleep 2
done
echo "ready_file.txt found! Proceeding..."
```

### Part 4: Functions (Advanced)

#### Theory

  * **Functions:** Reusable blocks of code within your script. They help organize code, improve readability, and prevent repetition (DRY - Don't Repeat Yourself).
  * **Local Variables:** Variables declared with `local` inside a function are scoped only to that function, preventing interference with global variables.
  * **Return Values:** Functions return an exit status (0 for success, non-zero for error), accessed via `$?`. They don't directly "return" values like in other languages; you usually `echo` the value and capture it using command substitution.

#### Practical Knowledge

**1. Basic Function Definition and Call:**

```bash
#!/bin/bash

# Function definition
greet_user() {
    echo "Hello, $1!" # $1 refers to the first argument passed to the function
    echo "Welcome to the script."
}

# Call the function
greet_user "John Doe"
greet_user "Jane Smith"
```

**2. Function with Local Variables and Return Status:**

```bash
#!/bin/bash

check_file_existence() {
    local FILENAME="$1" # Declare FILENAME as a local variable
    if [[ -f "$FILENAME" ]]; then
        echo "$FILENAME exists."
        return 0 # Success
    else
        echo "$FILENAME does not exist."
        return 1 # Failure
    fi
}

check_file_existence "hello.sh"
if [[ $? -eq 0 ]]; then
    echo "Function confirmed hello.sh exists."
else
    echo "Function confirmed hello.sh does not exist."
fi

check_file_existence "non_existent_file.txt"
if [[ $? -ne 0 ]]; then
    echo "Function confirmed non_existent_file.txt does not exist."
fi
```

**3. Function Returning a Value (via `echo` and command substitution):**

```bash
#!/bin/bash

add_numbers() {
    local N1=$1
    local N2=$2
    local RESULT=$((N1 + N2))
    echo "$RESULT" # Output the result to stdout
}

SUM_VAL=$(add_numbers 15 25) # Capture the output
echo "The sum is: $SUM_VAL"
```

### Part 5: Advanced Topics & Best Practices (Expert Level)

#### Theory

  * **Error Handling:** How to deal with errors and unexpected situations (e.g., `set -e`, `trap`).
  * **Input/Output Redirection:** Manipulating standard input, output, and error streams (`>`, `>>`, `<`, `2>`, `&>`).
  * **Piping:** Chaining commands together using `|` to pass the output of one command as the input to another.
  * **Arrays:** Storing multiple values in a single variable.
  * **Debugging:** Techniques for finding errors in scripts.
  * **`getopts`:** For parsing command-line options and arguments gracefully.
  * **Subshells vs. Current Shell:** Understanding how commands are executed.

#### Practical Knowledge

**1. Error Handling (`set -e`, `set -u`, `set -o pipefail`, `trap`):**

```bash
#!/bin/bash
set -e          # Exit immediately if a command exits with a non-zero status.
set -u          # Treat unset variables as an error when substituting.
set -o pipefail # The return value of a pipeline is the status of the last command to exit with a non-zero status.

# Trap command for cleanup on exit, error, or interrupt
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/my_temp_file_$$
}
trap cleanup EXIT INT TERM # Execute cleanup on script exit, interrupt (Ctrl+C), or termination

echo "Creating a temp file..."
touch /tmp/my_temp_file_$$

# This command will fail, triggering set -e and thus the trap
# non_existent_command

echo "This line will not be reached if non_existent_command fails."
```

**2. Input/Output Redirection & Piping:**

```bash
#!/bin/bash

# Redirect stdout to a file
echo "This will be written to a file." > output.txt

# Append stdout to a file
echo "This will be appended." >> output.txt

# Redirect stderr to a file
ls /non_existent_dir 2> error.log

# Redirect stdout and stderr to the same file
ls /non_existent_dir &> combined_output.log

# Pipe output from one command to input of another
ls -l | grep "hello" # Find 'hello' in ls -l output
```

**3. Arrays:**

```bash
#!/bin/bash

# Indexed array
FRUITS=("Apple" "Banana" "Cherry")
echo "First fruit: ${FRUITS[0]}"
echo "All fruits: ${FRUITS[@]}"
echo "Number of fruits: ${#FRUITS[@]}"

# Loop through array
for FRUIT in "${FRUITS[@]}"; do
    echo "I love $FRUIT!"
done
```

**4. Debugging:**

  * **`bash -x script.sh`:** Executes the script in debug mode, printing each command before it's executed.
  * **`echo "Debug: Variable is $MY_VAR"`:** Simple `echo` statements for tracing.

**5. `getopts` for Command-line Options:**

For handling options like `script.sh -f input.txt -v --output result.log`.

```bash
#!/bin/bash

# Define options: f: expects an argument, v does not
while getopts "f:v" opt; do
  case "$opt" in
    f) FILE_PATH="$OPTARG" ;;
    v) VERBOSE=true ;;
    *) echo "Usage: $0 [-f file] [-v]"; exit 1 ;;
  esac
done
shift $((OPTIND - 1)) # Shift positional parameters past the options

echo "File Path: ${FILE_PATH:-'Not specified'}"
echo "Verbose: ${VERBOSE:-'false'}"
echo "Remaining arguments: $@"
```

Run as: `./script.sh -f mydata.txt -v arg1 arg2`

### Shell Scripting Best Practices:

  * **Be Specific with Shebang:** Use `#!/bin/bash` if you rely on Bash-specific features; otherwise, `#!/bin/sh` for portability.
  * **Quote Variables:** Always quote variables that might contain spaces or special characters (e.g., `"$MY_VAR"`) to prevent word splitting and globbing issues.
  * **Use `[[ ]]` for Conditionals:** It's safer and more powerful than `[ ]` for Bash-specific scripts.
  * **Use `local` in Functions:** Prevents unintended side effects on global variables.
  * **Descriptive Variable Names:** Use clear names like `USER_NAME` instead of `u`.
  * **Add Comments:** Explain complex logic or non-obvious parts of your code.
  * **Error Handling:** Use `set -e`, `set -u`, `set -o pipefail`, and `trap` for robust scripts.
  * **Validate Input:** Always validate user input or command-line arguments to prevent unexpected behavior or security vulnerabilities.
  * **Test Thoroughly:** Test your scripts with different inputs and scenarios.
  * **Keep it Simple:** Break down complex tasks into smaller, manageable functions.

Shell scripting is a skill that improves with practice. Start with simple automation tasks, gradually incorporate more complex logic, and don't hesitate to consult the Bash manual (`man bash`) or online resources when you get stuck.