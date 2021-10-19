# Installation

## Step One: Install Conda MOOSE Environment

!style halign=left
In order to install MALAMUTE, the MOOSE developer environment must be installed. The
installation procedure depends on your operating system, so click on the MOOSE
website link below that corresponds to your operation system/platform and follow
the instructions to the conda installation step named "Cloning MOOSE". Then,
return to this page and continue with Step Two.

- [Linux and MacOS](https://mooseframework.inl.gov/getting_started/installation/conda.html)
- [Windows 10 (experimental)](https://mooseframework.inl.gov/getting_started/installation/windows10.html)

Advanced manual installation instructions for this environment are available
[via the MOOSE website](https://mooseframework.inl.gov/getting_started/installation/index.html).

If an error or other issue is experienced while using the conda environment,
please see [the MOOSE troubleshooting guide for Conda](https://mooseframework.inl.gov/help/troubleshooting.html#condaissues)

## Step Two: Clone MALAMUTE

!style halign=left
MALAMUTE is hosted on the [INL HPC GitLab server](https://hpcgitlab.hpc.inl.gov/idaholab/malamute),
and should be cloned directly from there using [git](https://git-scm.com/). As in
the MOOSE directions, it is recommended that users create a directory named
"projects" to put all of your MOOSE-related work.

To clone MALAMUTE, run the following commands in Terminal:

```bash
mkdir ~/projects
cd ~/projects
git clone git@hpcgitlab.hpc.inl.gov:idaholab/malamute.git
cd malamute
git checkout main
```

!alert! note title=MALAMUTE branches
This sequence of commands downloads MALAMUTE from the GitLab server and checks
out the "main" code branch. There are two code branches available:

- "main", which is the current most-tested version of MALAMUTE for general usage, and
- "devel", which is intended for code development (and may be more regularly broken as changes occur in MALAMUTE and MOOSE).

Developers wishing to add new features should create a new branch for submission
off of the current "devel" branch.  
!alert-end!

## Step Three: Build and Test MALAMUTE

!style halign=left
To compile MALAMUTE, first make sure that the conda MOOSE environment is activated
(*and be sure to do this any time that a new Terminal window is opened*):

```bash
conda activate moose
```

Then navigate to the MALAMUTE clone directory and download the MOOSE submodule:

```bash
cd ~/projects/malamute
git submodule update --init moose
```

!alert note
The copy of MOOSE provided with MALAMUTE has been fully tested against the current
MALAMUTE version, and is guaranteed to work with all current MALAMUTE tests.

Once all dependencies have been downloaded, MALAMUTE can be compiled and tested:

```bash
make -j8
./run_tests -j8
```

If MALAMUTE is working correctly, all active tests will pass. This indicates that
MALAMUTE is ready to be used and further developed.

## Troubleshooting

!style halign=left
If issues are experienced in installation and testing, several resources
are available:

- [MALAMUTE Issues Page](https://hpcgitlab.hpc.inl.gov/idaholab/malamute/issues)
- [MOOSE FAQ page for common MOOSE issues](https://mooseframework.inl.gov/help/faq/index.html)
- [MOOSE Discussion Forum (for non-MALAMUTE issues and questions)](https://github.com/idaholab/moose/discussions)

## What next?

!style halign=left
With installation and testing complete, proceed to [using_malamute.md].
