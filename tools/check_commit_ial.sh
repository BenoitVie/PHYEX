#!/bin/bash

#set -x
set -e
set -o pipefail #abort if left command on a pipe fails

#This script:
# - compiles the AROME model using a specific commit for the externalised physics
# - runs a small 3D case and checks if results are identical to a given version

#small_3D_np2: on only 2 procs
#small_3D_alt1: options around time-step dependency, CFRAC_ICE_*='T', CSEDIM='SPLI', LSEDIM_AFTER=.T.
#small_3D_alt2: CCLOUD='OLD3'
#small_3D_alt3: PRFR
#small_3D_alt4: small_3D_alt1 + CSNOWRIMING='OLD'
#small_3D_alt5: CCLOUD='ICE4'
#small_3D_alt6: CMF_UPDRAFT='RAHA', CMF_CLOUD='BIGA'
#small_3D_alt7: CMF_CLOUD='STAT', LOSIGMAS=.FALSE. #Needs 2 corrections in original cycle 48
#small_3D_alt8: CMF_UPDRAFT='RHCJ'
#small_3D_alt9: CCLOUD='OLD3', OCND2=.T.
#small_3D_alt10: LCRIAUTI=F
#small_3D_lima: LIMA scheme
#small_3D_alt11: same as small_3D but with a different value for NPROMICRO (must give exactly the same results)
#small_3D_alt12: same as small_3D but with LPACK_MICRO=.F. (must give exactly the same results)

#When running in 49t0 after the f065e64 commit (23 June 2023) all configurations must be compared to this same commit.
#79fe47e (previous commit) is identical to the different references for all the test cases.
#When running in 49t0 after the 00148b1 commit (27 June 2023) all configurations must be compared to this same commit.

#The small_3D_alt7 needed a correction in apl_arome which has been introduced in d37dd1f. But the reference pack has been modified
#                  afterwards to enable this test case to be run (documented in INSTALL_pack_ial.md). In consequence, the reference
#                  to use is the same as for the other test cases and this case cannot be run for commit before d37dd1f (20 April 2022).

#The small_3D_alt8 is not included in the list of available tests because it needs to be compared against a special commit.
#                  Indeed, on 3 February 2022 (commit 907e906) the mesonh version of compute_updraft_rhcj.F90 has been put in the common directory.
#                  The reference is
#                       the commit 907e906 when running in 48t1
#                       the commit d10ed48 when running in 48t3 (edc3f88 (last commit in 48t1) is identical to 907e906)
#                       the commit 7e55649 when running in 49t0 (9164c67 (last commit in 48t3) is identical to d10ed48)

#The small_3D_alt9 is not included in the list of available tests because it needs to be compared against a special commit.
#                  Indeed, some pieces are missing in the reference pack.
#                  Theses pieces have been added in commit edc3f88 during phasing with 48t3.
#                  The reference is
#                       the commit edc3f88 (21 September 2022) when running in 48t1
#                       the commit d10ed48 in 48t3 (29 september 2022) when running in 48t3
#                       the commit 110a5aa in 49t0 (13 June 2023) when running in 49t0 (bd44ba7 (patch on the last commint in 48t3) is identical to d10ed48)

#The small_3D_alt10 is not included in the list because it is not sufficiently different from other tests
#                  Be careful that namelists were wrong before commit 3c01df4 (8 June 2023)

#The small_3D_lima is not included in the list of available tests because it needs to be compared against a special commit.
#                  Indeed, the lima version in arome has been changed.
#                  The reference commit is
#                       the commit d095d11 (20 March 2023) when running in 48t3
#                       the commit 7e55649 when running in 49t0 (9164c67 (last commit in 48t3) is identical to d095d11)

#Special pack names:
# - recompil: original source code (everything under mpa)
# - split_48t1: original 48t1 source code but with physics source code under phyex directory
# - split_48t3: same as split_48t1 but for the 48t3 cycle
# - split: symbolic link to split_48t1 (backward compatibility)
# - split_49t0: same as split_48t1 but for the 49t0 cycle

specialPack="ori split split_48t1 split_48t3 recompil split_49t0"
availTests="small_3D,small_3D_np2,small_3D_alt1,small_3D_alt2,small_3D_alt3,small_3D_alt4,small_3D_alt5,small_3D_alt6,small_3D_alt7"
defaultTest="small_3D"
separator='_' #- be carrefull, gmkpack (at least on belenos) has multiple allergies (':', '.', '@')
              #- seprator must be in sync with prep_code.sh separator

PHYEXTOOLSDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dirpack=$PHYEXTOOLSDIR/pack
dirconf=$PHYEXTOOLSDIR/conf_tests
declare -A gmkpack_l
declare -A gmkpack_o
if [ $(hostname | cut -c 1-7) == 'belenos' -o $(hostname | cut -c 1-7) == 'taranis' ]; then
  HPC=1
  gmkpack_l[default]=MIMPIIFC1805
  gmkpack_l[49t0]=IMPIIFC2018
  gmkpack_l[49t2]=IMPIIFCI2302DP
  gmkpack_o[default]=2y
  gmkpack_o[49t0]=x
  gmkpack_o[49t2]=y
  defaultMainPackVersion=01
  defaultRef='split_${cycle}'
  availTests="${availTests},big_3D"
else
  HPC=0
  gmkpack_l[default]=MPIGFORTRAN920DBL
  gmkpack_l[49t0]=OMPIGFORT920DBL
  gmkpack_l[49t2]=OMPIGFORT920DBL
  gmkpack_o[default]=xfftw
  gmkpack_o[49t0]=x
  gmkpack_o[49t2]=x
  defaultMainPackVersion=01
  defaultRef='split_${cycle}'
fi
mainPackVersion=${mainPackVersion:-${defaultMainPackVersion}}

extraCompilationCheck=1

function usage {
  echo "Usage: $0 [-h] [-p] [-c] [-r] [-C] [-s] [-f] [--noexpand] [-t test] [--cycle CYCLE] [--repo-user] [--repo-protocol] commit [reference]"
  echo "commit          commit hash (or a directory, or among $specialPack) to test"
  echo "reference       commit hash (or a directory, or among $specialPack) REF to use as a reference"
  echo "-s              suppress compilation pack"
  echo "-p              creates pack"
  echo "-c              performs compilation"
  echo "-r              runs the tests"
  echo "-C              checks the result against the reference"
  echo "-t              comma separated list of tests to execute"
  echo "                or ALL to execute all tests"
  echo "--noexpand      do not use mnh_expand (code will be in array-syntax)"
  echo "-f              full compilation (do not use pre-compiled pack)"
  echo "--cycle CYCLE   to force using CYCLE"
  echo "--scripttag TAG script tag to use in case --cycle is provided"
  echo "--repo-user     user hosting the PHYEX repository on github,"
  echo "                defaults to the env variable PHYEXREOuser (=$PHYEXREOuser)"
  echo "--repo-protocol protocol (https or ssh) to reach the PHYEX repository on github,"
  echo "                defaults to the env variable PHYEXREOprotocol (=$PHYEXREOprotocol)"
  echo ""
  echo "If nothing is asked (pack creation, compilation, running, check) everything is done"
  echo "If no test is aked for, the default one ($defaultTest) is executed"
  echo
  echo "With the special reference REF commit, a suitable reference is guessed"
  echo "The directory (for commit only, not ref) can take the form server:directory"
  echo "If using a directory (for commit or reference) it must contain at least one '/'"
  echo "The commit can be a tag, written with syntagx tags/<TAG>"
  echo
  echo "The cycle will be guessed from the source code"
  echo
  echo "The -f flag (full recompilation) is active only at pack creation"
  echo
  echo "The PHYEXROOTPACK environment variable, if set, is used as the argument"
  echo "of the --rootpack option of ial-git2pack, for incremental packs."
}

packcreation=0
compilation=0
run=0
check=0
commit=""
reference=""
tests=""
suppress=0
useexpand=1
fullcompilation=0
cycle=""
scripttag=''

while [ -n "$1" ]; do
  case "$1" in
    '-h') usage;;
    '-s') suppress=1;;
    '-p') packcreation=1;;
    '-c') compilation=1;;
    '-r') run=$(($run+1));;
    '-C') check=1;;
    '-t') tests="$2"; shift;;
    '--noexpand') useexpand=0;;
    '-f') fullcompilation=1;;
    '--cycle') cycle="$2"; shift;;
    '--scripttag') scripttag="$2"; shift;;
    '--repo-user') export PHYEXREPOuser=$2; shift;;
    '--repo-protocol') export PHYEXREPOprotocol=$2; shift;;
    #--) shift; break ;;
     *) if [ -z "${commit-}" ]; then
          commit=$1
        else
          if [ -z "${reference-}" ]; then
            reference=$1
          else
            echo "Only two commit hash allowed on command line"
            exit 1
          fi
        fi;;
  esac
  shift
done

HOMEPACK=${HOMEPACK:=$HOME/pack}

