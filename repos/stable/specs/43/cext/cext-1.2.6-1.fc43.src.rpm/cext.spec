Name: cext
Version: 1.2.6
Release: 1%{?dist}
Summary: ESO's C Library Extensions

Group: Development/Libraries
License: GPL-2.0-or-later
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/cpl
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}.tar.gz

BuildRequires: gcc

%description
This provides a C utility library, which is used to implement
the ESO Common Pipeline Library (CPL).

%package devel
Summary: Libraries and includes needed to compile and link against %{name}
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}
%description devel
These are the header files and libraries needed to develop a program that
uses the %{name} library.

%prep
%setup -q

%build
%configure
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
%{_libdir}/*so.*

%files devel
%doc README
%{_libdir}/*.so
%{_libdir}/pkgconfig
%{_includedir}/*
%exclude %{_libdir}/*.la

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.2.6-1
- New version created.
