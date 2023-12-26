# add_suffix_if_needed function
# This function appends a suffix to a given path if the path does not already end with the specified suffix.

# Parameters:
#   $1: The original path
#   $2: The suffix to be added

# Example usage:
# original_path="/some/directory"
# suffix_to_add="files"
# modified_path=$(add_suffix_if_needed "$original_path" "$suffix_to_add")
# echo "Modified Path: $modified_path"
function add_suffix_if_needed() {
    local path="$1"
    local suffix="$2"
    if [[ "$path" != *"$suffix" ]]; then
        path="$path/$suffix"
    fi
    echo "$path"
}

# wsd_exe_cmd function
# Function to print and execute a command
function wsd_exe_cmd() {
    local command="$*"
    # Print the command
    echo "🖥️: $command"
    # Execute the command without using eval
    "$@"
    # eval "$command"
}

# wsd_exe_cmd_hook function
# Print a command
function wsd_exe_cmd_hook() {
    local command="$*"
    # Print the command
    echo "👉 use: $command"
}

# allow_execute_perm function
# Grants execute permission to the specified file or directory.
#
# Usage:
#   allow_execute_perm <file/dir>
#
# Description:
#   The 'allow_execute_perm' function sets the execute permission for the specified <file/dir>.
#   This is useful for making a script or binary executable.
#
# Parameters:
#   - file/dir: The path to the file or directory for which execute permission is to be granted.
#
# Example:
#   allow_execute_perm ./my_script.sh
#
# Recommendations:
#   - Use this function responsibly and only on files that should be executable.
#   - Ensure that granting execute permission is necessary for the specified file or directory.
function allow_execute_perm() {
    if [ $# -lt 1 ]; then
        echo "Usage: allow_execute_perm <file/dir>"
        return 1
    fi

    wsd_exe_cmd chmod +x "$1"
    echo "🍺 Execute permission granted to $1"
}
alias allowexecuteperm="allow_execute_perm"

# allow_full_perm function
# Grants full permissions (read, write, and execute) to the specified file or directory.
#
# Usage:
#   allow_full_perm <file/dir>
#
# Description:
#   The 'allow_full_perm' function sets the permission to 777 for the specified <file/dir>.
#   This provides read, write, and execute permissions to the owner, group, and others.
#
# Parameters:
#   - file/dir: The path to the file or directory for which full permissions are to be granted.
#
# Example:
#   allow_full_perm ./my_script.sh
#
# Recommendations:
#   - Use this function responsibly and only on files or directories that require full permissions.
#   - Granting full permissions should be done with caution, especially for security-sensitive files.
function allow_full_perm() {
    if [ $# -lt 1 ]; then
        echo "Usage: allow_full_perm <file/dir>"
        return 1
    fi
    wsd_exe_cmd sudo chmod 777 "$1"
    echo "🍺 Full permissions granted to $1 (read, write and execute)"
}
alias allowfullperm="allow_full_perm"

# create_file_if_not_exists function
# Creates a file with administrator privileges if it doesn't exist.
# Parameters:
#   $1: File path
# Returns:
#   0 on success, 1 on error
function create_file_if_not_exists() {
    if [ $# -lt 1 ]; then
        echo "Usage: create_file_if_not_exists <filename>"
        return 1
    fi
    local filename="$1"
    local directory="$(dirname "$filename")"
    # Check if the directory exists
    if [ ! -d "$directory" ]; then
        echo "📁 Directory does not exist. Creating $directory with admin privileges..."
        # Use sudo to create the directory with elevated privileges
        sudo mkdir -p "$directory"
        # Check if the directory was successfully created
        if [ $? -eq 0 ]; then
            echo "✅ Directory created successfully."
        else
            echo "❌ Error: Failed to create the directory."
            return 1
        fi
    fi

    # Check if the file exists
    if [ ! -e "$filename" ]; then
        echo "📄 File does not exist. Creating $filename with admin privileges..."
        # Use sudo to create the file with elevated privileges
        sudo touch "$filename"
        # Check if the file was successfully created
        if [ $? -eq 0 ]; then
            echo "✅ File created successfully."
            return 0
        else
            echo "❌ Error: Failed to create the file."
            return 1
        fi
        # the file permissions to allow read and write access only for the owner and no access for others.
        allow_full_perm "$filename"
    else
        # the file permissions to allow read and write access only for the owner and no access for others.
        allow_full_perm "$filename"
    fi
    return 0
}

# Example usage:
# create_file_if_not_exists "/Users/arisnguyenit97/wsdkit.conf/assets/secrets.txt"

# Check port running
function check_port() {
    if [ $# -ne 1 ]; then
        echo "Usage: check_port <port>"
        return 1
    fi
    wsd_exe_cmd lsof -nP -iTCP:"$1" | grep LISTEN
}

# Kill port running
# Kill processes using specified ports
function kill_ports() {
    echo "Enter the ports you want to kill (separated by spaces): \c"
    read ports

    # Loop through each port in the input
    for port in $ports; do
        # Check if the port is valid
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo "❌ Invalid port number: $port. Skipping..."
            continue
        fi

        # Get the process running on the specified port
        local process=$(lsof -n -iTCP:$port -sTCP:LISTEN -t)

        # Check if any process is running on the specified port
        if [ -z "$process" ]; then
            echo "No process is using port $port. Skipping..."
            continue
        fi

        # Ask for confirmation before killing the process
        echo -n "Are you sure you want to kill the process running on port $port? (y/n) "
        read confirm
        if [ "$confirm" != "y" ]; then
            echo "Process kill operation canceled for port $port."
            continue
        fi

        # Kill the process using the specified port
        kill $process
        echo "🍺 Process on port $port has been killed."
    done
}

# Copy filename by new filename
function copy_file() {
    if [ $# -ne 2 ]; then
        echo "Usage: copy_file <source_filename> <new_filename>"
        return 1
    fi

    local source="$1"
    local filename="$2"
    local destination="$PWD/$filename"

    if [ -e "$destination" ]; then
        echo "❌ Error: Destination file already exists."
        return 1
    fi

    wsd_exe_cmd cp "$source" "$destination"
    echo "🍺 File copied successfully to $destination"
}

# Copy filename by new filename (copy from one file to many files)
function copy_files() {
    if [ $# -lt 2 ]; then
        echo "Usage: copy_files <source_filename> <new_filename1> [<new_filename2> ...]"
        return 1
    fi

    local source="$1"
    shift # Remove the source file from the arguments
    local destination="$PWD"

    for filename in "$@"; do
        local destination_file="$destination/$filename"

        if [ -e "$destination_file" ]; then
            echo "❌ Error: Destination file '$filename' already exists."
            continue
        fi

        wsd_exe_cmd cp "$source" "$destination_file"
        echo "🍺 File copied successfully to $destination_file"
    done
}

# Move file to a specified folder
function move_file() {
    if [ $# -ne 2 ]; then
        echo "Usage: move_file <source_filename> <destination_folder>"
        return 1
    fi

    local source="$1"
    local destination_folder="$2"

    if [ ! -d "$destination_folder" ]; then
        echo "❌ Error: Destination folder does not exist."
        return 1
    fi

    local destination="$destination_folder/$(basename "$source")"

    if [ -e "$destination" ]; then
        echo "❌ Error: Destination file already exists."
        return 1
    fi

    wsd_exe_cmd mv "$source" "$destination"
    echo "🍺 File moved successfully to $destination"
}

# Move multiple files to a specified folder
function move_files() {
    if [ $# -lt 2 ]; then
        echo "Usage: move_files <destination_folder> <file1> <file2> ... <fileN>"
        return 1
    fi

    local destination_folder="$1"
    shift # Remove the first argument (destination folder) from the list

    if [ ! -d "$destination_folder" ]; then
        echo "❌ Error: Destination folder does not exist."
        return 1
    fi

    for source in "$@"; do
        if [ ! -e "$source" ]; then
            echo "❌ Error: Source file '$source' does not exist."
            return 1
        fi

        local destination="$destination_folder/$(basename "$source")"

        if [ -e "$destination" ]; then
            echo "❌ Error: Destination file '$destination' already exists."
            return 1
        fi

        wsd_exe_cmd mv "$source" "$destination"
        echo "🍺 File '$source' moved successfully to $destination"
    done
}

# Rename file or directory
function rename_file() {
    if [ $# -ne 2 ]; then
        echo "Usage: rename_file <old_name> <new_name>"
        return 1
    fi

    local old_name="$1"
    local new_name="$2"
    local old_path="$PWD/$old_name"
    local new_path="$PWD/$new_name"

    if [ ! -e "$old_path" ]; then
        echo "❌ Error: Source file/directory does not exist."
        return 1
    fi

    if [ -e "$new_path" ]; then
        echo "❌ Error: Destination file/directory already exists."
        return 1
    fi

    wsd_exe_cmd mv "$old_path" "$new_path"
    echo "🍺 File/directory renamed successfully to $new_path"
}

# chmod_info function
# Provides information about the 'chmod' command, including its usage, options, and modes.
#
# Usage:
#   chmod_info
#
# Description:
#   The 'chmod_info' function displays information about the 'chmod' command, explaining its usage,
#   options, and modes for changing file mode bits. It covers both numeric and symbolic notations,
#   file permissions, and provides examples of using the 'chmod' command.
function chmod_info() {
    echo "chmod - Change file mode bits"
    echo
    echo "Usage: chmod [OPTIONS] MODE FILE"
    echo
    echo "Options:"
    echo "  -c  Like verbose but report only when a change is made"
    echo "  -f  Suppress most error messages"
    echo "  -R  Change files and directories recursively"
    echo "  -v  Output a diagnostic for every file processed"
    echo "  --help  Display this help and exit"
    echo
    echo "MODE can be specified in several ways:"
    echo
    echo "Numeric Notation:"
    echo "  3-digit octal number: e.g., 644, 755"
    echo "    First digit: owner permissions"
    echo "    Second digit: group permissions"
    echo "    Third digit: others permissions"
    echo "    4: read, 2: write, 1: execute"
    echo "    Sum the desired numbers to set the mode"
    echo
    echo "Symbolic Notation:"
    echo "  Symbolic notation: e.g., u=rw,g=r,o=r"
    echo "    u: user, g: group, o: others, a: all"
    echo "    r: read, w: write, x: execute"
    echo "    +: add permission, -: remove permission, =: set permission"
    echo "    Use commas to separate multiple settings"
    echo
    echo "File Permissions:"
    echo "  r (read)    - The file can be read"
    echo "  w (write)   - The file can be modified"
    echo "  x (execute) - The file can be executed as a program"
    echo
    echo "Examples:"
    echo "  chmod 755 myfile.txt  # Owner has read, write, and execute permission; group and others have read and execute permission"
    echo "  chmod u+x,g-w,o=r myfile.sh  # Add execute permission for user, remove write permission for group, and set read permission for others"
    echo "  chmod -R a+rX directory  # Recursively add read and execute permission for all"
}
alias chmodinfo="chmod_info"

# extract function
# Extract compressed files using a single command based on their file extensions.
#
# Usage:
#   extract <filename>
#
# Description:
#   The 'extract' function simplifies the extraction process for various compressed file formats.
#   It detects the file type based on its extension and executes the corresponding extraction command.
#   Supported formats include tar.bz2, tar.gz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, and 7z.
#
# Options:
#   <filename>: The name of the compressed file to be extracted.
function extract() {
    if [ $# -ne 1 ]; then
        echo "Usage: extract <filename>"
        return 1
    fi
    if [ -f "$1" ]; then
        case "$1" in
        *.tar.bz2) wsd_exe_cmd tar xvjf "$1" ;;
        *.tar.gz) wsd_exe_cmd tar xvzf "$1" ;;
        *.bz2) wsd_exe_cmd bunzip2 "$1" ;;
        *.rar) wsd_exe_cmd unrar x "$1" ;;
        *.gz) wsd_exe_cmd gunzip "$1" ;;
        *.tar) wsd_exe_cmd tar xvf "$1" ;;
        *.tbz2) wsd_exe_cmd tar xvjf "$1" ;;
        *.tgz) wsd_exe_cmd tar xvzf "$1" ;;
        *.zip) wsd_exe_cmd unzip "$1" ;;
        *.Z) wsd_exe_cmd uncompress "$1" ;;
        *.7z) wsd_exe_cmd 7z x "$1" ;;
        *) echo "❌ '$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "❌ '$1' is not a valid file"
    fi
}
