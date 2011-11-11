package App::Util::Import::Parser;

use Exporter 'import';

use strict;
use warnings;

our @EXPORT_OK = qw(curry_tsv_processor curry_ego_processor);

=head2 curry_tsv_processor

    Curry a TSV line processor

=cut

sub curry_tsv_processor {
    my ($input, $index, $primary_idx) = @_;
    return sub {
        my $line    = shift;
        my $fields  = [ split("\t", $line) ];
        my $primary = $fields->[$primary_idx];
        push @$input, $fields;
        $index->{$primary} ||= [];
        push @{ $index->{$primary} }, $fields;
    };
}

=head2 curry_ego_processor

    Curry a processor for a line from the vertical file format

=cut

sub curry_ego_processor {
    my ($input, $index, $primary_idx) = @_;
    my $is_header    = 1;
    my @values       = ();
    my $current_key  = undef;
    my $current_idx  = 0;
    my $primary      = undef;
    my $item         = {};
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
        if ($line =~ m/^\s*\-+\s*/) {    # Item delimiter
            $set_item_key->();
            push @$input, $item;
            $index->{$item->{$primary}} = $item;
            $item = {};
            return;
        }
        my ($key, $value) = unpack('A11 x A*', $line);    # Key: Value
        $key   =~ s/^\s+|\s+$//g;
        $value =~ s/^\s+|\s+$//g;
        if ($key ne '') {
            $set_item_key->();
            $current_key = $key;
        }
        push @values, $value;
    };
}

1;
