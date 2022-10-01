package App::GitHub::Audit::Role::Inputs::RepoOwner;

use v5.36;
use boolean;
use strict;
use warnings;

use Moose::Role;
use MooseX::AlwaysCoerce;
use MooseX::UndefTolerant;

use Types::Standard ('ArrayRef', 'StrMatch');

## -----------------------------------------------------------------------------
has 'orgs' => (
## -----------------------------------------------------------------------------
    cmd_flag        => 'org',
    cmd_type        => 'option',
    documentation   => 'Include resources owned by this org in the report.',
    
    is              => 'bare',
    isa             => ArrayRef [ StrMatch [qr/^[[:alnum:]-]+$/msx] ],
    lazy            => true,
    traits          => [ 'AppOption', 'Array' ],
    
    default         => sub { [] },
    handles         => {
        orgs                        => 'elements',
    },
);

## -----------------------------------------------------------------------------
has 'users' => (
## -----------------------------------------------------------------------------
    cmd_flag        => 'user',
    cmd_type        => 'option',
    documentation   => 'Include resources owned by this user in the report.',
    
    is              => 'bare',
    isa             => ArrayRef [ StrMatch [qr/^[[:alnum:]-]+$/msx] ],
    lazy            => true,
    traits          => [ 'AppOption', 'Array' ],
    
    default         => sub { [] },
    handles         => {
        users                       => 'elements',
    },
);

use namespace::autoclean;
1;

__END__

=pod

=head1 ABSTRACT

=head1 DESCRIPTION

=cut
