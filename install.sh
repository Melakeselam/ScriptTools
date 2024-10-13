#!/bin/bash

# Function to display usage help
usage() {
    echo "Usage: $0 <script_name>"
    echo "Example: $0 keygen_script"
    exit 1
}

# Check if a script name was provided
if [ -z "$1" ]; then
    usage
fi

# Variables
SCRIPT_NAME=$1
SCRIPT_DIR="$(pwd)"          # Current directory (assumed to be ScriptTools repo)
TARGET_DIR="$HOME"           # Target directory to copy the script to
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME.sh"  # Path to the script

# Check if the script file exists in the current directory
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Script $SCRIPT_NAME.sh not found in the repository."
    exit 1
fi

# Copy the script to the home directory
echo "Copying $SCRIPT_NAME.sh to $HOME..."
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
echo "alias $ALIAS_NAME='bash $HOME/$SCRIPT_NAME.sh'" >> "$SOURCE_FILE"

# Refresh the source file
echo "Refreshing the shell by sourcing $SOURCE_FILE..."
source "$SOURCE_FILE"

# Confirmation message
echo "Installation complete! You can now run the script using the alias: $ALIAS_NAME"
