Name: adari
Version: 4.0.1
Release: 1%{?dist}
Group:          Applications/Scientific
Summary:        ADARI Plotting infrastructure

License:        GPL
Vendor:         European Southern Observatory
Packager:       ESO <usd-help@eso.org>
URL:            https://eso.org

Requires: python3-%{name}_core = %{version}


%description
ADARI is a set of python modules and utilities that can be used to create
reports of astronomical data.
This is a meta-package that depends on the different ADARI components.


%files
# No files to package. But these empty 'files' sections must be present to
# produce the binary RPMs.

%changelog
* Thu Mar 31 2016 ESO <usd at eso.org> 4.0.1-1
- New version created.
