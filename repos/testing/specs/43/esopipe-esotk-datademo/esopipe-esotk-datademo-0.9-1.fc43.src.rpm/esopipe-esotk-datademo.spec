%define instrument esotk
Name: esopipe-%{instrument}-datademo
Version: 0.9
Release: 1%{?dist}
BuildArch: noarch
Summary: ESO ESOTK instrument pipeline (demo data)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines

Requires: /bin/find
Requires: /bin/tar

%description
ESO data reduction pipeline for the ESOTK instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This package will download the Reflex demo data from the ESO FTP.
The data can be used to test the pipeline workflows.

%define datademodir %{_datadir}/esopipes/datademo/%{instrument}

%install
rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{datademodir}

%post
cd %{datademodir}
if [ "$1" -gt 1 ] ; then
    # The package is being upgraded so wipe whatever was there before.
    rm -rf %{datademodir}/*
fi
# Download and unpack the demo data into the installation directory.
fail=1
for ((N=1;N<100;N++)) ; do
    %_urlhelper - 'https://ftp.eso.org/pub/dfs/pipelines/instruments/%{instrument}/%{instrument}-demo-reflex-%{version}.tar.gz' | tar -zxpo
    if [ $? -eq 0 ] ; then
        fail=0
        break
    fi
done
[ $fail -eq 0 ] || exit 1
find %{datademodir} -type d -exec chmod 755 {} \;
find %{datademodir} ! -type d -exec chmod 644 {} \;

%preun
# Remove the downloaded demo data if this is the last package version being
# uninstalled. We do this in the pree-uninstall phase so that RPM can cleanup
# the empty directories.
if [ "$1" -eq 0 ] ; then
    rm -rf %{datademodir}/*
fi

%files
%dir %{_datadir}/esopipes
%dir %{_datadir}/esopipes/datademo
%dir %{_datadir}/esopipes/datademo/%{instrument}

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 0.9-1
- New version created.
