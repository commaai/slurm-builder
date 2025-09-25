#!/usr/bin/env bash
set -e

if [ ! -d slurm ]; then
    wget -O slurm-latest.tar.bz2 $(wget -qO- https://www.schedmd.com/downloads.php | grep -oP 'href="\K[^"]+\.tar\.bz2' | head -1)
    tar xvjf slurm-latest.tar.bz2
    mv "$(ls -d slurm-*/ | head -1)" slurm
    sed -i '/^\s*dh_auto_configure/s/$/ --with-mysql_config=\/usr\/bin --with-munge=no --with-nvml/' slurm/debian/rules
    sed -i '/munge/d' slurm/debian/control
fi

# set the revision number
if [ ! -z "$1" ]; then
  sed -i "s/(\([^-]*\)-[^)]*)/(\1-$1)/" slurm/debian/changelog
fi

head -n 1 slurm/debian/changelog
read -p "Are the version and build revision correct? (y/n): " yn
case $yn in
    [Yy]* ) ;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
esac

mkdir -p $(pwd)/build
docker build --no-cache -t slurm-package .
docker run --rm -v $(pwd)/slurm:/input -v $(pwd)/build:/output slurm-package
