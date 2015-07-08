#!/bin/bash

function print_title()
{
   if [ $# != 1 ]; then echo "print_title: expected 1 arguments, received $#!"; exit 1; fi
   echo "################################################################################"
   echo "$1"
   echo "################################################################################"
}

function assertFilePresent()
{
   if [ $# != 1 ]; then echo "assertFilePresent: expected 1 arguments, received $#!"; exit 1; fi
   local file=$1
   if [ ! -f $file ]; then echo "Unable to find $file!"; exit 1; fi
}

function assertDirectoryPresent()
{
   if [ $# != 1 ]; then echo "assertFilePresent: expected 1 arguments, received $#!"; exit 1; fi
   directory=$1
   if [ ! -d $directory ]; then echo "Unable to find $directory!"; exit 1; fi
}

function createDirectoryIfNecessary()
{
   if [ $# != 1 ]; then echo "createDirectoryIfNecessary: expected 1 arguments, received $#!"; exit 1; fi
   directory=$1
   if [ ! -d $directory ]; then mkdir $directory; fi
}

function verifySymlink()
{
   if [ $# != 2 ]; then echo "verifySymlink: expected 2 arguments, received $#!"; exit 1; fi
   local linkedFile=$1
   local linkName=$2
   if [ ! -e $linkedFile ]; then echo "WARNING: verifySymlink: specified target doesn't exist ($linkedFile)!" >&2; fi
   if [ ! -h  $linkName -o ! "$(readlink $linkName)" = "$linkedFile" ]; then
      rm -f $linkName
      ln -s $linkedFile $linkName
   fi
}

function downloadAndInstallZip()
{
   if [ $# != 2 ]; then echo "downloadAndInstallZip: expected 2 arguments, received $#!"; exit 1; fi
   if [ -z "$VIM_ROOT" ]; then echo "downloadAndInstallZip: expected VIM_ROOT to be specified!"; exit 1; fi
   local pluginName=$1
   local pluginUrl=$2
   if [ ! -d $VIM_ROOT/bundle ]; then mkdir $VIM_ROOT/bundle; fi
   if [ ! -d $VIM_ROOT/bundle/$pluginName ]; then
      echo "Installing $pluginName"
      pushd $VIM_ROOT/bundle > /dev/null
      wget $pluginUrl -O $pluginName.zip
      unzip $pluginName.zip
      popd > /dev/null
   fi
}

# To install the vimball:
#    $ vim ~/.vim/AnsiEsc.vba
#    :!mkdir ~/.vim/bundle/vim-ansi-esc
#    :UseVimball ~/.vim/bundle/vim-ansi-esc
# To use it:
#    :AnsiEsc
function downloadAnsiEsc()
{
   if [ ! -f $VIM_ROOT/AnsiEsc.vba ]; then
      echo "Downloading AnsiEsc.vba"
      pushd $VIM_ROOT > /dev/null
      wget --content-disposition http://www.vim.org/scripts/download_script.php?src_id=14498
      if [ ! -f AnsiEsc.vba.gz ]; then echo "[ERROR] didn't find expected file AnsiEsc.vba.gz"; return 1; fi
      gunzip AnsiEsc.vba.gz
      popd > /dev/null
   fi
}

function updateOrInstall()
{
   if [ $# -lt 3 ]; then echo "updateOrInstall: expected 3 arguments, received $#!"; exit 1; fi
   if [ -z "$VIM_ROOT" ]; then echo "updateOrInstall: expected VIM_ROOT to be specified!"; exit 1; fi
   if [ ! -d "$VIM_ROOT" ]; then echo "updateOrInstall: $VIM_ROOT is not a directory!"; exit 1; fi
   local update=$1
   local pluginName=$2
   local pluginUrl=$3
   if [ ! -d $VIM_ROOT/bundle ]; then mkdir $VIM_ROOT/bundle; fi
   if [ ! -d $VIM_ROOT/bundle/$pluginName ]; then
      echo "Installing $pluginName"
      pushd $VIM_ROOT/bundle > /dev/null
      if [[ $pluginUrl =~ .*\.git ]]; then
          git clone $pluginUrl $pluginName
      elif [[ $pluginUrl =~ .*bitbucket.* ]]; then
          hg clone $pluginUrl $pluginName
      else
         echo "helper-functions::updateOrInstall: we don't support installing this type of plugin yet!"
         #curl --location --progress-bar --compressed $pluginUrl
      fi
      popd > /dev/null
   elif [ $update = 1 ]; then
      echo "Updating $pluginName"
      local result="";
      local result_code=0;
      pushd $VIM_ROOT/bundle/$pluginName > /dev/null
      if [[ $pluginUrl =~ .*\.git ]]; then
         result="$(git pull)"
         result_code=$?;
      elif [[ $pluginUrl =~ .*bitbucket.* ]]; then
         result="$(hg pull)"
         result_code=$?;
      else
         echo "WARNING: helper-function::updateOrInstall: we don't support updating this type of plugin yet!"
      fi
      if [ $result_code != 0 ]; then
         echo "  WARNING: Somthing went wrong while trying to update: $result";
         echo "  Continuing..." 
      fi
      popd > /dev/null
   fi
}

function version_gt() {
   latest_version="$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)"
   test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; 
}

function install_latest_cmake()
{
   local cmake_to_install=cmake-3.2.2
   local temp_dir=`mktemp -d`

   print_title "Installing $cmake_to_install"

   # (cmake requires python-dev)
   sudo aptitude install python-dev

   pushd $temp_dir >/dev/null
   trap 'popd >/dev/null' SIGINT

   wget http://www.cmake.org/files/v3.2/${cmake_to_install}.tar.gz
   tar xzf ${cmake_to_install}.tar.gz
   cd $cmake_to_install 
   ./bootstrap
   make
   sudo make install

   popd >/dev/null
   trap - SIGINT
}

