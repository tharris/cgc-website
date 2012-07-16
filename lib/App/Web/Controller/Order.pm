package App::Web::Controller::Order;

use Moose;

BEGIN { extends 'App::Web::Controller::REST'; }

=head1 NAME

App::Web::Controller::Order - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# Yeah, I said entitify
sub entitify :Private {
	my ($row) = @_;
	return +{
        id       => $row->id,
        user     => $row->user->username,
        remark   => $row->remark,
        received => $row->date_received,
        shipped  => $row->date_shipped,
        strains  => "" . $row->app_order_contents,
    };
}

sub orders : Path("/orders") : Args(0) {
    my ($self, $c) = @_;

    my @rows = $c->model('CGC::AppOrder')->search();

    my $orders = [];
    for my $row (@rows) {
        push @$orders, entitify($row);
    }
    $c->stash->{template} = 'order/all.tt2';
    $self->status_ok($c, entity => { orders => $orders });
}

sub order :Path("/order") :Args(1) :ActionClass('REST') {}
	
sub order_GET {
	my ($self, $c, $id) = @_;
	
	my $row = $c->model('CGC::AppOrder')->single({
		id => $id
	});
	$c->stash->{template} = 'order/index.tt2';
	if (defined $row) {
		$self->status_ok($c, entity => { order => entitify($row) });
	} else {
		$self->status_not_found($c, message => "Cannot find this order");
	}
}

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
