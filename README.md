# Set up a new machine
```
# Generate your ssh key
ssh-keygen -t rsa
# Copy the key to Github
cat .ssh/id_rsa.pub

# Clone the dotfiles
git init
git remote add origin git@github.com:dheater/dotfiles.git
git fetch origin

# Remove the local copy
rm .bashrc

# Switch to the git versions.
git checkout master
source .bashrc

# Setup Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
```
