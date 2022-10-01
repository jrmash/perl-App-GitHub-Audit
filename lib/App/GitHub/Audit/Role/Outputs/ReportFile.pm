package App::GitHub::Audit::Role::Outputs::ReportFile;

use v5.36;
use boolean;
use strict;
use warnings;

use Const::Fast;
use Data::Table;
use Data::Table::Excel ('tables2xlsx');
use Moose::Role;
use MooseX::AlwaysCoerce;
use MooseX::NiftyDelegation;
use MooseX::UndefTolerant;
use Path::Tiny;

use Types::DateTime ('DateTimeUTC');
use Types::Standard ('Enum', 'InstanceOf', 'Str');

const my $EXCEL_TABLE_COLORS => [9, 44, 56];

## =============================================================================
has '_report_data' => (
## =============================================================================
    is              => 'ro',
    isa             => InstanceOf['Data::Table'],
    lazy            => true,
    
    builder         => '_build__report_data',
    handles         => {
        add_report_data_column      => 'addCol',
        add_report_data_row         => 'addRow',
        get_report_data_row_count   => 'nofRow',
    },
);
sub _build__report_data($self) {
    return( Data::Table->new([], [], Data::Table::ROW_BASED) );
}

## =============================================================================
has '_report_params' => (
## =============================================================================
    is              => 'ro',
    isa             => InstanceOf['Data::Table'],
    lazy            => true,
    
    builder         => '_build__report_params',
    handles         => {
        add_report_param_row        => 'addRow',
        get_report_param_row_count  => 'nofRow',
    },
);
sub _build__report_params($self) {
    my $table = Data::Table->new( [], [], Data::Table::ROW_BASED );
    
    $table->addCol( undef, 'Param' );
    $table->addCol( undef, 'Value' );
    $table->addRow( ['Created', DateTimeUTC->assert_coerce('now')] );
    
    return( $table );
}



## =============================================================================
has 'report_format' => (
## =============================================================================
    cmd_flag        => 'report-format',
    cmd_position    => 1000,
    cmd_type        => 'option',
    documentation   => 'The format of the report to generate.',
    
    is              => 'ro',
    isa             => Enum[ 'csv', 'tsv', 'xlsx' ],
    lazy            => true,
    traits          => [ 'AppOption' ],
    
    default         => 'csv',
);

## =============================================================================
has 'report_name' => (
## =============================================================================
    cmd_flag        => 'report-name',
    cmd_position    => 1000,
    cmd_type        => 'option',
    documentation   => 'The base name of the report file to create.',
    
    is              => 'ro',
    isa             => Str,
    lazy            => true,
    traits          => [ 'AppOption', 'String' ],
    
    default         => 'github-audit',
);

## =============================================================================
=method B<write_report>

=cut
## -----------------------------------------------------------------------------
sub write_report($self) {
## =============================================================================
    my $file = join( '.', $self->report_name(), $self->report_format() );
    my $filePath = path( $file );
    
    if ($self->report_format() eq 'csv') {
        $filePath->spew( $self->_report_params()->csv(), "\n" );
        $filePath->append( $self->_report_data()->csv() );
    }
    elsif ($self->report_format() eq 'tsv') {
        $filePath->spew( $self->_report_params()->tsv(), "\n" );
        $filePath->append( $self->_report_data()->tsv() );
    }
    elsif ($self->report_format() eq 'xlsx') {
        tables2xlsx( $file, [$self->_report_params(), $self->_report_data()], undef, [$EXCEL_TABLE_COLORS, undef] );
    }
    
    return;
}

use namespace::autoclean;
1;

__END__

=pod

=head1 ABSTRACT

=head1 DESCRIPTION

=cut
