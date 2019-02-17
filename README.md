# Set up a new machine
```
# Generate your ssh key
ssh-keygen -t rsa
# Copy the key to Github
cat .ssh/id_rsa.pub

# Clone the dotfiles
git clone git@github.com:dheater/dotfiles.git

# Remove the bashrc
rm .bashrc

# Intiallize the dotfiles
cd dotfiles
./install

# Setup Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
```
