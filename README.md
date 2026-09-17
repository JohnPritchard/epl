# epl

A MacPorts repository for ESO PipeLines.

## Activation of the repository

The following instructions assume that MacPorts is already installed.
If not, see [MacPorts Installation](https://www.macports.org/install.php).

In a terminal, issue the following commands

```bash
bash
cd /opt
sudo git clone https://github.com/JohnPritchard/epl.git
sudo chown -R macports:wheel epl
cd epl/repos/stable/macports/ports
sudo -u macports portindex $(pwd)
sudo /usr/bin/sed -i '' \
    -e "s[^rsync.*[&\nfile://$(pwd)[" \
    /opt/local/etc/macports/sources.conf
```

Test the installation with:

```bash
sudo port list epl-\*
```

Once installed as above, you can then install and manage EPL packages in the usual MacPorts
way, i.e./e.g.:

```bash
sudo port selfupdate
sudo port upgrade outdated
sudo port install epl-esopipe-uves
```

### Update

Once installed as above, the repo will be updated as part of the usual
```port selfupdate``` (or ```port sync```) (followed by
```port upgrade outdated``` to upgrade the installed packages).
But if you want to update the repo independently of that
in a terminal, issue the following commands:

```bash
bash
cd /opt/epl
sudo -u macports git pull
sudo -u macports portindex repos/stable/macports/ports
```

### Deactivate

In a terminal, issue the following commands

```bash
bash
cd /opt
sudo port uninstall eops-\*
sudo /usr/bin/sed -i '' \
    -e "s[^file:.*/epl/[#&[" \
    /opt/local/etc/macports/sources.conf
sudo rm -fr epl
```
