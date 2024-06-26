#! /bin/bash
exec > >(tee -a archsetupminimal.log)
exec 2> >(tee -a archsetupminimal.log >&2)

./scripts/preinstall.sh && \
./scripts/setup.sh && \
./scripts/install.sh

exec >&-
exec 2>&-

exit 0