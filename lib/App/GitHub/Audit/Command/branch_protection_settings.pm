package App::GitHub::Audit::Command::branch_protection_settings;

use v5.36;
use boolean;
use strict;
use warnings;

use MooseX::App::Command;
use MooseX::AlwaysCoerce;
use MooseX::StrictConstructor;
use MooseX::UndefTolerant;

extends 'App::GitHub::Audit::Command';
with (
    'App::GitHub::Audit::Role::Inputs::RepoOwner',
    'App::GitHub::Audit::Role::Outputs::ReportFile',
);

## =============================================================================
has '+report_name' => (
## =============================================================================
    default     => 'branch-protection-settings',
);

## =============================================================================
sub run ($self) {
## =============================================================================
    $self->add_report_data_column( undef, 'Owner' );
    $self->add_report_data_column( undef, 'Repository' );
    $self->add_report_data_column( undef, 'Branch' );
    $self->add_report_data_column( undef, 'Required Approvals' );

    for my $owner ($self->orgs()) {
        $self->_process_org( $owner );
    }
    for my $owner ($self->users()) {
        $self->_process_user( $owner );
    }
    $self->write_report();

    return;
}

## =============================================================================
sub _process_org($self, $owner) {
## =============================================================================
    while (my $repo = $self->next_org_repo($owner)) {
        $self->_process_repository( $repo );
    }
    return;
}

## =============================================================================
sub _process_user($self, $owner) {
## =============================================================================
    while (my $repo = $self->next_user_repo($owner)) {
        $self->_process_repository( $repo );
    }
    return;
}

## =============================================================================
sub _process_repository($self, $repo) {
## =============================================================================
    my $repoBranch = $repo->{'default_branch'};
    my $repoName   = $repo->{'name'};
    my $repoOwner  = $repo->{'owner'}->{'login'};

    printf( "Processing: %s/%s\n", $repoOwner, $repoName );

    ## Catch any errors that might come up when we try to get the branch
    ## protection settings. This may only be required due to an issue in
    ## the NET::GitHub module with the response parsing, but I will look
    ## at that later.
    eval {
        my $protection = $self->branch_protection($repoOwner, $repoName, $repoBranch);

        $self->add_report_data_row([
            $repoOwner,
            $repoName,
            $repoBranch,
            $protection->{'required_pull_request_reviews'}->{'required_approving_review_count'},
        ]);
    } or do {
        warn( "WARNING: Branch protections for '$repoName' have not been enablled.\n" );
    };
    return;
}

## =============================================================================
## App command customizations and overrides required to suit the project vision.
## =============================================================================
command_long_description(undef);
command_usage(join("\n",
    'gh-audit branch-protection-settings [long options...]',
    'gh-audit branch-protection-settings --user jrmash',
    'gh-audit branch-protection-settings --help',
));

use namespace::autoclean;
__PACKAGE__->meta->make_immutable();
1;

__END__

=pod

=head1 ABSTRACT

Generate a report containing a list of the branch protections defined for each
repository in the specified organization or user namespaces.

=head1 DESCRIPTION

    gh-audit branch-protection-settings --help
    usage:
        gh-audit branch-protection-settings [long options...]
        gh-audit branch-protection-settings --user jrmash
        gh-audit branch-protection-settings --help

    short description:
        Generate a report containing a list of pull requests merged to each repository's default branch, along with the
        list of users who approved them.

    options:
        --user           Include resources owned by this user in the report. [Multiple]
        --org            Include resources owned by this org in the report. [Multiple]
        --report-format  The format of the report to generate. [Default:"csv"; Possible values: csv, tsv, xlsx]
        --report-name    The base name of the report file to create. [Default:"branch-protection-settings"]
        --help           Prints this usage information. [Flag]

    available subcommands:
        help  Prints this usage information

=cut
