package App::Util::MonkeyPatcherTest;

use base qw(Test::Unit::TestCase);

use App::Util::MonkeyPatcher qw/add_method/;
use Readonly;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {
}

sub tear_down {
}

sub test_monkey_patch {
    my $self = shift;

    my $dog1 = Dog->new();
    my $dog2 = Dog->new();

    # Before monkey-patching
    $self->assert_equals("woof", $dog1->speak());
    $self->assert_equals("woof", $dog2->speak());

    add_method($dog2, speak => sub { return "yap" });

    # After monkey-patching
    $self->assert_equals("woof", $dog1->speak());
    $self->assert_equals("yap",  $dog2->speak());
}

package Dog;

sub new { bless {}, shift }
sub speak { return "woof" }

1;
