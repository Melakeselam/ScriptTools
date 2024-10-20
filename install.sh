#!/bin/bash

# Function to display usage help
usage() {
    echo "Usage: $0 <script_name>"
    echo "Or run without parameters to show a menu of available scripts."
}

# Function to list all shell scripts in the current directory, excluding "installer.sh"
list_scripts() {
    echo "Available scripts:"
    local count=1
    script_list=()
    # Read all *.sh files in the current directory, excluding "installer.sh"
    for script in *.sh; do
        if [[ $script != "install.sh" ]]; then
            echo "$count) $script"
            script_list+=("$script")
            count=$((count + 1))
        fi
    done
    echo "0) Install all scripts"
    echo ""
}

# Function to install the script
install_script() {
    local SCRIPT_NAME=$1
    local SCRIPT_DIR="$(pwd)"           # Current directory (assumed to be ScriptTools repo)
    local TARGET_DIR="$HOME"            # Target directory to copy the script to
    local SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"  # Path to the script

    # Check if the script file exists in the current directory
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Error: Script $SCRIPT_NAME not found in the repository."
        exit 1
    fi

    # Copy the script to the home directory
    echo "Copying $SCRIPT_NAME to $HOME..."
    cp "$SCRIPT_PATH" "$TARGET_DIR/"

    # Request the shell's source file
    echo "What is your shell's source file? Options: ~/.bashrc, ~/.bash_profile, ~/.zshrc, or other."
    read -p "Enter the full path to your shell's source file: " SOURCE_FILE

    # Validate the source file exists
    if [ ! -f "$SOURCE_FILE" ]; then
        echo "Error: The file $SOURCE_FILE does not exist."
        exit 1
    fi

    # Request alias name
    read -p "Enter a short alias for the script $SCRIPT_NAME: " ALIAS_NAME

    # Add alias to the shell's source file
    echo "Adding alias '$ALIAS_NAME' to $SOURCE_FILE..."
    echo "alias $ALIAS_NAME='bash $HOME/$SCRIPT_NAME'" >> "$SOURCE_FILE"

    # Refresh the source file
    echo "Refreshing the shell by sourcing $SOURCE_FILE..."
    source "$SOURCE_FILE"

    # Confirmation message
    echo "Installation complete! You can now run the script using the alias: $ALIAS_NAME"
}

# Check if no arguments are passed, show the menu
if [ -z "$1" ]; then
    # List available scripts
    list_scripts
    read -p "Enter the number of the script you want to install (or 0 to install all): " script_choice

    if [ "$script_choice" -eq 0 ]; then
        echo "Installing all scripts..."
        for script in "${script_list[@]}"; do
            install_script "$script"
        done
    else
        script_index=$((script_choice - 1))
        if [ "$script_index" -ge 0 ] && [ "$script_index" -lt "${#script_list[@]}" ]; then
            selected_script="${script_list[$script_index]}"
            echo "You selected: $selected_script"
            install_script "$selected_script"
        else
            echo "Invalid choice. Exiting."
            exit 1
        fi
    fi
else
    # Install script passed as parameter
    install_script "$1"
fi
