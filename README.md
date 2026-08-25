# epl
ESO Pipelines

## Installation

The following instructions assume that MacPorts is already installed.
If not, see [MacPorts Installation](https://www.macports.org/install.php).

In a terminal, issue the following commands

```bash
bash
cd /opt
sudo git clone https://github.com/JohnPritchard/epl.git
sudo chown -R macports:wheel epl
cd epl/epl/repos/stable/macports/ports
sudo -u macports portindex $(pwd)
sudo /usr/bin/sed -i '' \
    -e "s[^rsync.*[&\nfile://$(pwd)[" \
    /opt/local/etc/macports/sources.conf

```

### Update

In a terminal, issue the following commands

```bash
bash
cd /opt/epl
sudo -u macports git pull
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

