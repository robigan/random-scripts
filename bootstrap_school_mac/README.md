# Mac Bootstrap Script

This script automates some common setup steps and configurations for a new Mac. 

It will:

- Check for and add some useful shell aliases
- Install Xcode command line tools if needed  
- Install Homebrew
- Perform initial Homebrew configuration

## Usage

To run the latest version of the script easily in one step, use:

```
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/robigan/random-scripts/main/bootstrap_school_mac/bootstrap.sh)"
```

This will download the script directly from GitHub and execute it. 

Or clone the full repo to get the bootstrap.sh script, make any desired edits, then run it:

```
git clone https://github.com/robigan/random-scripts.git
cd random-scripts/bootstrap_school_mac
zsh bootstrap.sh
```

Feel free to open issues or PRs if you have any problems or suggested improvements!
