# ScriptTools

Collection of useful scripts for various tools and tasks.

##
## Installation Instructions

This repository includes several script tools for various use cases. You can install and configure any script from this repository using the `installer.sh` script. This script allows you to set up an alias for quick access to the tools.

### How to Use `installer.sh`:

1. **Clone the Repository:**

   First, clone the **ScriptTools** repository to your local machine:

   ```bash
   git clone git@github.com:YOUR_USERNAME/ScriptTools.git
   cd ScriptTools
   ```
1. **Run the Installer Script:**

    Run the installer.sh script with the name of the script tool you want to install:

    ```bash
    ./install.sh <script_name>
    ```
    Replace <script_name> with the actual name of the script file you want to install (without the .sh extension). For example:
    ```bash
    ./install.sh keygen_script
    ```
1. **Follow the Prompts:**

    - The installer will prompt you to select your shell’s source file (e.g., `~/.bashrc`, `~/.bash_profile`, or `~/.zshrc`).
    - It will also ask you for a short alias for the script (e.g., `keygen`).
    - The script will then copy the selected tool to your home directory and create an alias for easy use.
1. **Use the Alias:**

    Once the installation is complete, you can run the script using the alias you created. For example, if you chose the alias `keygen`, you can run the script like this:
    ```bash
    keygen
    ```

### Example:
To install and set up the `keygen_script.sh` tool:
```bash
./installer.sh keygen_script
```
- Choose your shell’s source file (e.g., ~/.bashrc).
- Enter a short alias (e.g., `keygen`).
- The script will be copied to your home directory and you can run it by typing `keygen` in your terminal.

##
## Contributing:
Feel free to contribute additional scripts or make improvements to the existing ones. To contribute:

Fork the repository.
Create a new branch.
Make your changes.
Submit a pull request.

##
## License:
Free to use and distribute under free copyright permission.
