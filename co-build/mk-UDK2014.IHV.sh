#!/bin/bash -x

# build.sh
# /home/rcpao/Documents/github.com-rcpao/BlkCat/co-build/build.sh



build_bld_num() {
  BLD_NUM_FN=$PROJECT_DIR/bldnum.txt
  [ ! -f $BLD_NUM_FN ] && echo "0" > $BLD_NUM_FN
  OLD_BLD_NUM=`cat $BLD_NUM_FN`
  BLD_NUM=`expr $OLD_BLD_NUM + 1`
  sed -i "s/$OLD_BLD_NUM/$BLD_NUM/" $BLD_NUM_FN
  echo "#define BLD_NUM $BLD_NUM" > $PROJECT_DIR/bldnum.h
} #build_bld_num


build_gccversion() {
  # Create the GCC version specific TOOL_CHAIN_TAG = GCC44 to GCC49 as
  # defined in $EDKDIR/Conf/tools_def.txt.
  # TOOL_CHAIN_TAG = GCC46
  # GCCVERSIONab=`gcc --version | grep ^gcc | sed 's/^.* //g' | cut -c 1-3 -`
  GCCVERSIONab=`gcc -dumpversion` # | grep ^gcc | sed 's/^.* //g' | cut -c 1-3 -`
  GCCVERSIONa=`echo $GCCVERSIONab | cut -c 1 -`
  GCCVERSIONb=`echo $GCCVERSIONab | cut -c 3 -`
  GCCVERSION2=${GCCVERSIONa}${GCCVERSIONb}
  if [[ "$GCCVERSIONa" == "5" ]]; then
    BLD_TOOL_CHAIN_TAG=GCC${GCCVERSIONa}
  else
    BLD_TOOL_CHAIN_TAG=GCC${GCCVERSION2}
  fi
  #echo GCCVERSIONab=$GCCVERSIONab
  #echo GCCVERSIONa=$GCCVERSIONa
  #echo GCCVERSIONb=$GCCVERSIONb
  #echo GCCVERSION2=$GCCVERSION2
  #echo BLD_TOOL_CHAIN_TAG=$BLD_TOOL_CHAIN_TAG
} #build_gccversion


pushd ..
  PROJECT_DIR=`pwd`
  PROJECT_NAME=`basename $PROJECT_DIR`
popd #..


UDK2014_IHV_zip=~/Downloads/UDK2014.IHV.zip
UDK2014_IHV_DIR=UDK2014.IHV
[ ! -f $UDK2014_IHV_zip ] && wget https://github.com/tianocore-docs/Docs/raw/master/Driver_Developer/UDK2014.IHV.zip && mv UDK2014.IHV.zip $UDK2014_IHV_zip
[ ! -d $UDK2014_IHV_DIR ] && unzip $UDK2014_IHV_zip

pushd $UDK2014_IHV_DIR 
  EDKSETUP_SH=./edksetup.sh 
  BASETOOLS_MAKE_TXT=make.txt
  [ ! -f $EDKSETUP_SH ] && tar xvf 'BaseTools(Unix).tar'
  pushd BaseTools
    if [ ! -f $BASETOOLS_MAKE_TXT ]; then
      make > $BASETOOLS_MAKE_TXT 2>&1
    fi
  popd #BaseTools
  [ -x $EDKSETUP_SH ] && source $EDKSETUP_SH

  if [ ! -L $PROJECT_NAME ]; then
    ln -s $PROJECT_DIR $PROJECT_NAME
  fi


  build_bld_num
  build_gccversion
  build -v -t ${BLD_TOOL_CHAIN_TAG} -a X64 -p $PROJECT_NAME/$PROJECT_NAME.dsc

  ls -l Build/BlkCatPkg/DEBUG_GCC48/X64/
  cp Build/BlkCatPkg/DEBUG_GCC48/X64/BlkCat.efi .
  [ -d ~/Documents/job/enmotus.com/en_uefi/ovmf-run/hda-contents/ ] && cp Build/BlkCatPkg/DEBUG_GCC48/X64/BlkCat.efi ~/Documents/job/enmotus.com/en_uefi/ovmf-run/hda-contents/
  [ -d ~/Documents/ovmf-run/hda-contents/ ] && cp Build/BlkCatPkg/DEBUG_GCC48/X64/BlkCat.efi ~/Documents/ovmf-run/hda-contents/

popd #$UDK2014_IHV_DIR 
