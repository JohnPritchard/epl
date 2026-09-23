%define instrument amber
Name: esopipe-%{instrument}-recipes
Version: 4.4.5
Release: 1%{?dist}
Summary: ESO AMBER instrument pipeline (recipe plugins)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines
Source0: %{instrument}-%{version}.tar.gz

BuildRequires: cfitsio-devel >= 3.350
BuildRequires: cpl-devel >= 7.0
BuildRequires: erfa-devel >= 1.3.0
BuildRequires: fftw-devel >= 3.3.3
BuildRequires: gcc
BuildRequires: gsl-devel >= 1.15
BuildRequires: libcurl-devel
BuildRequires: pkgconfig >= 0.21
Requires: libcurl


%description
ESO data reduction pipeline recipe plugins for the AMBER instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
To execute these one needs to install a front-end such as esorex or Reflex.

%prep
if ! test -f %{SOURCE0} ; then
    # Unpack the source tarball from the pipeline kit if it is not yet available.
    cd '%{_sourcedir}'
    %_urlhelper - 'https://ftp.eso.org/pub/dfs/pipelines/kit_devel/%{instrument}-kit-%{version}-7.tar.gz' | gzip -dc | tar -xf - '%{instrument}-kit-%{version}-7/%{instrument}-%{version}.tar.gz'
    mv '%{instrument}-kit-%{version}-7/%{instrument}-%{version}.tar.gz' ./
    rmdir '%{instrument}-kit-%{version}-7'
fi
%setup -q -n %{instrument}-%{version} -c -T
cd %{_builddir}
gzip -dc '%{SOURCE0}' | tar -xf -

%build
%configure
# http://fedoraproject.org/wiki/PackagingGuidelines#Beware_of_Rpath
sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
%make_build

%check
make %{?_smp_mflags} installcheck

%define ld_conf_file %{_sysconfdir}/ld.so.conf.d/%{instrument}-%{version}.conf

%install
rm -rf %{buildroot}
%make_install
install -m 755 -d %{buildroot}%{_sysconfdir}/ld.so.conf.d
echo '%{_libdir}/%{instrument}-%{version}' > %{buildroot}%{ld_conf_file}
# remove EDPS workflows/ADARI reports for pipelines where the kit includes those
# but the target platform is not capable of running EDPS/ADARI (too old Python3)
[ -d %{buildroot}%{_datadir}/esopipes/reports ] && rm -rf %{buildroot}%{_datadir}/esopipes/reports/*
[ -d %{buildroot}%{_datadir}/esopipes/workflows ] && rm -rf %{buildroot}%{_datadir}/esopipes/workflows/*

%ldconfig_scriptlets

%files
%dir %{_docdir}/esopipes
%dir %{_docdir}/esopipes/*
%doc %{_docdir}/esopipes/*/*
%config %{ld_conf_file}
%{_libdir}/*
%exclude %{_libdir}/*/*.so
%exclude %{_libdir}/*/*.la
%exclude %{_libdir}/esopipes-plugins/*/*.la
%exclude %{_includedir}/*

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 4.4.5-1
- New version created.
