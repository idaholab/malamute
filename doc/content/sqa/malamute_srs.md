!template load file=sqa/app_srs.md.template app=MALAMUTE category=malamute

!template! item key=system-scope
!! system-scope-begin

MALAMUTE models....

!! system-scope-finish
!template-end!

!template! item key=system-purpose
!! system-purpose-begin
The purpose of MALAMUTE is to simulate....
!! system-purpose-finish
!template-end!

!template! item key=assumptions-and-dependencies
{{app}} has no constraints on hardware and software beyond those of the MOOSE framework and modules listed in their respective SRS documents, which are accessible through the links at the beginning of this document.

{{app}} provides access to a number of code objects that perform computations such as material behavior and boundary conditions. These objects each make their own physics-based assumptions, such as the units of the inputs and outputs. Those assumptions are described in the documentation for those individual objects.
!template-end!

!template! item key=user-characteristics
{{app}} has three main classes of users:

- +{{app}} Developers+: These are the core developers of {{app}}. They are responsible for designing, implementing, and maintaining the software, while following and enforcing its software development standards.
- +Developers+: These are scientists or engineers that modify or add capabilities to {{app}} for their own purposes, which may include research or extending its capabilities. They will typically have a background in structural or mechanical engineering, and in modeling and simulation techniques, but may have more limited background in code development using the C++ language. In many cases, these developers will be encouraged to contribute code back to {{app}}.
- +Analysts+: These are users that run {{app}} to run simulations, but do not develop code. The primary interface of these users with {{app}} is the input files that define their simulations. These users may interact with developers of the system requesting new features and reporting bugs found.
!template-end!

!template! item key=information-management
{{app}} as well as the core MOOSE framework in its entirety will be made publicly available on an appropriate repository hosting site. Day-to-day backups and security services will be provided by the hosting service. More information about backups of the public repository on [!ac](INL)-hosted services can be found on the following page: [sqa/github_backup.md]
!template-end!

!template! item key=policies-and-regulations
!include framework_srs.md start=policies-and-regulations-begin end=policies-and-regulations-finish
!template-end!

!template! item key=packaging
No special requirements are needed for packaging or shipping any media containing the [!ac](MOOSE) and {{app}} source code. However, some [!ac](MOOSE)-based applications that use the {{app}} code may be export-controlled, in which case all export control restrictions must be adhered to when packaging and shipping media.
!template-end!

!template item key=reliability
The regression test suite will cover at least 65% of all lines of code at all times. Known
regressions will be recorded and tracked (see [#maintainability]) to an independent and
satisfactory resolution.
