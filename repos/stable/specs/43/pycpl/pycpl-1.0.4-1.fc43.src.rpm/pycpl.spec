
%global srcname pycpl
%global debug_package %{nil}

Name: pycpl
Version: 1.0.4
Release: 1%{?dist}

Summary:        Python Language Bindings for the ESO CPL
Group:          Development/Libraries
License:        GPLv3+
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://www.eso.org/sci/software/pycpl/
Source0:        http://piperepo.hq.eso.org/sources/%{srcname}/%{srcname}-1.0.4.tar.gz

BuildRequires: cmake >= 3.12
BuildRequires: cpl-devel >= 7.4
BuildRequires: gcc-c++
Requires: cmake >= 3.12


BuildRequires:  pyproject-rpm-macros
BuildRequires:  python3-devel >= 3.9
BuildRequires:  python3-setuptools >= 45.0
BuildRequires:  python3-toml
BuildRequires:  python3-wheel
BuildRequires:  python3-pybind11 >= 2.8
BuildRequires:  python3-astropy
BuildRequires:  python3-pandas
BuildRequires:  python3-pytest
BuildRequires:  python3-scipy
BuildRequires:  python3-sphinx
BuildRequires:  python3-sphinx-design


%description
PyCPL provides Python language bindings for the ESO Common Pipeline Library.
It allows to execute ESO instrument pipeline recipes from Python, as well
as to write ESO compliant pipeline recipes in Python.

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{srcname}}

%description -n python%{python3_pkgversion}-%{srcname}
PyCPL provides Python language bindings for the ESO Common Pipeline Library.
It allows to execute ESO instrument pipeline recipes from Python, as well
as to write ESO compliant pipeline recipes in Python.

%prep
%setup -q -n %{srcname}-1.0.4

%generate_buildrequires
%pyproject_buildrequires


%build
if test -z "$CXXFLAGS"; then
    export CXXFLAGS=${RPM_OPT_FLAGS}
fi
if test -z "$PYCPL_RECIPE_DIR"; then
    export PYCPL_RECIPE_DIR=%{_datadir}/esopipes/pyrecipes:%{_libdir}/esopipes-plugins
fi
%pyproject_wheel

%install
%pyproject_install
test -f %{buildroot}/%{_libdir}/esopipes-plugins || mkdir -p %{buildroot}/%{_libdir}/esopipes-plugins

%pyproject_save_files cpl

%files -n python%{python3_pkgversion}-%{srcname} -f %{pyproject_files}
%license LICENSE
%doc README.md
%dir %{_libdir}/esopipes-plugins

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.0.4-1
- New version created.