function exescript () {
  #usage: exescript <output file> <script> [arg [arg ...]]
  output=$1
  shift
  if [ $HPC -eq 1 ]; then
    sbatch --wait -o $output $@
    cat $output
  else
    $@ 2>&1 | tee $output
  fi
}

if [ -z "${tests-}" ]; then
  tests=$defaultTest
elif [ $tests == 'ALL' ]; then
  tests=$availTests
fi

if [ $packcreation -eq 0 -a \
     $compilation -eq 0 -a \
     $run -eq 0 -a \
     $check -eq 0 ]; then
  packcreation=1
  compilation=1
  run=1
  check=1
fi

if [ -z "${commit-}" ]; then
  echo "At least one commit hash must be provided on command line"
  exit 2
fi

if [ $check -eq 1 -a -z "${reference-}" ]; then
  echo "To perform a comparison two commit hashes are mandatory on the command line"
  exit 3
fi

function apl_arome_content2cycle {
  # variable content_apl_arome must contain the source code of apl_arome.F90
  if grep CPG_DYN_TYPE <(echo $content_apl_arome) > /dev/null; then
    echo 48t3
  else
    echo 48t1
  fi
}

function ial_version_content2key {
  # variable content_ial_version must contain the source code of ial_version.json
  # $1 must be the key name
  # $2 is the default value
  content_ial_version=$content_ial_version python3 -c "import json; import os; print(json.loads(os.environ['content_ial_version']).get('$1', '$2'))"
}

#Name is choosen such as it can be produced with a main pack: PHYEX/${cycle}_XXXXXXXXX.01.${gmkpack_l}.${gmkpack_o}
fromdir=''
if echo $commit | grep '/' | grep -v '^tags/' > /dev/null; then
  fromdir=$commit
  if [ "$cycle" == "" ]; then
    content_ial_version=$(scp $commit/src/arome/ial_version.json /dev/stdout 2>/dev/null || echo "")
    if [ "$content_ial_version" == "" ]; then
      content_apl_arome=$(scp $commit/src/arome/ext/apl_arome.F90 /dev/stdout)
      cycle=$(apl_arome_content2cycle)
    else
      cycle=$(ial_version_content2key cycle '')
      scripttag=$(ial_version_content2key scripttag '')
    fi
  fi
  if [[ ! -z "${gmkpack_o[$cycle]+unset}" ]]; then #the -v approach is valid only with bash > 4.3:  if [[ -v gmkpack_o[$cycle] ]]; then
    gmkpack_o=${gmkpack_o[$cycle]}
  else
    gmkpack_o=${gmkpack_o[default]}
  fi
  if [[ ! -z "${gmkpack_l[$cycle]+unset}" ]]; then
    gmkpack_l=${gmkpack_l[$cycle]}
  else
    gmkpack_l=${gmkpack_l[default]}
  fi
  packBranch=$(echo $commit | sed 's/\//'${separator}'/g' | sed 's/:/'${separator}'/g' | sed 's/\./'${separator}'/g')
  name="PHYEX/${cycle}_${packBranch}.01.${gmkpack_l}.${gmkpack_o}"
  [ $suppress -eq 1 -a -d $HOMEPACK/$name ] && rm -rf $HOMEPACK/$name
elif echo $specialPack | grep -w $commit > /dev/null; then
  name="PHYEX/$commit"
  if [ $commit == split_49t0 ]; then
    cycle=49t0
  elif [ $commit == split_48t3 ]; then
    cycle=48t3
  else
    cycle=48t1
  fi
