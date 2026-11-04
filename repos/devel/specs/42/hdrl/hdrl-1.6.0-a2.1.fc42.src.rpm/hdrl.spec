Name: hdrl
Version: 1.6.0
Release: a2.1%{?dist}
Summary: ESO High Level Datareduction Library (HDRL)

Group: Development/Libraries
License: GPLv2+
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: https://www.eso.org/sci/software/cpl
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}a2.tar.gz

BuildRequires: cpl-devel >= 7.0.0
BuildRequires: erfa-devel >= 1.3.0
BuildRequires: gsl-devel >= 1.16
BuildRequires: libcurl-devel
Requires: cpl >= 7.0.0
Requires: erfa >= 1.3.0
Requires: gsl >= 1.16
Requires: libcurl


BuildRequires:  doxygen
%description
HDRL (High Level Datareduction Library) is an ESO C library for astronomical
data reduction. It provides algorithms for image combination, bad-pixel
handling, flat-fielding, spectroscopy, and related tasks. HDRL depends on
CPL, GSL, ERFA, and libcurl.

%package devel
Summary: Libraries and includes needed to compile and link against %{name}
Group: Development/Libraries
Requires: %{name} = %{version}-%{release}
%description devel
These are the header files and libraries needed to develop a program that
uses the %{name} library.

%prep
%setup -q -n %{name}-%{version}a2

%build
%configure --enable-standalone
%make_build

%check
make %{?_smp_mflags} installcheck

%install
rm -rf %{buildroot}
%make_install

%ldconfig_scriptlets

%files
# %doc AUTHORS BUGS COPYING NEWS LICENSE - add when a future hdrl tarball includes
# these (e.g. via EXTRA_DIST in Makefile.am). They are currently missing; omit
# until then to avoid "cannot stat" at package build. CPL uses: %doc AUTHORS BUGS COPYING NEWS.
%{_libdir}/*hdrl*so.*

%files devel
%{_libdir}/*hdrl*.so
%{_includedir}/hdrl
%{_libdir}/pkgconfig/hdrl.pc
%{_docdir}/hdrl
%exclude %{_libdir}/*.la

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.6.0-a2.1
- New version created.
