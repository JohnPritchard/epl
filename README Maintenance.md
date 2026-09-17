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
sudo -u macports git pull
cd repos/stable
bash ../../bin/chk_bump.sh
cd ../testing
bash ../../bin/chk_bump.sh
```
