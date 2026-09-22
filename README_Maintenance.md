# epl Maintenance

A MacPorts repository for ESO PipeLines.

## General Users

This should only be performed by the github repositiory Maintainer(s).
For general users, maintain in the usual MacPorts way, i.e./e.g.:

```bash
sudo port selfupdate
sudo port upgrade outdated
sudo port install epl-esopipe-uves
```

## Manual maintenance of the repo

In a terminal, issue the following commands:

```bash
cd /opt/epl
sudo port selfupdate
sudo chgrp -R macports .
sudo chmod -R g+w .
cd repos/stable
bash ../../bin/chk_bump.sh
cd ../testing
bash ../../bin/chk_bump.sh
sudo port sync
```

For a complete refresh...

```bash
cd /opt
sudo rm -fr epl
sudo git clone https://github.com/JohnPritchard/epl.git
sudo chown -R macports:macports epl
sudo chmod -R g+w .
sudo -u macports portindex /opt/epl/repos/stable/macports/ports
sudo -u macports portindex /opt/epl/repos/testing/macports/ports
cd /opt/epl
sudo port selfupdate
sudo chmod -R g+w .
sudo chgrp -R macports .
cd repos/stable
bash ../../bin/chk_bump.sh
cd ../testing
bash ../../bin/chk_bump.sh
sudo port sync
```