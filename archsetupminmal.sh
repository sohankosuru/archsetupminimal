#! /bin/bash
exec > >(tee -a /mnt/archsetupminimal.log)
exec 2>&1 # >(tee -a /mnt/archsetupminimal.log >&2)

./scripts/preinstall.sh && \
./scripts/setup.sh && \
./scripts/install.sh

#exec >&-
#exec 2>&-

exit 0