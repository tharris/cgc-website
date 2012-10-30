package FoxPro::Parser;

use strict;
use warnings;

use feature 'state';
use IO::File;

=head1 NAME

    FoxPro::Parser - 

=head1 SYNOPSIS

    use FoxPro::Parser;
    <#code exampe#>

=head1 DESCRIPTION

Parses FoxPro text dumps

=head1 METHODS

=head2 new

Constructor

=cut

sub new {
    my $self = shift @_;
    my (%args) = @_;

    my $class = ref($self) || $self;

    return bless {%args}, $class;

}

=head2 filename

    Gets and sets the value of filename

=cut

sub filename {
    my $self = shift;
    if (@_) {
        my $f = shift;
        die "File $f doesn't exist: $!\n"  unless (-e $f);
        die "File $f cannot be read: $!\n" unless (-r $f);
        $self->{FILENAME} = $f;
    }
    return $self->{FILENAME};
}

=head2 next_record

    Fetches the next record from the input file
    
=cut
sub next_record {
    my $self = shift;
    state $fh = IO::File->new($self->filename, 'r');
    while (my $line = <$fh>) {
        chomp $line;
        $self->{NUMRECORDS}++;
        my $record = FoxPro::Record->new();
        my $index = 0;
        while ($line ne '') {
            my $value;
            if ($line =~ s/^\s*\|([^\|]*)\|\s*,?//) {
                $value = $1;
            } else {
                $line =~ s/^\s*([^,]+)\s*,?//;
                $value = $1;
            }
            $value =~ s|^/\s*/$||;
            $value =~ s/^\s+$//; 
            $record->col($index++, $value);
        }
        return $record;
    }
    $fh->close();
    return undef;
}

=head2 records_processed

    Returns the number of records processed

=cut
sub records_processed {
    my $self = shift;
    return $self->{NUMRECORDS};
}


1;

package FoxPro::Record;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless {}, $class;
    $self->{COLUMNS} = [];
    $self;
}

sub col {
    my $self = shift;
    my ($index, $value) = @_;
    if (defined($value)) {
        $self->{COLUMNS}->[$index] = $value;
    }
    return $self->{COLUMNS}->[$index];
}

sub num_columns {
    my $self = shift;
    return scalar @{ $self->{COLUMNS} };
}

sub as_tsv {
    my $self = shift;
    return join("\t", @{ $self->{COLUMNS}});
}

1;

BEGIN { $INC{'FoxPro/Record.pm'} = 1 }


=head1 EXAMPLES

=head1 CONSTANTS/ERROR CODES

=head1 ENVIRONMENT

=head1 REQUIREMENTS

=head1 FILES

F<filename>

=head1 SEE ALSO

=head1 BUGS

=head1 AUTHOR

Shiran Pasternak C<shiranpasternak@gmail.com>

=head1 COPYRIGHT

(c) 2011 Shiran Pasternak

=cut

