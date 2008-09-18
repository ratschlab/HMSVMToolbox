#!/bin/sh

base_dr="${HOME}/svn/projects/hmsvm" 
cd $base_dr

dt=`date +%Y-%m-%d`
rel_dr="${base_dr}/releases/release_${dt}"

echo "Deploying new release to $rel_dr"
if [ ! -d $rel_dr ]
then
  mkdir $rel_dr
  echo "Created $rel_dr"
fi
if [ ! -d "${rel_dr}/src" ]
then
  mkdir "$rel_dr/src"
fi

# deploy doc files in base directory
cp "${base_dr}/releases/AUTHORS" "$rel_dr/src/"
cp "${base_dr}/releases/LICENSE" "$rel_dr/src/"
cp "${base_dr}/README" "$rel_dr/src/"


# deploy source files in base directory
file_list=`ls ${base_dr}/*.m`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/"
done
file_list=`ls ${base_dr}/*.h`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/"
done
file_list=`ls ${base_dr}/*.cpp`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/"
done


# deploy source files from opt_interface subdirectory
if [ ! -d "${rel_dr}/src/opt_interface" ]
then
  mkdir "${rel_dr}/src/opt_interface"
fi
if [ ! -d "${rel_dr}/src/opt_interface/mosek" ]
then
  mkdir "${rel_dr}/src/opt_interface/mosek"
fi
cp "${base_dr}/opt_interface/mosek/README" "${rel_dr}/src/opt_interface/mosek/"
file_list=`ls ${base_dr}/opt_interface/mosek/*.m`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/opt_interface/mosek"
done

if [ ! -d "${rel_dr}/src/opt_interface/cplex" ]
then
  mkdir "${rel_dr}/src/opt_interface/cplex"
fi
cp "${base_dr}/opt_interface/cplex/README" "${rel_dr}/src/opt_interface/cplex/"
cp "${base_dr}/opt_interface/cplex/compile_mex.sh" "${rel_dr}/src/opt_interface/cplex/"
file_list=`ls ${base_dr}/opt_interface/cplex/*.m`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/opt_interface/cplex/"
done
file_list=`ls ${base_dr}/opt_interface/cplex/*.c`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/opt_interface/cplex/"
done


# deploy source files from models/two_state subdirectory
if [ ! -d "${rel_dr}/src/models" ]
then
  mkdir "${rel_dr}/src/models"
fi
if [ ! -d "${rel_dr}/src/models/two_state" ]
then
  mkdir "${rel_dr}/src/models/two_state"
fi
file_list=`ls ${base_dr}/models/two_state/*.m`
for fn in $file_list
do
  cp $fn "${rel_dr}/src/models/two_state"
done


# create archive
cd $rel_dr
tar -czvf "${rel_dr}_src.tar.gz" src

