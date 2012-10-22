package App::Web::Controller::Order;

use Moose;
use DateTime;

BEGIN { extends 'App::Web::Controller::REST'; }

=head1 NAME

App::Web::Controller::Order - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin :Auto {
	my ($self, $c) = @_;
	$c->stash(model => 'AppOrder', default_model_columns => [
        { col => 'name',          name => 'Name' },
        { col => 'genotype',      name => 'Genotype' },
        { col => 'species_id',    name => 'Species' },
        { col => 'laboratory_id', name => 'Laboratory' },
        { col => 'description',   name => 'Description' },
    ]);
}

sub orders : Path("/orders") : Args(0) {
    my ($self, $c) = @_;

    my $search_params = {};
    if (grep { $_ eq 'pending' } $c->request->query_keywords) {
        $search_params->{date_shipped} = undef;
    } elsif (grep { $_ eq 'new' } $c->request->query_keywords) {
        $search_params->{date_received} = { '>=' => \'DATE_SUB(CURDATE(),INTERVAL 7 DAY)' }
    }
    my @rows = $c->model('CGC::AppOrder')->search($search_params);

    my $orders = [];
    for my $row (@rows) {
        push @$orders, $row->flatten;
    }
    $c->stash->{template} = 'order/all.tt2';
    $self->status_ok($c, entity => { orders => $orders });
}

sub order :Path("/order") :ActionClass('REST') {}
	
sub order_GET {
	my ($self, $c, $id) = @_;
	
	if (defined($id)) {
		my $row = $c->model('CGC::AppOrder')->single({
			id => $id
		});
		$c->stash->{template} = 'order/index.tt2';
		if (defined $row) {
			$self->status_ok($c, entity => { order => $row->flatten });
		} else {
			$self->status_not_found($c, message => "Cannot find this order");
		}
	} else {
		$c->stash->{template} = 'order/form.tt2';
	}
}

sub order_POST {
	my ($self, $c) = @_;
	
	$c->stash->{template} = 'order/form.tt2';
	if (!$c->user) {
		return $self->status_bad_request($c,
			message => "Action requires authentication");
	}
	my $post_data = $c->req->data || $c->req->body_parameters;
	
	if (!$post_data->{confirm} || $post_data->{confirm} ne 'true') {
		return $self->status_bad_request($c, message => "Unconfirmed order");
	} else {
		my $cart = $c->user->app_cart;
		if (!$cart || scalar $cart->app_cart_contents == 0) {
			return $self->status_bad_request($c,
				message => "Your cart is empty");
		}
		my $order = $self->place_order($c, $cart);
		$cart->delete();
		$cart->delete_related('app_cart_contents');
		$c->log->debug("Created order " . $order->id);
		$self->status_ok($c, entity => { order => $order->flatten });
	}
}

sub place_order :Private {
	my ($self, $c, $cart) = @_;
	my $order = $c->model('CGC::AppOrder')->create({
		user_id => $cart->user_id,
		remark  => $cart->remark,
		date_received => DateTime->now
	});
	
	for my $item ($cart->app_cart_contents) {
		$order->create_related('app_order_contents', { strain => $item->strain });
	}
	return $order;
}

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
