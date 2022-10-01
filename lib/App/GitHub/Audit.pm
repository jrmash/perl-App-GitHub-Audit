package App::GitHub::Audit;

use v5.36;
use boolean;
use strict;
use warnings;

use Const::Fast;
use MooseX::App ('Color', 'Term', 'Typo', 'Version');
use MooseX::AlwaysCoerce;
use MooseX::StrictConstructor;
use MooseX::UndefTolerant;
use Net::GitHub::V3;

const my $MX_APP_SCREEN_WIDTH => 118;

## =============================================================================
## Application customizations and overrides required to suit the project vision.
## =============================================================================
$MooseX::App::Utils::SCREEN_WIDTH = $MX_APP_SCREEN_WIDTH;

app_command_name { ($_[0] =~ s/_/-/gmrs )[0] };
app_namespace( 'App::GitHub::Audit::Command' );
app_permute( true );
app_usage(join("\n",
    'gh-audit <command> [options]',
    'gh-audit <command> --help',
));

has '+help_flag' => (
    cmd_aliases => [],
);

use namespace::autoclean (-except => 'new_with_command');
__PACKAGE__->meta->make_immutable();
1;

__END__

=pod

=head1 ABSTRACT

=head1 DESCRIPTION

=cut
