package FoxPro::Parser;

use strict;
use warnings;

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

    return bless {
	%args
    }, $class;

}

1;


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

