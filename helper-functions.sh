#!/bin/bash

function assertFilePresent()
{
   if [ $# != 1 ]; then echo "assertFilePresent: expected 1 arguments, received $#!"; exit 1; fi
   file=$1
   if [ ! -f $file ]; then echo "Unable to find $file!"; exit 1; fi
}

function assertDirectoryPresent()
{
   if [ $# != 1 ]; then echo "assertFilePresent: expected 1 arguments, received $#!"; exit 1; fi
   directory=$1
   if [ ! -d $directory ]; then echo "Unable to find $directory!"; exit 1; fi
}


function verifySymlink()
{
   if [ $# != 2 ]; then echo "verifySymlink: expected 2 arguments, received $#!"; exit 1; fi
   linkedFile=$1
   linkName=$2
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

function updateOrInstall()
{
   if [ $# -lt 3 ]; then echo "updateOrInstall: expected 3 arguments, received $#!"; exit 1; fi
   if [ -z "$VIM_ROOT" ]; then echo "updateOrInstall: expected VIM_ROOT to be specified!"; exit 1; fi
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

