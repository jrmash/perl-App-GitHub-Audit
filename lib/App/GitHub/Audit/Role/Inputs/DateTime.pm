package App::GitHub::Audit::Role::Inputs::DateTime;

use v5.36;
use boolean;
use strict;
use warnings;

use Moose::Role;
use MooseX::AlwaysCoerce;
use MooseX::NiftyDelegation;
use MooseX::UndefTolerant;

use Types::DateTime ('DateTimeUTC', 'Format');

## =============================================================================
=option B<--from-date> [C<Default: 1970-01-01T00:00:00Z>]

An L<ISO 8601|https://en.wikipedia.org/wiki/ISO_8601> formatted date / time
string to use as the start point for the query.

=cut
## -----------------------------------------------------------------------------
has 'from' => (
## =============================================================================
    cmd_flag        => 'from-date',
    cmd_position    => 100,
    cmd_type        => 'option',
    
    is              => 'ro',  ## Required for NiftyDelegation
    isa             => DateTimeUTC->plus_coercions( Format['ISO8601'] ),
    lazy            => true,
    traits          => [ 'AppOption', Nifty ],
    
    default         => '1970-01-01T00:00:00',
    handles         => {
        compare_from_datetime   => sub { DateTime->compare( $_[1], $_ ) },
        from_datetime_rfc822    => sub { $_->strftime('%a, %d %b %Y %H:%M:%S %Z') },
    },
);

## =============================================================================
=option B<--until-date> [C<Default: L<DateTime-E<gt>now()|DateTime/now>>]

An L<ISO 8601|https://en.wikipedia.org/wiki/ISO_8601> formatted date / time
string to use as the end point for the query.

=cut
## -----------------------------------------------------------------------------
has 'until' => (
## =============================================================================
    cmd_flag        => 'until-date',
    cmd_position    => 100,
    cmd_type        => 'option',
    
    is              => 'ro',  ## Required for NiftyDelegation
    isa             => DateTimeUTC->plus_coercions( Format['ISO8601'] ),
    lazy            => true,
    traits          => [ 'AppOption', Nifty ],
    
    default         => DateTimeUTC->assert_coerce('now')->stringify(),
    handles         => {
        compare_until_datetime  => sub { DateTime->compare( $_[1], $_ ) },
        until_datetime_rfc822   => sub { $_->strftime('%a, %d %b %Y %H:%M:%S %Z') },
    },
);

## =============================================================================
has '_datetime_parser' => (
## =============================================================================
    is              => 'bare',
    isa             => 'DateTime::Format::ISO8601',
    lazy            => true,
    
    default         => sub { DateTime::Format::ISO8601->new() },
    handles         => {
        parse_datetime              => 'parse_datetime',
    },
);

use namespace::autoclean;
1;

__END__

=pod

=head1 ABSTRACT

=head1 DESCRIPTION

=cut
