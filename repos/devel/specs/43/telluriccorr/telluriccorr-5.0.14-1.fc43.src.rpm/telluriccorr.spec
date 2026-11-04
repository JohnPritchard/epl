Name: telluriccorr
Version: 5.0.14
Release: 1%{?dist}
Summary: Library of algorithms to correct astronomical observations for atmospheric absorption

Group: Development/Libraries
License: GPLv2
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines/skytools/molecfit
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}.tar.gz

BuildRequires: cpl-devel >= 7.1
BuildRequires: gcc
BuildRequires: molecfit_third_party >= 1.9.5
Requires: molecfit_third_party >= 1.9.5

%description
Telluric Correction is a software tool to correct astronomical observations 
for atmospheric absorption features, based on fitting synthetic transmission 
spectra to the astronomical data. It can also estimate molecular abundances, 
especially the water vapour content of the Earth's atmosphere.

%package devel
Summary: Libraries, includes, etc. used to develop an application with %{name}
Requires: %{name} = %{version}-%{release}
%description devel
These are the header files and libraries needed to develop an application that
uses %{name}.

%prep
%setup -q

%build
%configure --with-cpl=%{_prefix}
%make_build

%check
make %{?_smp_mflags} installcheck

%install
rm -rf %{buildroot}
%make_install

%ldconfig_scriptlets

%files
%doc COPYING NEWS
%{_libdir}/*so.*
%{_datadir}/*
%exclude %{_libdir}/*.a

%files devel
%{_libdir}/*.so
%{_includedir}/*
%exclude %{_libdir}/*.la

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 5.0.14-1
- New version created.
