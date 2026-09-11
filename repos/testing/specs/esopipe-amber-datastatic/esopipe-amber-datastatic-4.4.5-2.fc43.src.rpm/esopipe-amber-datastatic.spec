%define instrument amber
Name: esopipe-%{instrument}-datastatic
Version: 4.4.5
Release: 2%{?dist}
BuildArch: noarch
Summary: ESO AMBER instrument pipeline (static data)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines
Source0: %{instrument}-calib-%{version}.tar.gz

%description
ESO data reduction pipeline for the AMBER instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This package contains the static data used by the pipeline.

%prep
if ! test -f %{SOURCE0} ; then
    # Unpack the source tarball from the pipeline kit if it is not yet available.
    cd '%{_sourcedir}'
    %_urlhelper - 'https://ftp.eso.org/pub/dfs/pipelines/instruments/%{instrument}/%{instrument}-kit-%{version}-15.tar.gz' | gzip -dc | tar -xf - '%{instrument}-kit-%{version}-15/%{instrument}-calib-%{version}.tar.gz'
    mv '%{instrument}-kit-%{version}-15/%{instrument}-calib-%{version}.tar.gz' ./
    rmdir '%{instrument}-kit-%{version}-15'
fi
cd %{_builddir}
gzip -dc '%{SOURCE0}' | tar -xf -

%define staticdatadir %{_datadir}/esopipes/datastatic/%{instrument}-%{version}

%install
rm -rf %{buildroot}
install -m 755 -d %{buildroot}%{staticdatadir}
install -m 644 %{_builddir}/%{instrument}-calib-%{version}/cal/* %{buildroot}%{staticdatadir}

%files
%{_datadir}/esopipes

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 4.4.5-2
- New version created.
