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
# Check installation of required tools
################################################################################
hash wget 2>/dev/null  || {sudo aptitude install wget}
hash curl 2>/dev/null  || {sudo aptitude install curl}
hash unzip 2>/dev/null || {sudo aptitude install unzip}
hash cmake 2>/dev/null || {sudo aptitude install cmake}

#https://github.com/seebi/dircolors-solarized
#gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3"

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
updateOrInstall $update vim-unite              https://github.com/Shougo/unite.vim.git

updateOrInstall $update vim-airline            https://github.com/bling/vim-airline.git
updateOrInstall $update vim-nerdcommenter      https://github.com/scrooloose/nerdcommenter.git
updateOrInstall $update vim-surround           https://github.com/tpope/vim-surround.git
updateOrInstall $update vim-fugitive           https://github.com/tpope/vim-fugitive.git
updateOrInstall $update vim-visual-star-search https://github.com/bronson/vim-visual-star-search.git
updateOrInstall $update vim-youcompleteme      https://github.com/Valloric/YouCompleteMe.git
updateOrInstall $update vim-tagbar             https://github.com/majutsushi/tagbar.git
updateOrInstall $update vim-easymotion         https://github.com/Lokaltog/vim-easymotion.git
updateOrInstall $update vim-json               https://github.com/elzr/vim-json.git
updateOrInstall $update vim-colors-solarized   https://github.com/altercation/vim-colors-solarized.git
#updateOrInstall $update vim-taglist            https://github.com/vim-scripts/taglist.vim.git
#updateOrInstall $update vim-taglist            http://sourceforge.net/projects/vim-taglist/files/latest/download?source=files 
#yankring uses <C-p> which collides with vim-ctrlp: needs to be fixed before we add yankring
#updateOrInstall $update vim-yankring           https://github.com/vim-scripts/YankRing.vim.git

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
if [ ! -f $youcompleteme_root/third_party/ycmd/build.py ]; then
   echo "Installing youcompleteme"
   pushd $youcompleteme_root>/dev/null
   trap "{popd>/dev/null; exit 255; }" SIGINT

   export PATH="/usr/local/bin:$PATH"
   installed_cmake=$(cmake --version |sed -r 's/^[^0-9]*(.*)[^0-9]*$/\1/')
   required_cmake=$(grep -IR cmake_minimum_required |sed -r 's/.*VERSION (.*)\).*/\1/g' |tr -d ' ' |sort --version-sort |tail -n 1)
   if version_gt $required_cmake $installed_cmake; then
      echo "Required version of cmake $required_cmake is greater then installed version $installed_cmake"
      echo "Installing latest cmake version..."
      install_latest_cmake
   fi

   git submodule update --init --recursive
   ./install.sh --clang-completer --system-libclang

   popd >/dev/null
   trap - SIGINT
fi

echo "Thank you, come again!"
