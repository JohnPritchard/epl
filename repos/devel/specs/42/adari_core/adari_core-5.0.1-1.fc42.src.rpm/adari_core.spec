%global srcname adari_core

Name: adari_core
Version: 5.0.1
Release: 1%{?dist}

Group:          Applications/Scientific
Summary:        ADARI Plotting infrastructure (Core)

License:        GPL
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://eso.org
Source0:        https://ftp.eso.org/pub/dfs/pipelines/libraries/%{srcname}/%{srcname}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  pyproject-rpm-macros
BuildRequires:  python3-devel
BuildRequires:  python3-setuptools
BuildRequires:  python3-toml
BuildRequires:  python3-wheel

BuildRequires:  python3-requests
BuildRequires:  python3-requests-unixsocket
BuildRequires:  python3-bokeh
BuildRequires:  python3-matplotlib
BuildRequires:  python3-pydantic
BuildRequires:  python3-uvicorn
BuildRequires:  python3-fastapi
BuildRequires:  python3-astropy

%description
ADARI is a set of python modules and utilities that can be used to create
reports of astronomical data.
This package contains the core of ADARI

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{srcname}}

%description -n python%{python3_pkgversion}-%{srcname}
ADARI sofware

%prep
%setup -q -n %{srcname}-%{version}

%generate_buildrequires
%pyproject_buildrequires


%build
%pyproject_wheel

%install
%pyproject_install

%pyproject_save_files adari_core

%files -n python%{python3_pkgversion}-%{srcname} -f %{pyproject_files}
%{_bindir}/genreport

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 5.0.1-1
- New version created.
