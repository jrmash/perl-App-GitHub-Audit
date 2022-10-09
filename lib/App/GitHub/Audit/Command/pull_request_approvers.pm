package App::GitHub::Audit::Command::pull_request_approvers;

use v5.36;
use boolean;
use strict;
use warnings;

use MooseX::App::Command;
use MooseX::AlwaysCoerce;
use MooseX::NiftyDelegation;
use MooseX::StrictConstructor;
use MooseX::UndefTolerant;

use Types::Standard ('Enum');

extends 'App::GitHub::Audit::Command';
with (
    'App::GitHub::Audit::Role::Inputs::DateTime',
    'App::GitHub::Audit::Role::Inputs::RepoOwner',
    'App::GitHub::Audit::Role::Outputs::ReportFile',
);

## =============================================================================
has '+from' => (
## =============================================================================
    documentation   => 'Include pull requests merged on or after this date.',
);

## =============================================================================
has '+until' => (
## =============================================================================
    documentation   => 'Include pull requests merged on before this date.',
);

## =============================================================================
has '+report_name' => (
## =============================================================================
    default     => 'pull-request-approvers',
);

## =============================================================================
sub run ($self) {
## =============================================================================
    $self->add_report_data_column( undef, 'Merged Date');
    $self->add_report_data_column( undef, 'Owner' );
    $self->add_report_data_column( undef, 'Repository' );
    $self->add_report_data_column( undef, 'PR Creator' );
    $self->add_report_data_column( undef, 'PR Link' );
    $self->add_report_data_column( undef, 'PR Approvers' );
    $self->add_report_param_row( ['From Date', $self->from_datetime_rfc822] );
    $self->add_report_param_row( ['To Date', $self->until_datetime_rfc822] );

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

    my @prQuery = ($repoOwner, $repoName, {
        base      => $repoBranch,
        sort      => 'update', direction => 'desc',
        state     => 'closed',
    });

    while (my $pr = $self->next_pull(@prQuery)) {
        ## Closed pull requests without this field in output
        ## were not merged to master, so skip them.
        next unless ($pr->{'merged_at'}); 

        ## Merged pull requests with a merged date/time that
        ## falls outside the from/until times are skipped.
        my $prCreator = $pr->{'user'}->{'login'};
        my $prMergedAt = $self->parse_datetime( $pr->{'merged_at'} );
        my $prUrl = $pr->{'html_url'};

        if ($self->compare_from_datetime($prMergedAt) < 0) {
            # printf( "Skipping ... %s\n", $prUrl );
            next;
        }
        if ($self->compare_until_datetime($prMergedAt) > 0) {
            # printf( "Skipping ... %s\n", $prUrl );
            next;
        }

        ## 
        my @prApprovers = ();
        my @prReviewQuery = ( $repoOwner, $repoName, $pr->{'number'} );
        my @reportRow = ($prMergedAt, $repoOwner, $repoName, $prCreator, $prUrl);

        while ( my $r = $self->next_review(@prReviewQuery) ) {
            unless ($r->{'state'} eq 'APPROVED') {
                # printf( "Skipping ... %s\n", $r->{'html_url'} );
                next;
            }
            push( @prApprovers, $r->{'user'}->{'login'} );
        }

        $self->add_report_data_row( [@reportRow, join(', ', @prApprovers)] );
    }
    return;
}

## =============================================================================
## App command customizations and overrides required to suit the project vision.
## =============================================================================
command_long_description(undef);
command_usage(join("\n",
    'gh-audit pull-request-approvers [long options...]',
    'gh-audit pull-request-approvers --user jrmash',
    'gh-audit pull-request-approvers --help',
));

use namespace::autoclean;
__PACKAGE__->meta->make_immutable();
1;

__END__

=pod

=head1 ABSTRACT

Generate a report containing a list of pull requests merged to each repository's
default branch, along with the list of users who approved them.

=head1 DESCRIPTION

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

    available subcommands:
        help  Prints this usage information

=cut
