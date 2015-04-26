#!/bin/bash

################################################################################
# Parse parameters
################################################################################
function show_help {
    echo "Install the vim plugins and create required symbolic links.";
    echo "  -h Show this help function";
    echo "  -u Update existing plugins";
}
OPTIND=1         # Reset in case getopts has been used previously in the shell.
verbose=0
update=0
while getopts "h?vu" opt; do
   case "$opt" in
      h|\?)
         show_help
         exit 0
         ;;
      v)  verbose=1 ;;
      u)  update=1 ;;
   esac
done
shift $((OPTIND-1))

################################################################################
# Determine important directories
################################################################################
DOTVIM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER=$(whoami)
HOME_DIR=/home/$USER
VIM_ROOT=$HOME_DIR/.vim

source helper-functions.sh

################################################################################
# Verify presence of expected directories and files
################################################################################
assertDirectoryPresent $HOME_DIR
assertDirectoryPresent $DOTVIM_DIR/vimrc.d
assertFilePresent $DOTVIM_DIR/vimrc
createDirectoryIfNecessary $VIM_ROOT
createDirectoryIfNecessary $VIM_ROOT/autoload

################################################################################
# Download plugins
################################################################################
updateOrInstall $update vim-pathogen           https://github.com/tpope/vim-pathogen.git

# file navigation
updateOrInstall $update vim-nerdtree           https://github.com/scrooloose/nerdtree.git
updateOrInstall $update vim-ctrlp              https://github.com/kien/ctrlp.vim.git
updateOrInstall $update vim-mru                https://github.com/yegappan/mru.git

updateOrInstall $update vim-nerdcommenter      https://github.com/scrooloose/nerdcommenter.git
updateOrInstall $update vim-surround           https://github.com/tpope/vim-surround.git
updateOrInstall $update vim-fugitive           https://github.com/tpope/vim-fugitive.git
updateOrInstall $update vim-visual-star-search https://github.com/bronson/vim-visual-star-search.git
updateOrInstall $update vim-youcompleteme      https://github.com/Valloric/YouCompleteMe.git
updateOrInstall $update vim-tagbar             https://github.com/majutsushi/tagbar.git
updateOrInstall $update vim-easymotion         https://github.com/Lokaltog/vim-easymotion.git
updateOrInstall $update vim-json               https://github.com/elzr/vim-json.git
#updateOrInstall $update vim-taglist       https://github.com/vim-scripts/taglist.vim.git
#updateOrInstall $update vim-taglist       http://sourceforge.net/projects/vim-taglist/files/latest/download?source=files 

downloadAndInstallZip vim-fswitch http://www.vim.org/scripts/download_script.php?src_id=14047 

verifySymlink $DOTVIM_DIR/vimrc          $HOME_DIR/.vimrc
verifySymlink $DOTVIM_DIR/vimrc.d/colors $VIM_ROOT/colors
verifySymlink $DOTVIM_DIR/vimrc.d/indent $VIM_ROOT/indent
verifySymlink $VIM_ROOT/bundle/vim-pathogen/autoload/pathogen.vim $VIM_ROOT/autoload/pathogen.vim

################################################################################
# Install vim-youcompleteme if possible
# For more info: https://github.com/Valloric/YouCompleteMe#ubuntu-linux-x64-super-quick-installation
################################################################################
youcompleteme_root=$VIM_ROOT/bundle/vim-youcompleteme
if [ ! -f $youcomleteme_root/third_party/ycmd/build.py ]; then
   echo "Installing youcompleteme"
   pushd $youcompleteme_root>/dev/null
   trap "{popd>/dev/null; exit 255; }" SIGINT
   git submodule update --init --recursive
   ./install.sh --clang-completer --system-libclang
fi

echo "Thank you, come again!"