else
  packBranch="COMMIT$(echo $commit | sed 's/\//'${separator}'/g' | sed 's/:/'${separator}'/g' | sed 's/\./'${separator}'/g')"
  if [ "$cycle" == "" ]; then
    if [[ $commit == arome${separator}* ]]; then
      apl_arome_file="ext/apl_arome.F90"
      ial_version_file="ial_version.json"
    else
      apl_arome_file="src/arome/ext/apl_arome.F90"
      ial_version_file="src/arome/ial_version.json"
    fi
    if echo $commit | grep '^tags/' > /dev/null; then
      urlcommit=$(echo $commit | cut -d / -f 2-)
    else
      urlcommit=$commit
    fi
    content_ial_version=$(wget --no-check-certificate https://raw.githubusercontent.com/$PHYEXREPOuser/PHYEX/${urlcommit}/$ial_version_file -O - 2>/dev/null || echo "")
    if [ "$content_ial_version" == "" ]; then
      content_apl_arome=$(wget --no-check-certificate https://raw.githubusercontent.com/$PHYEXREPOuser/PHYEX/${urlcommit}/$apl_arome_file -O - 2>/dev/null)
      cycle=$(apl_arome_content2cycle)
    else
      cycle=$(ial_version_content2key cycle)
      scripttag=$(ial_version_content2key scripttag)
    fi
  fi
  if [[ ! -z "${gmkpack_o[$cycle]+unset}" ]]; then #the -v approach is valid only with bash > 4.3:  if [[ -v gmkpack_o[$cycle] ]]; then
    gmkpack_o=${gmkpack_o[$cycle]}
  else
    gmkpack_o=${gmkpack_o[default]}
  fi
  if [[ ! -z "${gmkpack_l[$cycle]+unset}" ]]; then
    gmkpack_l=${gmkpack_l[$cycle]}
  else
    gmkpack_l=${gmkpack_l[default]}
  fi
  name="PHYEX/${cycle}_${packBranch}.01.${gmkpack_l}.${gmkpack_o}"
  [ $suppress -eq 1 -a -d $HOMEPACK/$name ] && rm -rf $HOMEPACK/$name
fi
if [ ! -z "${reference-}" ]; then
  [ $reference == 'REF' ] && reference=$(eval echo $defaultRef) #echo to replace ${cycle} by value
  reffromdir=''
  if echo $reference | grep '/' > /dev/null; then
    reffromdir=$reference
    refname="PHYEX/*_$(echo $reference | sed 's/\//'${separator}'/g' | sed 's/:/'${separator}'/g' | sed 's/\./'${separator}'/g').01.${gmkpack_l}.${gmkpack_o}"
  elif echo $specialPack | grep -w $reference > /dev/null; then
    refname="PHYEX/$reference"
  else
    refname="PHYEX/*_COMMIT${reference}.01.${gmkpack_l}.${gmkpack_o}"
  fi
fi

if [ $packcreation -eq 1 ]; then
  echo "### Compilation of commit $commit"

  if echo $specialPack | grep -w $commit > /dev/null; then
    echo "Special commit '$commit' cannot be compiled with this script"
    exit 4
  fi

  if [ -d $HOMEPACK/$name ]; then
    echo "Pack already exists ($HOMEPACK/$name), suppress it to be able to compile it again (or use the -s option to automatically suppress it)"
    exit 5
  fi

  export GMKTMP=/dev/shm

  if [ $cycle == '49t2' ]; then
    if ! which ial-git2pack > /dev/null 2>&1; then
      echo "ial-git2pack not found, please install it"
      exit 7
    fi
    #Pack creation using ial-git2pack
    tmpbuilddir=$(mktemp -d)
    trap "\rm -rf $tmpbuilddir" EXIT
    cd $tmpbuilddir
    git clone $(ial_version_content2key IALrepo git@github.com:ACCORD-NWP/IAL.git)
    cd IAL
    git checkout $(ial_version_content2key IALcommit 'XXXXXXX')
    IALbundle_tag=$(ial_version_content2key IALbundle_tag '')
    [ "$IALbundle_tag" != "" ] && IALbundle_tag="--hub_bundle_tag $IALbundle_tag"
    ROOTPACKopt=""
    if [ $fullcompilation == 0 ]; then
      kind=incr
      if [ "$PHYEXROOTPACK" != "" ]; then
        ROOTPACKopt="--rootpack $PHYEXROOTPACK"
      fi
    else
      kind=main
    fi
    echo y | ial-git2pack -l ${gmkpack_l} -o ${gmkpack_o} -t $kind -n 10 \
                          -r $tmpbuilddir/IAL -p masterodb \
                          $ROOTPACKopt \
                          --homepack $tmpbuilddir/pack $IALbundle_tag

    #Moving
    oldname=$(echo $tmpbuilddir/pack/*)
    mv $oldname $HOMEPACK/$name
    for file in $HOMEPACK/$name/ics_*; do
      sed -i "s*$oldname*$HOMEPACK/$name*g" $file
    done
    rm -rf $tmpbuilddir

    #Workarounds for 49t2 compilation
    cd $HOMEPACK/$name
    rm -rf src/local/obstat src/local/oopsifs
    rm -rf hub/local/src/Atlas hub/local/src/OOPS hub/local/src/ecSDK/?ckit
    if [ $fullcompilation != 0 ]; then
      gmkfile=$HOMEPACK/$name/.gmkfile/${gmkpack_l}.*
      for key in REPRO48 WITH_ODB WITHOUT_ECFLOW; do
        if ! grep "^MACROS_FRT" $gmkfile | grep -e -D$key; then
          sed -i "/^MACROS_FRT/s/$/ -D$key/" $gmkfile
        fi
      done
      if ! grep "^GMK_CMAKE_ectrans" $gmkfile | grep -e -DENABLE_ETRANS=ON; then
        sed -i "/^GMK_CMAKE_ectrans/s/$/ -DENABLE_ETRANS=ON/" $gmkfile
      fi
      reftree='local'
    else
      reftree='main'
    fi

    #Prepare PHYEX inclusion
    rm -rf src/local/phyex
    mkdir src/local/phyex
  elif [ $fullcompilation == 0 ]; then
    #Incremental compilation old style
    basepack=${cycle}_main.01.${gmkpack_l}.${gmkpack_o}
    #[ $HPC -eq 0 -a ! -d $ROOTPACK/$basepack ] &&  getpack $basepack
    gmkpack -r ${cycle} -b phyex -v $mainPackVersion -l ${gmkpack_l} -o ${gmkpack_o} -p masterodb \
            -f $dirpack/ \
            -u $name
    reftree='main'
  else
    #Main pack creation old style
    if [ $(echo $cycle | cut -c 1-2) -ne 48 ]; then
      hub='-K'
    else
      hub=''
    fi
    #Create main pack
    gmkpack -a $hub -r ${cycle} -b ${packBranch} -n 01 -l ${gmkpack_l} -o ${gmkpack_o} -p masterodb -h $HOMEPACK/PHYEX
    #Populate hub
    if [ -d $HOMEPACK/$name/hub ]; then
      cd $HOMEPACK/$name/hub/local/src
      if [ $HPC -eq 1 ]; then
        ssh sxphynh.cnrm.meteo.fr "wget http://anonymous:mto@webdav.cnrm.meteo.fr/public/algo/khatib/src/hub49.tgz -O -" > hub49.tgz
      else
        wget http://anonymous:mto@webdav.cnrm.meteo.fr/public/algo/khatib/src/hub49.tgz
      fi
      tar xf hub49.tgz
      rm -f hub49.tgz
    fi
    #Populate
    cd $HOMEPACK/$name/src/local/
    if [ $HPC -eq 1 ]; then
      ssh sxphynh.cnrm.meteo.fr "wget http://anonymous:mto@webdav.cnrm.meteo.fr/public/algo/khatib/src/${cycle}_main.01.tgz -O -" > ${cycle}_main.01.tgz
    else
      wget http://anonymous:mto@webdav.cnrm.meteo.fr/public/algo/khatib/src/${cycle}_main.01.tgz
    fi
    tar xf ${cycle}_main.01.tgz
    rm -f ${cycle}_main.01.tgz
    #Cleaning and moving
    if [ "$cycle" == '48t3' -o "$cycle" == '49t0' ]; then
      #extracting budgets from micro
      mkdir mpa/budgets
      for file in mpa/micro/module/moddb_intbudget.F90 mpa/micro/externals/aro_suintbudget_omp.F90 \
                  mpa/micro/interface/aro_convbu.h mpa/micro/externals/aro_convbu.F90 \
                  mpa/micro/interface/aro_startbu.h mpa/micro/externals/aro_startbu.F90 \
                  mpa/micro/externals/aro_suintbudget.F90 mpa/micro/externals/aro_suintbudget_omp.F90 \
                  mpa/micro/interface/aroini_budget.h mpa/micro/externals/aroini_budget.F90; do
        [ -f $file ] && mv $file mpa/budgets/
      done 
      mkdir mpa/aux
      for file in mpa/micro/interface/aroini_frommpa.h mpa/micro/externals/aroini_frommpa.F90 \
                  mpa/micro/externals/modd_spp_type.F90 mpa/micro/externals/spp_mod_type.F90 \
                  mpa/micro/interface/aroini_cstmnh.h mpa/micro/externals/aroini_cstmnh.F90; do
        [ -f $file ] && mv $file mpa/aux/
      done
      [ -f mpa/micro/externals/add_bounds.F90 ] && rm -f mpa/micro/externals/add_bounds.F90
      [ -f mpa/micro/externals/aroini_wet_dep.F90 ] && mv mpa/micro/externals/aroini_wet_dep.F90 mpa/chem/externals/aroini_wet_dep.F90
      [ -f mpa/micro/interface/aroini_wet_dep.h ] && mv mpa/micro/interface/aroini_wet_dep.h mpa/chem/interface/aroini_wet_dep.h
    fi
    if [ "$cycle" == '49t0' ]; then
      rm -rf oopsifs
    fi
    #we keep everything from the official source code except internals and module subdirectories of mpa
    #and except some files of mpa/conv/module
    for file in modi_shallow_convection.F90 modi_shallow_convection_part1.F90 \
                modi_shallow_convection_part2.F90 modi_shallow_convection_part2_select.F90; do
      if [ -f mpa/conv/module/$file ]; then
        [ ! -d mpa/conv/module_save ] && mkdir mpa/conv/module_save
        mv mpa/conv/module/$file mpa/conv/module_save/
      fi
    done
    for rep in turb micro conv; do
      mkdir -p phyex/$rep
      rm -rf mpa/$rep/internals mpa/$rep/module
    done
    [ -d mpa/conv/module_save ] && mv mpa/conv/module_save mpa/conv/module
    if [ -f /cnrm/algo/khatib/drhook.c_for_ubuntu.tar -a $(echo $cycle | cut -c 1-2) -eq 48 ]; then
      #If file exists it means that we are running on a CTI computer, so we are using ubuntu
      tar xf /cnrm/algo/khatib/drhook.c_for_ubuntu.tar
    fi
    #Special modification of the compilation configuration file and script
    sed -i 's/-ftree-vectorize//' $HOMEPACK/$name/.gmkfile/${gmkpack_l}.*
    sed -i "/^MACROS_FRT/s/$/ -DREPRO48/" $HOMEPACK/$name/.gmkfile/${gmkpack_l}.*
    #sed -i "s/PHYEX\/${cycle}_$$.01.${gmkpack_l}.${gmkpack_o}/$(echo $name | sed 's/\//\\\//')/" $HOMEPACK/$name/ics_masterodb #this line could be used if pack was renamed before compilation but it does not work on belenos

    resetpack -f #Is it really useful?
    reftree='local'
  fi
  cd $HOMEPACK/$name/src/local/phyex

  MNH_EXPAND_DIR=$PHYEXTOOLSDIR/mnh_expand
  export PATH=$MNH_EXPAND_DIR/filepp:$MNH_EXPAND_DIR/MNH_Expand_Array:$PATH

  if [ $useexpand == 1 ]; then
    expand_options="-D MNH_EXPAND -D MNH_EXPAND_LOOP"
  else
    expand_options=""
  fi
  subs="-s gmkpack_ignored_files -s turb -s micro -s aux -s ext -s conv -s externals" #externals is the old name for aux/ext
  prep_code=$PHYEXTOOLSDIR/prep_code.sh
  if [ "$fromdir" == '' ]; then
    echo "Clone repository, and checkout commit $commit (using prep_code.sh)"
    if [[ $commit == arome${separator}* ]]; then
      $prep_code -c $commit PHYEX #This commit is ready for inclusion
    else
      $prep_code -c $commit $expand_options $subs -m arome PHYEX
    fi
  else
    echo "Copy $fromdir"
    mkdir PHYEX
    scp -q -r $fromdir/src PHYEX/
    $prep_code $expand_options $subs -m arome PHYEX
  fi
  find PHYEX -type f -exec touch {} \; #to be sure a recompilation occurs
  for rep in turb micro conv aux; do
    [ -d PHYEX/$rep ] && mv PHYEX/$rep .
  done
  #modd_nsv.F90 has been moved and gmkpack is lost in case a different version exists in main/.../micro
  if [ -f ../../main/phyex/micro/modd_nsv.F90 -a -f aux/modd_nsv.F90 ]; then
    mv aux/modd_nsv.F90 micro/
    if [ -f PHYEX/gmkpack_ignored_files ]; then
      grep -v micro/modd_nsv.F90 PHYEX/gmkpack_ignored_files > PHYEX/gmkpack_ignored_files_new
      mv PHYEX/gmkpack_ignored_files_new PHYEX/gmkpack_ignored_files
    fi
  fi
  if [ -f PHYEX/gmkpack_ignored_files ]; then
    #gmkpack_ignored_files contains a list of file, present in the reference pack, that is not used anymore
    #and must be excluded from compilation (in case of a full comilation) or from re-compilation (in case of a non-full
    #compilation).
    if [ $fullcompilation == 0 ]; then
      #Content is added in the ics_masterodb script
      if [ $(wc -l PHYEX/gmkpack_ignored_files) != 0 ]; then
        sed -i "/^end_of_ignored_files/i $(first=1; for line in $(cat PHYEX/gmkpack_ignored_files); do echo -n $(test $first -ne 1 && echo \\n)${line}; first=0; done)" $HOMEPACK/$name/ics_masterodb
      fi
    else
      #Files must be suppressed (non phyex files)
      for file in $(cat PHYEX/gmkpack_ignored_files); do
        [ -f $HOMEPACK/$name/src/local/$file ] && rm -f $HOMEPACK/$name/src/local/$file
      done
      if [ -d $HOMEPACK/$name/src/local/mpa/dummy ]; then
        [ ! "$(ls -A $HOMEPACK/$name/src/local/mpa/dummy)" ] && rmdir $HOMEPACK/$name/src/local/mpa/dummy
      fi
    fi
  fi

  EXT=PHYEX/ext
  [ ! -d $EXT ] && EXT=PHYEX/externals #old name for ext/aux
  if [ -d $EXT ]; then
    #Move manually files outside of mpa (a find on the whole repository would take too much a long time)
    [ -f $EXT/yomparar.F90 ] && mv $EXT/yomparar.F90 ../arpifs/module/
    [ -f $EXT/namparar.nam.h ] && mv $EXT/namparar.nam.h ../arpifs/namelist
    [ -f $EXT/namlima.nam.h ] && mv $EXT/namlima.nam.h ../arpifs/namelist
    [ -f $EXT/suparar.F90 ] && mv $EXT/suparar.F90 ../arpifs/phys_dmn/
    [ -f $EXT/apl_arome.F90 ] && mv $EXT/apl_arome.F90 ../arpifs/phys_dmn/
    [ -f $EXT/suphmpa.F90 ] && mv $EXT/suphmpa.F90 ../arpifs/phys_dmn/
    [ -f $EXT/suphmse.F90 ] && mv $EXT/suphmse.F90 ../arpifs/phys_dmn/
    [ -f $EXT/vdfhghtnhl.F90 ] && mv $EXT/vdfhghtnhl.F90 ../arpifs/phys_dmn/
    [ -f $EXT/cpg_opts_type_mod.fypp ] && mv $EXT/cpg_opts_type_mod.fypp ../arpifs/module/
    file=$EXT/cpg_pt_ulp_expl.fypp; [ -f $file ] && mv $file ../arpifs/adiab/
    file=$EXT/field_variables_mod.fypp; [ -f $file ] && mv $file ../arpifs/module/
    file=$EXT/cpg_type_mod.fypp; [ -f $file ] && mv $file ../arpifs/module/
    file=$EXT/field_registry_mod.fypp; [ -f $file ] && mv $file ../arpifs/module/
    file=$EXT/mf_phys_next_state_type_mod.fypp; [ -f $file ] && mv $file ../arpifs/module/
    file=$EXT/yemlbc_model.F90; [ -f $file ] && mv $file ../arpifs/module/
    [ -f $EXT/aplpar.F90 ] && mv $EXT/aplpar.F90 ../arpifs/phys_dmn/
    [ -f $EXT/su0yomb.F90 ] && mv $EXT/su0yomb.F90 ../arpifs/setup/
    [ -f $EXT/acvppkf.F90 ] && mv $EXT/acvppkf.F90 ../arpifs/phys_dmn/
    #Special mpa case
    for file in modd_spp_type.F90 spp_mod_type.F90 aroini_conf.h aroini_conf.F90; do
      if [ -f $EXT/$file ]; then
        [ ! -d ../mpa/aux ] && mkdir ../mpa/aux
        mv $EXT/$file ../mpa/aux/
      fi
    done
    [ -d $EXT/dead_code ] && rm -rf $EXT/dead_code/
    if [ $EXT == "PHYEX/externals" ]; then
      mv $EXT .
    else
      #Move automatically all codes under mpa
      for file in $EXT/*; do
        extname=`basename $file`
        loc=`find ../../$reftree/mpa/ -name $extname | sed "s/\/$reftree\//\/local\//g"`
        nb=`echo $loc | wc -w`
        if [ $nb -ne 1 ]; then
          echo "Don't know where $file must be moved, none or several places found!"
          exit 9
        fi
        mv $file $loc
      done
    fi
  fi
  rm -rf PHYEX
fi

if [ $compilation -eq 1 ]; then
  echo "### Compilation of commit $commit"

  cd $HOMEPACK/$name
  sed -i 's/GMK_THREADS=1$/GMK_THREADS=10/' ics_masterodb
  cleanpack -f
  resetpack -f

  [ -f ics_packages ] && exescript Output_compilation_hub ics_packages
  exescript Output_compilation ics_masterodb
  if [ $extraCompilationCheck -eq 1 -a \
       -f bin/MASTERODB \
       -a $(grep Error Output_compilation | \
            grep -v TestErrorHandler | \
            grep -v "'Error" | \
            grep -v "'CPLNG: Error" | \
            grep -v '"Error' | \
            grep -v "'*** Error" | \
            grep -v "-- Up-to-date:" | wc -l) -ne 0 ]; then
      echo "MASTERODB was produced but errors occured during compilation:"
      grep Error Output_compilation | \
            grep -v TestErrorHandler | \
            grep -v "'Error" | \
            grep -v "'CPLNG: Error" | \
            grep -v '"Error' | \
            grep -v "'*** Error" | \
            grep -v "-- Up-to-date:"
      echo "MASTERODB suppressed!"
      rm -f bin/MASTERODB
  fi
fi

if [ $run -ge 1 ]; then
  echo "### Running of commit $commit"

  if [ ! -f $HOMEPACK/$name/bin/MASTERODB ]; then
    echo "Pack does not exist ($HOMEPACK/$name) or compilation has failed, please check"
    exit 6
  fi

  #Cleaning to suppress old results that may be confusing in case of a crash during the run
  for t in $(echo $tests | sed 's/,/ /g'); do
    cd $HOMEPACK/$name
    if [ -d conf_tests/$t ]; then
      rm -rf conf_tests/$t
    fi
  done

  #Run the tests one after the other
  for t in $(echo $tests | sed 's/,/ /g'); do
    cd $HOMEPACK/$name
    mkdir -p conf_tests/$t
    cd conf_tests/$t
    MYLIB=$name TESTDIR=$dirconf/$t exescript Output_run $dirconf/$t/aro${cycle}${scripttag}.sh
  done
fi

if [ $check -eq 1 ]; then
  echo "### Check commit $commit against commit $reference"

  allt=0
  message=""
  filestocheck=""
  for t in $(echo $tests | sed 's/,/ /g'); do
    if echo $t | grep 'small' > /dev/null; then
      if [ $cycle == '49t2' ]; then
        filestocheck="$filestocheck ${t},conf_tests/$t/ICMSHFPOS+0002:00"
      else
        filestocheck="$filestocheck ${t},conf_tests/$t/ICMSHFPOS+0002:00 ${t},conf_tests/$t/DHFDLFPOS+0002"
      fi
    else
      filestocheck="$filestocheck ${t},conf_tests/$t/NODE.001_01"
    fi
  done
  for tag_file in $filestocheck; do
      tag=$(echo $tag_file | cut -d, -f1)
      file=$(echo $tag_file | cut -d, -f2)
      file1=$HOMEPACK/$name/$file
      file2=$(echo $HOMEPACK/$refname/$file) #echo to enable shell substitution

      mess=""
      t=0
      if [ ! -f "$file1" ]; then
        mess="Result ($file1) for commit $commit does not exist, please run the simulation"
        t=1
      fi
      if [ ! -f "$file2" ]; then
        mess2="Result ($file2) for commit $reference does not exist, please run the simulation"
        t=1
        if [ "$mess" = "" ]; then
          mess=$mess2
        else
          mess="$mess and $mess2"
        fi
      fi
      if [ $t -eq 0 ]; then
        if [ $(basename $file) == ICMSHFPOS+0002:00 ]; then
          #historic files
          cmd="cmp $file1 $file2 256 256"
          output='stderr'
        elif [ $(basename $file) == DHFDLFPOS+0002 ]; then
          #DDH files
          ddh_images="$HOMEPACK/$name/ddh_diff_${tag}.png"
          if [ `hostname` == 'sxphynh' ]; then
            [ ! -d /d0/images/$USER ] && mkdir /d0/images/$USER
            ddh_images="$ddh_images /d0/images/$USER/ddh_diff_${tag}.png"
          fi
          cmd="$PHYEXTOOLSDIR/comp_DDH.py"
          if [ ! -x $cmd ]; then
            echo "Command not found: \"$cmd\""
            exit 10
          fi
          cmd="$cmd $file1 $file2 $ddh_images"
          output='stdout'
        elif [ $(basename $file) == NODE.001_01 ]; then
          #Output listing
          cmd="$PHYEXTOOLSDIR/diffNODE.001_01"
          if [ ! -x $cmd ]; then
            echo "Command not found: \"$cmd\""
            exit 11
          fi
          cmd="$cmd $file1 $file2 --norm-max-diff=0."
          output='stdout'
        else
          cmd="cmp $file1 $file2"
          output='stderr'
        fi
        set +e
        if [ $output == 'stderr' ]; then
            mess=$($cmd 2>&1)
        else
            mess=$($cmd 2>/dev/null)
        fi
        t=$?
        set -e
      fi
      [ $t -ne 0 ] && message="$message $file : $mess \n"
      allt=$(($allt+$t))
  done
  if [ $allt -eq 0 ]; then
    echo "SUCCESS, files are (nearly) identical"
  else
    echo "*************** Files are different *******************"
    echo -e "$message"
  fi
fi
