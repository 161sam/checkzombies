%global version_override 1.0.0
%global release_override 1
%global unitdir /usr/lib/systemd/system

Name:           checkzombies
Version:        %{?version_override:%{version_override}}%{!?version_override:1.0.0}
Release:        %{?release_override:%{release_override}}%{!?release_override:1}
Summary:        Zombie Process Manager (find & cleanup zombie processes)
License:        MIT
URL:            https://github.com/161sam/checkzombies
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

Requires:       bash
Requires:       procps-ng

%description
checkzombies finds zombie processes, shows PID/PPID/service info, and offers
safe cleanup flows with standardized signal escalation.

%prep
%setup -q

%install
install -D -m 0755 bin/checkzombies %{buildroot}%{_bindir}/checkzombies
install -D -m 0644 man/man1/checkzombies.1 %{buildroot}%{_mandir}/man1/checkzombies.1
install -D -m 0644 packaging/systemd/checkzombies.service %{buildroot}%{unitdir}/checkzombies.service
install -D -m 0644 packaging/systemd/checkzombies-auto.service %{buildroot}%{unitdir}/checkzombies-auto.service
install -D -m 0644 packaging/systemd/checkzombies.timer %{buildroot}%{unitdir}/checkzombies.timer
install -D -m 0644 README.md %{buildroot}%{_docdir}/%{name}/README.md
install -D -m 0644 LICENSE %{buildroot}%{_docdir}/%{name}/LICENSE

%files
%license %{_docdir}/%{name}/LICENSE
%doc %{_docdir}/%{name}/README.md
%{_bindir}/checkzombies
%{_mandir}/man1/checkzombies.1*
%{unitdir}/checkzombies.service
%{unitdir}/checkzombies-auto.service
%{unitdir}/checkzombies.timer

%changelog
* Sun Jan 11 2026 CheckZombies Maintainers <maintainers@checkzombies.local> - 1.0.0-1
- Initial RPM packaging for v1.0.0
