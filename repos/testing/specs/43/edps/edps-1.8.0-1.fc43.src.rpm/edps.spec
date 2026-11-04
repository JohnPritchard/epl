%global srcname edps

Name: edps
Version: 1.8.0
Release: 1%{?dist}

Group:          Applications/Scientific
Summary:        EDPS data processing system

License:        GPL
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://www.eso.org/sci/software/edps.html
Source0:        https://ftp.eso.org/pub/dfs/pipelines/libraries/%{srcname}/%{srcname}-%{version}.tar.gz
%if 0%{?fedora} < 40
Patch0:         depend-pydantic1.patch
%endif

BuildArch:      noarch
BuildRequires:  pyproject-rpm-macros
BuildRequires:  python3-devel
BuildRequires:  python3-setuptools
BuildRequires:  python3-toml
BuildRequires:  python3-wheel
BuildRequires:  python3-astropy
BuildRequires:  python3-fastapi
BuildRequires:  python3-jinja2
BuildRequires:  python3-networkx
BuildRequires:  python3-pip
BuildRequires:  python3-pyyaml
BuildRequires:  python3-requests
BuildRequires:  python3-tinydb
BuildRequires:  python3-uvicorn
BuildRequires:  python3-frozendict
BuildRequires:  python3-pydantic
BuildRequires:  python3-psutil

%description
EDPS is a system to automatically organise data from ESO instruments
for pipeline processing and running the pipeline on these data.

%package -n python%{python3_pkgversion}-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{srcname}}

%description -n python%{python3_pkgversion}-%{srcname}
EDPS is a system to automatically organise data from ESO instruments
for pipeline processing and running the pipeline on these data.

%prep
%setup -q -n %{srcname}-%{version}
%if 0%{?fedora} < 40
%patch0 -p0
%endif


%generate_buildrequires
%pyproject_buildrequires

%build
%pyproject_wheel

%install
%pyproject_install

%pyproject_save_files edps

%files -n python%{python3_pkgversion}-%{srcname} -f %{pyproject_files}
%{_bindir}/edps
%{_bindir}/edps-server
%{_bindir}/edps-shutdown

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 1.8.0-1
- New version created.
