#!/usr/bin/env zsh

# Load existing aliases
source ~/.zshrc

# Check if aliases already exist
if ! alias | grep -q mkadmin; then
  echo 'alias mkadmin="sudo dscl . -append /Groups/admin GroupMembership $USERNAME"' >> ~/.zshrc
else
  echo 'mkadmin alias already exists'
fi

if ! alias | grep -q rmadmin; then
  echo 'alias rmadmin="sudo dscl . -delete /Groups/admin GroupMembership $USERNAME && sudo dseditgroup -o edit -d $USERNAME -t user admin"' >> ~/.zshrc
else
  echo 'rmadmin alias already exists'
fi

if ! alias | grep -q rmblock; then
  echo 'alias rmblock="sudo rm /Library/Managed\ Preferences/$USERNAME/com.apple.familycontrols.contentfilter.plist; sudo rm /Library/Managed\ Preferences/$USERNAME/com.apple.familycontrols.timelimits.plist; sudo rm /Library/Managed\ Preferences/$USERNAME/com.apple.ironwood.support.plist; sudo rm /Library/Managed\ Preferences/$USERNAME/com.google.chrome.plist"' >> ~/.zshrc
else
  echo 'rmblock alias already exists'
fi

# Homebrew install
echo -n "Do you want to install Xcode Command Line Utilities? (y/n) "
read install_brew

if [[ $install_brew =~ ^[Yy]$ ]]; then
  # Prevent sleep
  caffeinate -i &

  trap 'echo "Caught INT signal, cleaning up..."; kill $!' INT

  {
    # Install Xcode tools
    if xcode-select --install; then
      echo "Xcode command line tools installed successfully"
    else
      echo "Failed to install Xcode command line tools"
    fi

    echo -n "Also install Homebrew? (y/n)"
    read install_brew

    if [[ $install_brew =~ ^[Yy]$ ]]; then
      # Install Homebrew
      {
        git clone --depth=5 https://github.com/Homebrew/brew ~/homebrew
        echo "Homebrew cloned"

        # Additional Homebrew setup
        eval "$(~/homebrew/bin/brew shellenv)"
        brew update --force --quiet
        chmod -R go-w "$(brew --prefix)/share/zsh"

        mkdir -p $HOME/Applications
        echo "$HOME/Applications created"
        echo "eval \"\$(${HOMEBREW_PREFIX}/bin/brew shellenv)\"" >> ~/.zshrc
        echo 'export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"' >> ~/.zshrc

        echo "Homebrew setup complete"
      } || {
        echo "Failed to install Homebrew"
      }
    fi
  } || {
    echo "Installation exited with non zero status code"
  }

  # Allow sleep
  kill $!
else
  echo "Skipping Xcode/Homebrew installation"
fi
