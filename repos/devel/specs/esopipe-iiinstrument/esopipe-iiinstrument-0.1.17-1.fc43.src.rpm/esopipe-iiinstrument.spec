%define instrument iiinstrument
Name: esopipe-%{instrument}
Version: 0.1.17
Release: 1%{?dist}
Summary: ESO example template instrument pipeline (text terminal execution)

Group: Applications/Scientific
License: GPLv2+
Vendor: European Southern Observatory
Packager: <usd-help@eso.org>
URL: http://www.eso.org/sci/software/pipelines

Requires: %{name}-datastatic = %{version}
Requires: %{name}-recipes = %{version}
Requires: esorex >= 3.12.3

%description
ESO data reduction pipeline for the example template instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package contains all necessary dependencies to run the pipeline on
the terminal with esorex.

%package gui
Summary: ESO example template instrument pipeline (graphical execution)
Requires: %{name}-datademo = 0.7
Requires: %{name}-datastatic = %{version}
Requires: %{name}-wkf = %{version}
%description gui
ESO data reduction pipeline for the example template instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package contains all necessary dependencies to run the pipeline
in a graphical way with Reflex.

%package all
Summary: ESO example template instrument pipeline (all packages)
Requires: %{name} = %{version}-%{release}
Requires: %{name}-gui = %{version}-%{release}
%description all
ESO data reduction pipeline for the example template instrument.
See www.eso.org/pipelines for a description of the ESO pipeline systems.
This meta-package will install all the packages related to the pipeline,
including demo data, static data and workflows.

%files
# No files to package. But these empty 'files' sections must be present to
# produce the binary RPMs.

%files gui

%files all

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 0.1.17-1
- New version created.
