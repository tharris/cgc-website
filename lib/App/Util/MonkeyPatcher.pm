package App::Util::MonkeyPatcher;

# Adapted from John Siracusa's solution @ StackOverflow:
# http://goo.gl/KxdkV

use strict;
use Exporter qw/import/;

our @EXPORT_OK = qw/add_instance_method add_class_method/;

my $counter = 1;

sub add_instance_method {
    my ($instance, $method, $code) = @_;
    my $package = ref($instance) . '::MonkeyPatch' . $counter++;
    no strict 'refs';
    @{"${package}::ISA"} = (ref($instance));
    *{"${package}::$method"} = $code;
    use strict 'refs';
    bless $_[0], $package;
}

sub add_class_method {
    my ($class, $method, $code) = @_;
    no strict 'refs';
    *{"${class}::$method"} = $code;
    use strict 'refs';
}

1;
