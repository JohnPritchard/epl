%define instrument xshoo
Name: esopipe-%{instrument}
Version: 3.8.3
Release: 1%{?dist}
Summary: ESO XSHOOTER instrument pipeline (text terminal execution)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines

Requires: %{name}-datastatic = %{version}
Requires: %{name}-recipes = %{version}
Requires: esorex >= 3.13

%description
ESO data reduction pipeline for the XSHOOTER instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package contains all necessary dependencies to run the pipeline on
the terminal with esorex.

%package gui
Summary: ESO XSHOOTER instrument pipeline (graphical execution)
Requires: %{name}-datademo = 1.3
Requires: %{name}-datastatic = %{version}
Requires: %{name}-wkf = %{version}
%description gui
ESO data reduction pipeline for the XSHOOTER instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package contains all necessary dependencies to run the pipeline
in a graphical way with Reflex.

%package all
Summary: ESO XSHOOTER instrument pipeline (all packages)
Requires: %{name} = %{version}-%{release}
Requires: %{name}-gui = %{version}-%{release}
%description all
ESO data reduction pipeline for the XSHOOTER instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package will install all the packages related to the pipeline,
including demo data, static data and workflows.

%files
# No files to package. But these empty 'files' sections must be present to
# produce the binary RPMs.

%files gui

%files all

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 3.8.3-1
- New version created.
