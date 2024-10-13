#!/bin/bash

# Logo animation
display_key_animation() {
GREEN='\033[0;32m'   # Green color
  NC='\033[0m'         # No color (reset)

  echo -e "${GREEN}"
  cat << "EOF"
                               ..:::..           
                            .+-.   :+@%=.        
                           +. =@+...+..%@=       
                         .* :@#.      --.%#.     
                         -. %@.         +.*%.    
                        .+ -@=           +.+@.   
                        .+ #@-            =.#@.  
                        .+ #@=            = .@@. 
                        .* -@%.           +. :@- 
                        .*  #@#.           --.#%.
      .-%%%%%-        :*=-- .*@@#           ::.@:
  .:#%:.-=+=-..#: .:*#*-=++   -@%            *.%-
 .%%:.#@@@@@@@@-**: -.==--%#. +@%            +.%:
.#@:.@@@@@@@@@*.    .%.-#.##+..%@+.         .-:# 
:@@.#@@@@@@@:       .-#*+++  =: =@@*:     :*=.%. 
-@@.#@@@@@@+:    .#%:%-.      .+. .+@@@@@@=..%.  
.%@:-@@@@@@%+@@#++#.            .--.      .=:    
 .@@-=@@@@@@@%@@@:-                ..-==-..      
  .%@#.#@@@@@@@:.-                               
    -%@*.%@@@%.-                                 
     -@#.@@@@@:*.                                
     *@+:@@@@@#.:                                
    .@@.#@@@@@%.+.                               
    *@*.@@@@@@@:.-                               
    %@--@@@@@@@#.=                               
   -@%.#@@@@@@@@::-                              
  .%@=.##**+=-:..+=                              
  .+#@@@#=-:=*@#-.                               
       .:-*%=.                                   
EOF
  echo -e "${NC}"

  # Display script creators and copyright info
  echo -e "${GREEN}Created by: Melakeselam Moges and ChatGPT${NC}"
  echo -e "${GREEN}Date: $(date '+%Y-%m-%d')${NC}"
  echo -e "${GREEN}Free to use and distribute under free copyright permission${NC}"
  echo ""
}

# Function to validate successful setup of ssh key
validate() {
  ssh_host=$1
  echo ""
  echo "Validating SSH connection for $ssh_host..."
  echo ""
  
  # Attempt to SSH to the host
  ssh -T "$ssh_host" >/dev/null 2>&1
  
  # Check the exit status of the SSH command
  if [ $? -eq 1 ]; then
    echo "Validation successful: SSH connection to $ssh_host is working."
  else
    echo "Validation failed: Unable to establish an SSH connection to $ssh_host."
  fi
}

# Function to generate SSH key and update ~/.ssh/config
generate_ssh_key() {
  ssh_host=$1
  user_name=$2
  user_email=$3
  
  # Remove 'git@' if it exists in the ssh_host
  clean_ssh_host=$(echo "$ssh_host" | sed 's/git@//g' | sed 's/\./dot/g')
  
  # Extract the actual hostname (everything before the first dash)
  actual_host=$(echo "$ssh_host" | cut -d'-' -f1)

  ssh_key_path="$HOME/.ssh/id_rsa_$clean_ssh_host"

  # Ask for the SSH key type to generate with descriptions
  echo ""
  echo "Select the type of SSH key to generate:"
  echo "1) RSA (default) - Strong security and most compatible"
  echo "2) Ed25519 - Newer, faster, and more secure"
  echo "3) ECDSA - Smaller key size, based on elliptic curve cryptography"
  read -p "Enter the number of your choice: " key_choice

  case $key_choice in
    2)
      key_type="ed25519"
      ;;
    3)
      key_type="ecdsa"
      ;;
    *)
      key_type="rsa"
      ;;
  esac

  if [ -f "$ssh_key_path" ]; then
    echo "SSH key already exists at $ssh_key_path"
  else
    echo "Generating a new $key_type SSH key for $ssh_host..."
    
    # Generate the SSH key based on the selected type
    if [ "$key_type" = "rsa" ]; then
      ssh-keygen -t rsa -b 4096 -C "$user_email" -f "$ssh_key_path" -N ""
    else
      ssh-keygen -t "$key_type" -C "$user_email" -f "$ssh_key_path" -N ""
    fi

    # Add the key to the SSH agent
    eval "$(ssh-agent -s)"
    ssh-add "$ssh_key_path"

    # Show the public key and prompt to add it
    echo ""
    echo "Your public SSH key is shown below. Copy it and add it to the relevant service:"
    cat "$ssh_key_path.pub"
    echo ""
    read -p "Press Enter to continue once you've added your key..."
  fi

  # Append the new SSH host configuration to ~/.ssh/config
  echo "Adding SSH Host configuration for $ssh_host to ~/.ssh/config"
  echo "
