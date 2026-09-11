Name: cpl
Version: 7.4
Release: 1%{?dist}
Summary: ESO library for automated astronomical data-reduction tasks

Group: Development/Libraries
License: GPLv2+
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/cpl
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}.tar.gz

BuildRequires: cext-devel >= 1.3
BuildRequires: cfitsio-devel >= 3.350
BuildRequires: fftw-devel >= 3.3.3
BuildRequires: gcc
BuildRequires: wcslib-devel >= 4.24

%description
The Common Pipeline Library (CPL) comprises a set of ISO-C libraries
that provide a comprehensive, efficient and robust software toolkit.
It forms a basis for the creation of automated astronomical data-reduction
tasks (known as "pipelines") for ESO (European Southern Observatory)
instruments. The CPL was developed to standardize the way
VLT (Very Large Telescope) instrument pipelines are built,
to shorten their development cycle and to ease their maintenance.

%prep
%setup -q

%package devel
Summary: Libraries, includes, etc. used to develop an application with %{name}
Requires: %{name} = %{version}-%{release}
Requires: cext-devel >= 1.3
%description devel
These are the header files and libraries needed to develop a %{name}
application.

%build
%configure --disable-static --with-system-cext
# http://fedoraproject.org/wiki/PackagingGuidelines#Beware_of_Rpath
sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
%make_build

%check
make %{?_smp_mflags} installcheck

%install
rm -rf %{buildroot}
%make_install

%ldconfig_scriptlets

%files
%doc AUTHORS BUGS COPYING NEWS
%{_libdir}/*cpl*so.*

%files devel
%doc README
%{_libdir}/*cpl*.so
%{_libdir}/pkgconfig
%{_includedir}/cpl*
%exclude %{_libdir}/*cpl*.la

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 7.4-1
- New version created.
