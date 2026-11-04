%global srcname pyhdrl
%global debug_package %{nil}

Name: pyhdrl
Version: 1.0.0
Release: 1%{?dist}

Summary:        Python Language Bindings for the ESO HDRL
Group:          Development/Libraries
License:        GPLv3+
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://www.eso.org/sci/software/pyhdrl/
Source0:        http://piperepo.hq.eso.org/sources/%{srcname}/%{srcname}-1.0.0.tar.gz

BuildRequires: cmake >= 3.12
BuildRequires: cpl-devel >= 7.4
BuildRequires: gcc-c++
BuildRequires: hdrl-devel >= 1.6.0
BuildRequires: python3-pycpl >= 1.0.4
Requires: cmake >= 3.12


BuildRequires:  pyproject-rpm-macros
BuildRequires:  python3-devel >= 3.9
BuildRequires:  python3-setuptools >= 45.0
BuildRequires:  python3-toml
BuildRequires:  python3-wheel
BuildRequires:  python3-pybind11 >= 2.8
BuildRequires:  python3-pytest
BuildRequires:  python3-sphinx
BuildRequires:  python3-sphinx-design


%description
PyHDRL provides Python language bindings for the ESO High Level Data Reduction Library.
It provides access to the data reduction algorithms of HDRL from Python.

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{srcname}}

%description -n python%{python3_pkgversion}-%{srcname}
PyHDRL provides Python language bindings for the ESO High Level Data Reduction  Library.
It provides access to the data reduction algorithms of HDRL from Python.

%prep
%setup -q -n %{srcname}-1.0.0

%generate_buildrequires
%pyproject_buildrequires


%build
if test -z "$CXXFLAGS"; then
    export CXXFLAGS=${RPM_OPT_FLAGS}
fi
%pyproject_wheel

%install
%pyproject_install

%pyproject_save_files hdrl

%files -n python%{python3_pkgversion}-%{srcname} -f %{pyproject_files}
%license LICENSE
%doc README.md

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.0.0-1
- New version created.
