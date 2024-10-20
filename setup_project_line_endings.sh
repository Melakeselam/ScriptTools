#!/bin/bash

echo "Project Line Ending Setup Script"
echo "================================"

# Check if in project folder
read -p "Are you in the project folder? (y/n): " in_project_folder
if [[ $in_project_folder != "y" ]]; then
    echo "Please navigate to your project folder and run this script again."
    exit 1
fi

# Check if new or existing project
read -p "Is this a new project or an existing project? (new/existing): " project_type

# Ask for IDE
read -p "What IDE are you using? (vscode/intellij/eclipse): " ide

# Confirm Linux compatible endings
read -p "Do you want your files to have Linux compatible endings? (y/n): " linux_endings
if [[ $linux_endings != "y" ]]; then
    echo "Script terminated. No changes made."
    exit 0
fi

# Set up Git configuration
git config core.autocrlf input

# Create .gitattributes file
cat > .gitattributes << EOL
# Set the default behavior, in case people don't have core.autocrlf set.
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout.
*.java text
*.gradle text
*.xml text
*.properties text
*.yml text
*.md text
gradlew text eol=lf
*.sh text eol=lf

# Declare files that will always have CRLF line endings on checkout.
*.bat text eol=crlf

# Denote all files that are truly binary and should not be modified.
*.jar binary
*.png binary
*.jpg binary
EOL

echo "Created .gitattributes file with appropriate settings."

# Set up IDE-specific configurations
case $ide in
    vscode)
        mkdir -p .vscode
        echo '{"files.eol": "\n"}' > .vscode/settings.json
        echo "Configured VS Code for LF line endings."
        ;;
    intellij)
        echo "For IntelliJ IDEA, please manually set line endings:"
        echo "1. Go to File > Settings (on Windows/Linux) or IntelliJ IDEA > Preferences (on macOS)"
        echo "2. Navigate to Editor > Code Style"
        echo "3. Set 'Line separator' to 'Unix and macOS (\n)'"
        ;;
    eclipse)
        echo "For Eclipse, please manually set line endings:"
        echo "1. Go to Window > Preferences"
        echo "2. Navigate to General > Workspace"
        echo "3. Under 'New text file line delimiter', select 'Unix'"
        ;;
    *)
        echo "No IDE-specific configuration set."
        ;;
esac

# Renormalize existing files if it's an existing project
if [[ $project_type == "existing" ]]; then
    echo "Renormalizing all files in the project..."
    git add --renormalize .
    echo "Files renormalized. Please commit these changes."
fi

echo "Setup complete. Your project is now configured for Linux-compatible line endings."
