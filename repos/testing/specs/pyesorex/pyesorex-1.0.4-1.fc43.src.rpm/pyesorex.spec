%global srcname pyesorex
%global debug_package %{nil}

Name: pyesorex
Version: 1.0.4
Release: 1%{?dist}

Summary:        Python ESO Recipe Execution Tool
Group:          Applications/Scientific
License:        GPLv3+
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://www.eso.org/sci/software/pycpl/
Source0:        http://piperepo.hq.eso.org/sources/%{srcname}/%{srcname}-1.0.4.tar.gz

BuildRequires: python3-pycpl >= 1.0.4


BuildArch: noarch

BuildRequires:  pyproject-rpm-macros
BuildRequires:  python3-devel >= 3.9
BuildRequires:  python3-setuptools >= 45.0
BuildRequires:  python3-pip
BuildRequires:  python3-toml
BuildRequires:  python3-wheel
BuildRequires:  python3-pytest
BuildRequires:  python3-sphinx
BuildRequires:  python3-sphinx-design


%description
PyEsoRex is new recipe execution tool that complements the PyCPL library. It
fills the role of the existing EsoRex recipe execution tool, but extends it by
facilitating the execution of recipes implemented either in C using CPL or in
Python using PyCPL. PyEsoRex is meant to be a drop-in replacement of the classic
EsoRex tool.

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{srcname}}

%description -n python%{python3_pkgversion}-%{srcname}
PyEsoRex is new recipe execution tool that complements the PyCPL library. It
fills the role of the existing EsoRex recipe execution tool, but extends it by
facilitating the execution of recipes implemented either in C using CPL or in
Python using PyCPL. PyEsoRex is meat to be a drop-in replacement of the classic
EsoRex tool.

%prep
%setup -q -n %{srcname}-1.0.4

%generate_buildrequires
%pyproject_buildrequires


%build
%pyproject_wheel

%install
%pyproject_install

%pyproject_save_files pyesorex

%files -n python%{python3_pkgversion}-%{srcname} -f %{pyproject_files}
%license LICENSE
%doc README.md
%{_bindir}/pyesorex

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.0.4-1
- New version created.
