# VERSION

version v0.1.0

# ABSTRACT

A command-line utility using the GitHub API to generate useful reports that
can be used to audit various aspects of GitHub configuration.

# INSTALLATION

This module is only available from this repository and can be installed via
one of the following methods:

### cpanm

```
cpanm git@github.com:jrmash/perl-App-GitHub-Audit.git
```

### make

```
perl Makefile.PL
make
make test
make install
```

# COMMANDS

## pull-request-approvers

Generates a report containing pull requests merged to the default branch of
each repository, along with a list of approving users.

```perl
gh-audit pull-request-approvers --help
usage:
    gh-audit pull-request-approvers [long options...]
    gh-audit pull-request-approvers --user jrmash
    gh-audit pull-request-approvers --help

short description:
    Generate a report containing a list of pull requests merged to each repository's default branch, along with the
    list of users who approved them.

options:
    --user           Include resources owned by this user in the report. [Multiple]
    --org            Include resources owned by this org in the report. [Multiple]
    --from-date      Include pull requests merged on or after this date. [Default:"1970-01-01T00:00:00"]
    --until-date     Include pull requests merged on before this date. [Default:"2022-09-25T21:52:58"]
    --report-format  The format of the report to generate. [Default:"csv"; Possible values: csv, tsv, xlsx]
    --report-name    The base name of the report file to create. [Default:"pull-request-approvers"]
    --help           Prints this usage information. [Flag]
```

# AUTHOR

J.R. Mash

# CONTRIBUTOR

J.R. Mash <2574997+jrmash@users.noreply.github.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2022 by J.R. Mash.

This is free software, licensed under:

```
The Apache License, Version 2.0, January 2004
```
