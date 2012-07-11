package App::Util::Import::CGC::Parser;

use Moose;
extends 'App::Util::Import';


use App::Util::MonkeyPatcher qw/add_class_method/;

has 'ego_fieldname_length' => (
    is => 'ro',
    default => 13,
    );

has 'states' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [qw/AL AK AZ AR CA CO CT DE FL GA
    HI ID IL IN IA KS KY LA ME MD
    MA MI MN MS MO MT NE NV NH NJ
    NM NY NC ND OH OK OR PA RI SC
    SD TN TX UT VT VA WA WV WI WY/] }
    );


has 'strain' => (
    is => 'ro',
    default => sub {
	my %data = {
	    fields => [
		qw(
                name     species    genotype   description mutagen
                outcrossed reference  made_by    received
                )
		],
		primary   => 'name',
		type      => 'vertical',
		extension => 'ego',
	};
	return \%data;
    }
    );
    




    my $class_counter = 1;

=head2 curry_tsv_processor

    Curry a TSV line processor

=cut

sub curry_tsv_processor {
    my ($self, $input, $index, $primary_idx, $columns) = @_;
    my $package = _record_class($columns);
    return sub {
        my $line    = shift;
        my @fields  = split("\t", $line);
        my $primary = $fields[$primary_idx];
        my $record  = $package->new();

        # Populate record
        for (my $i = 0; $i < @$columns; $i++) {
            $record->{ $columns->[$i] } = $fields[$i];
        }

        push @$input, $record;
        $index->{$primary} ||= [];
        push @{ $index->{$primary} }, $record;
    };
}

=head2 curry_ego_processor

    Curry a processor for a line from the vertical file format

=cut

sub curry_ego_processor {
    my ($input, $index, $primary_idx, $fields) = @_;
    my $is_header   = 1;
    my @values      = ();
    my $current_key = undef;
    my $current_idx = 0;
    my $primary     = undef;
    my $package     = _record_class($fields);
    my $item        = $package->new();
    my $set_item_key = sub {    # Set key-value in $item, reset state.

        if (defined $current_key) {
            $item->{$current_key} = join(' ', @values) || undef;
            if ($primary_idx == $current_idx) {
                $primary = $current_key;
            }
            $current_idx++;
            $current_key = undef;
            @values      = ();
        }
    };
    return sub {
        my $line = shift;
        if ($is_header) {
            if ($line =~ m/\s*\=+\s*$/) {
                $is_header = 0;
            }
            return;
        }
        if ($line =~ m/^\s*\-+\s*$/) {    # Item delimiter
            $set_item_key->();
            push @$input, $item;
            $index->{ $item->{$primary} } = $item;
            $item = $package->new();
            return;
        }
        my ($key, $value)
            = unpack("A$EGO_FIELDNAME_LENGTH x A*", $line);    # Key: Value
        $key   =~ s/^\s+|\s+$//g;
        $value =~ s/^\s+|\s+$//g;
        if ($key ne '') {
            $key = lc $key;
            $key =~ s/ /_/g;
            $set_item_key->();
            $current_key = $key;
        }
        push @values, $value;
    };
}

sub parse_lab_name {
    my ($laboratory) = @_;
    my @fields = split(/,\s?/, $laboratory->namelocat);
    my $labdata
        = { map { $_ => shift @fields } qw/head institution city state/ };
    if (defined($labdata->{city})) {

        if (!defined($labdata->{state}) && _is_state($labdata->{city})) {
            $labdata->{state} = $labdata->{city};
            $labdata->{city}  = undef;
        } elsif ($labdata->{city} eq $laboratory->country) {
            $labdata->{city} = undef;
        }
    }
    return $labdata;
}

sub _is_state {
    my ($place) = @_;
    return scalar grep({ $_ eq $place } @STATES) == 1;
}

sub _record_class {
    my ($fields) = @_;
    my $package = "App::Util::Import::Record" . $class_counter++;
    no strict 'refs';
    @{"${package}::ISA"} = ('App::Util::Import::Record');
    use strict 'refs';
    for my $field (@$fields) {
        my $method = lc $field;
        $method =~ s/ /_/;
        add_class_method(
            $package,
            $method => sub  : lvalue {
                shift->{$field};
            }
        );
    }
    return $package;
}

package App::Util::Import::Record;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless {}, $class;
    $self;
}

1;
