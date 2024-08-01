#!/usr/bin/env bash
set -e

if [ ! -d slurm ]; then
    wget -O slurm-latest.tar.bz2 $(wget -qO- https://www.schedmd.com/downloads.php | grep -oP 'href="\K[^"]+\.tar\.bz2' | head -1)
    tar xvjf slurm-latest.tar.bz2
    mv "$(ls -d slurm-*/ | head -1)" slurm
    sed -i '/^\s*dh_auto_configure/s/$/ --with-mysql_config=\/usr\/bin --with-munge=no/' slurm/debian/rules
    sed -i '/munge/d' slurm/debian/control
fi

mkdir -p $(pwd)/build
docker build -t slurm-package .
docker run --rm -v $(pwd)/slurm:/input -v $(pwd)/build:/output slurm-package
