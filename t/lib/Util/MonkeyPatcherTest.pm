package App::Util::MonkeyPatcherTest;

use base qw(Test::Unit::TestCase);

use App::Util::MonkeyPatcher qw/add_instance_method add_class_method/;
use Readonly;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {
}

sub tear_down {
}

sub test_monkey_patch_instance {
    my $self = shift;

    my $dog1 = Dog->new();
    my $dog2 = Dog->new();

    # Before monkey-patching
    $self->assert_equals("woof", $dog1->speak());
    $self->assert_equals("woof", $dog2->speak());

    add_instance_method($dog2, speak => sub { return "yap" });

    # After monkey-patching
    $self->assert_equals("woof", $dog1->speak());
    $self->assert_equals("yap",  $dog2->speak());
}

sub test_monkey_patch_class {
    my $self = shift;

    $self->assert(!"Dog"->can("bark"));

    add_class_method("Dog", bark => sub { });
    $self->assert("Dog"->can("bark"),
        "Class was not monkey-patched with bark()");
}

package Dog;

sub new { bless {}, shift }
sub speak { return "woof" }

1;
