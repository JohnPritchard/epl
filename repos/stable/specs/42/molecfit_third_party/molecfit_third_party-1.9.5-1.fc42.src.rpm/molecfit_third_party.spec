Name: molecfit_third_party
Version: 1.9.5
Release: 1%{?dist}
Summary: 3rd party tools for the Molecfit library

Group: Development/Libraries
License: GPLv2 and Custom-AER
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines/skytools/molecfit
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}.tar

BuildRequires: gcc
BuildRequires: gcc-gfortran
BuildRequires: libgfortran-static
BuildRequires: zlib-devel


%global debug_package %{nil}

%description
This package fulfils Molecfit's dependency requirements. It provides the 3rd
party command line tools and data files that are needed by Molecfit itself.

%prep
%setup -q

%build
make -f BuildThirdParty.mk prefix=%{_prefix}

%install
rm -rf %{buildroot}
make -f BuildThirdParty.mk DESTDIR=%{buildroot} prefix=%{_prefix} install

%files
%{_bindir}/*
%{_datadir}/molecfit/data/hitran

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.9.5-1
- New version created.
