Name: esorex
Version: 3.14
Release: a2.1%{?dist}
Summary: Recipe Execution Tool of the European Southern Observatory

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: ESO <usd-help@eso.org>
URL: http://www.eso.org/sci/software/cpl/esorex.html
Source0: https://ftp.eso.org/pub/dfs/pipelines/libraries/%{name}/%{name}-%{version}a2.tar.gz

BuildRequires: cext-devel >= 1.2.6
BuildRequires: cpl-devel >= 7.0
BuildRequires: gcc-c++
BuildRequires: libffi-devel

%description
EsoRex is the ESO Recipe Execution Tool. It can list, configure and
execute CPL-based recipes from the command line.
One of the features provided by the Common Pipeline Library (CPL) is the ability
to create data-reduction algorithms that run as plugins (dynamic libraries).
These are called "recipes" and are one of the main aspects of the
CPL data-reduction development environment.

%prep
%setup -q -n %{name}-%{version}a2

%build
%configure
%make_build
echo 'This directory should contain standard system wide ESO recipe plugins that will be used by esorex.' \
     > esopipes_dir_README

%check
make %{?_smp_mflags} installcheck

%install
rm -rf %{buildroot}
%make_install
# Install default recipe plugin directory to prevent run-time error messages if missing.
install -m 755 -d %{buildroot}%{_libdir}/esopipes-plugins
install -m 644 esopipes_dir_README %{buildroot}%{_libdir}/esopipes-plugins/README

%files
%doc AUTHORS COPYING README BUGS ChangeLog
%config(noreplace) %{_sysconfdir}/*
%{_bindir}/*
%{_libdir}/esopipes-plugins
%{_datadir}/*

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 3.14-a2.1
- New version created.