# $user_name - $user_email : $actual_host account
Host $ssh_host
  HostName $actual_host
  User git
  IdentityFile $ssh_key_path
  IdentitiesOnly yes
" >> ~/.ssh/config
}

# Call the key animation before starting the generation
  display_key_animation
  
# Step 1: Confirm you are in the project directory
read -p "Make sure you are in the project repository folder before continuing. Are you in the correct folder? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Please navigate to the project folder and re-run the script."
  exit 1
fi

# Menu for selecting the service to configure SSH
echo "Select the service for which you'd like to configure SSH:"
echo "1) GitHub"
echo "2) GitLab"
echo "3) Bitbucket"
echo "4) AWS EC2"
echo "5) Azure VM"
echo "6) Google Cloud Compute Engine"
echo "7) DigitalOcean Droplets"
echo "8) Just SSH (No Git Config)"
echo "9) Exit"

read -p "Enter the number of your choice: " choice

case $choice in
  1)
    echo "You selected GitHub."
    # Step 1: Collect inputs
    echo ""
    read -p "Enter the SSH Host name to assign (e.g., github.com-personal): " ssh_host
    read -p "Enter the GitHub username: " github_user
    read -p "Enter the email associated with this GitHub account: " github_email

    # Step 2: Generate the SSH key and configure
    generate_ssh_key "$ssh_host" "$github_user" "$github_email"

    # Step 3: Set Git config locally
    git config --local user.name "$github_user"
    git config --local user.email "$github_email"
    echo "Git username and email set for this repository."

    # Step 4: Update the remote URL to use SSH
    remote_url=$(git remote get-url origin)
    if [[ "$remote_url" == https://github.com/* ]]; then
      repo_path=$(echo "$remote_url" | sed 's/https:\/\/github.com\///')
      git remote set-url origin "git@$ssh_host:$repo_path"
      echo "Updated remote URL to use SSH host: git@$ssh_host:$repo_path"
    else
      echo "Remote URL is already using SSH. No changes needed."
    fi
    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "GitHub SSH setup complete!"
    ;;

  2)
    echo "You selected GitLab."
    # Step 1: Collect inputs
    read -p "Enter the SSH Host name to assign (e.g., gitlab.com-personal): " ssh_host
    read -p "Enter the GitLab username: " gitlab_user
    read -p "Enter the email associated with this GitLab account: " gitlab_email

    # Step 2: Generate the SSH key and configure
    generate_ssh_key "$ssh_host" "$gitlab_user" "$gitlab_email"

    # Step 3: Set Git config locally
    git config --local user.name "$gitlab_user"
    git config --local user.email "$gitlab_email"
    echo "Git username and email set for this repository."

    # Step 4: Update the remote URL to use SSH
    remote_url=$(git remote get-url origin)
    if [[ "$remote_url" == https://gitlab.com/* ]]; then
      repo_path=$(echo "$remote_url" | sed 's/https:\/\/gitlab.com\///')
      git remote set-url origin "git@$ssh_host:$repo_path"
      echo "Updated remote URL to use SSH host: git@$ssh_host:$repo_path"
    else
      echo "Remote URL is already using SSH. No changes needed."
    fi
    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "GitLab SSH setup complete!"
    ;;

  3)
    echo "You selected Bitbucket."
    # Step 1: Collect inputs
    read -p "Enter the SSH Host name to assign (e.g., bitbucket.org-personal): " ssh_host
    read -p "Enter the Bitbucket username: " bitbucket_user
    read -p "Enter the email associated with this Bitbucket account: " bitbucket_email

    # Step 2: Generate the SSH key and configure
    generate_ssh_key "$ssh_host" "$bitbucket_user" "$bitbucket_email"

    # Step 3: Set Git config locally
    git config --local user.name "$bitbucket_user"
    git config --local user.email "$bitbucket_email"
    echo "Git username and email set for this repository."

    # Step 4: Update the remote URL to use SSH
    remote_url=$(git remote get-url origin)
    if [[ "$remote_url" == https://bitbucket.org/* ]]; then
      repo_path=$(echo "$remote_url" | sed 's/https:\/\/bitbucket.org\///')
      git remote set-url origin "git@$ssh_host:$repo_path"
      echo "Updated remote URL to use SSH host: git@$ssh_host:$repo_path"
    else
      echo "Remote URL is already using SSH. No changes needed."
    fi
    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "Bitbucket SSH setup complete!"
    ;;

  4)
    echo "You selected AWS EC2."
    # Step 1: Collect inputs for EC2
    read -p "Enter the EC2 public DNS (e.g., ec2-xx-xxx-xxx-xx.compute.amazonaws.com): " ec2_host
    read -p "Enter the path to your EC2 private key file (.pem): " pem_file

    # Step 2: Append EC2 host to SSH config
    echo "Adding EC2 configuration to ~/.ssh/config"
    echo "
# AWS EC2 instance
Host $ec2_host
  HostName $ec2_host
  User ec2-user
  IdentityFile $pem_file
  IdentitiesOnly yes
" >> ~/.ssh/config

    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "EC2 SSH setup complete! You can now SSH into your EC2 instance with:"
    echo "ssh $ec2_host"
    ;;

  5)
    echo "You selected Azure VM."
    # Step 1: Collect inputs for Azure VM
    read -p "Enter the Azure VM DNS or IP address: " azure_host
    read -p "Enter the username for the Azure VM: " azure_user
    read -p "Enter the path to your Azure private key file (.pem): " pem_file

    # Step 2: Append Azure VM to SSH config
    echo "Adding Azure VM configuration to ~/.ssh/config"
    echo "
# Azure VM instance
Host $azure_host
  HostName $azure_host
  User $azure_user
  IdentityFile $pem_file
  IdentitiesOnly yes
" >> ~/.ssh/config

    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "Azure VM SSH setup complete! You can now SSH into your VM with:"
    echo "ssh $azure_host"
    ;;

  6)
    echo "You selected Google Cloud Compute Engine."
    # Step 1: Collect inputs for Google Cloud
    read -p "Enter the Google Cloud Compute Engine public IP or DNS: " gcloud_host
    read -p "Enter the path to your Google Cloud private key file (.pem): " pem_file

    # Step 2: Append Google Cloud to SSH config
    echo "Adding Google Cloud configuration to ~/.ssh/config"
    echo "
# Google Cloud Compute Engine
Host $gcloud_host
  HostName $gcloud_host
  User google_user
  IdentityFile $pem_file
  IdentitiesOnly yes
" >> ~/.ssh/config

    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "Google Cloud SSH setup complete! You can now SSH into your Compute Engine instance with:"
    echo "ssh $gcloud_host"
    ;;

  7)
    echo "You selected DigitalOcean Droplets."
    # Step 1: Collect inputs for DigitalOcean Droplet
    read -p "Enter the Droplet public IP or DNS: " droplet_host
    read -p "Enter the username for the Droplet: " droplet_user
    read -p "Enter the path to your private key file (.pem): " pem_file

    # Step 2: Append Droplet to SSH config
    echo "Adding DigitalOcean Droplet configuration to ~/.ssh/config"
    echo "
# DigitalOcean Droplet
Host $droplet_host
  HostName $droplet_host
  User $droplet_user
  IdentityFile $pem_file
  IdentitiesOnly yes
" >> ~/.ssh/config

    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "DigitalOcean SSH setup complete! You can now SSH into your Droplet with:"
    echo "ssh $droplet_host"
    ;;

  8)
    echo "You selected Just SSH."
    # Step 1: Collect inputs for Just SSH (no Git setup)
    read -p "Enter the SSH Host name to assign (e.g., myserver.com): " ssh_host
    read -p "Enter the username for this SSH connection: " ssh_user
    read -p "Enter your email (optional, for key comment): " ssh_email

    # Step 2: Generate the SSH key and configure (without Git setup)
    generate_ssh_key "$ssh_host" "$ssh_user" "$ssh_email"

    # Call validate to check the SSH connection
    validate "$ssh_host"
    echo "SSH setup complete for $ssh_host!"
    echo "You can now SSH into $ssh_host with the following command:"
    echo "ssh $ssh_host"
    ;;

  9)
    echo "Exiting the script."
    exit 0
    ;;

  *)
    echo "Invalid option. Please select a valid number."
    ;;
esac
