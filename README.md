# epl - ESO PipeLines

A MacPorts repository for ESO PipeLines. **This is NOT an official ESO repository**.

The official, supported-by-ESO, recommended installation method for ESO Pipelines on macOS computers is [Homebrew](https://www.eso.org/sci/software/pipe_aem_brew.html).

This repository is intended for experienced MacPorts users. Support is available only on a best effort basis.

If you encounter problems using the pipelines, please check if you get the same issues using the pipeline via the Homebrew or install_script installation method. If so, then please submit a ticket to [ESO User Support](https://support.eso.org).

If you believe the issue is specific to the MacPorts installation method provided by this repository, then please check if there is already an issue at [epl-issues](https://github.com/JohnPritchard/epl/issues) for your issue and if not create one there.

**Do NOT create ESO User Support tickets related to this repository.**

This repository is derived from from the ESO MacPorts repository that was decommissioned 2026-09-01. It is intended for experienced users. It's main purpose is to facilitate comparison of different compilers, and in particular to enable the use of OpenMP for multi-threaded processing. All pipeline packages support compiler variants allowing compilng with MacPorts GCC or CLANG compilersm thus enabling OpenMP code, which is not supported by the default Apple-CLANG compiler.

The package structure has been re-organised in line with the Homebrew implementation, i.e. all -wkf, -gui and -all packages and been removed.

## Activate the repository

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

Once installed as above, you can then install and manage EPL packages in the usual MacPorts way, i.e./e.g.:

```bash
sudo port selfupdate
sudo port upgrade outdated
sudo port install epl-esopipe-uves
sudo port install esoreflex
sudo port install edps
```

The usual eso pipeline execution commands are all prefixed with ```epl-```, i.e.

```bash
epl-esorex
epl-esoreflex
epl-edps
```

Which are provided via softlinks in ```/opt/local/bin```. Alternatively you can add the directory  ```/opt/local/libexec/epl/stable/bin``` to your PATH environment variable to access the commands with their unmodified names, i.e. ```esorex, esoreflex, edps```.

### Deactivate the repository

In a terminal, issue the following commands

```bash
bash
sudo port uninstall eops-\*
sudo /usr/bin/sed -i '' \
    -e "s[^file:.*/epl/[#&[" \
    /opt/local/etc/macports/sources.conf
sudo rm -fr /opt/epl
```

### Update the repository

Once installed as above, the repo will be updated as part of the usual
```port selfupdate``` (or ```port sync```) (followed by
```port upgrade outdated``` to upgrade the installed packages).

### Release channels

This repository supports the stable, testing and devel release channels, though devel packages can only be accessed fron inside the ESO firewall.

Packages from each channel are installed in fully isolated, channel specific subdirectorys of ```/opt/local/libexec/epl```. Multiple channels can be activated simultaneously with packages from any of the channels installed along side each other.

To enable these channels:

```bash
bash
cd /opt/epl/repos/testing/macports/ports
sudo -u macports portindex $(pwd)
sudo /usr/bin/sed -i '' \
    -e "s[^rsync.*[&\nfile://$(pwd)[" \
    /opt/local/etc/macports/sources.conf
cd /opt/epl/repos/devel/macports/ports
sudo -u macports portindex $(pwd)
sudo /usr/bin/sed -i '' \
    -e "s[^rsync.*[&\nfile://$(pwd)[" \
    /opt/local/etc/macports/sources.conf
```

```esorex, esoreflex, edps``` commands are then prefixed by ```epl-``` and suffixed by ```-testing``` or ```-devel``` accordingly, or again one can add the corresponding ```/opt/local/libexec/epl/testing/bin``` or ```/opt/local/libexec/epl/devel/bin``` directories to your PATH environment variable.