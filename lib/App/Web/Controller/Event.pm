package App::Web::Controller::Event;

use Readonly;
use DateTime;

use base 'App::Web::Controller::REST';

Readonly my %EVENT_TYPES => (
	order => { class => 'AppOrder' },
	
);

=head1 NAME

App::Web::Controller::Event - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub begin :Auto {
	my ($self, $c) = @_;
	$c->stash(model => 'Event', default_model_columns => [
        { col => 'id',         name => 'ID' },
        { col => 'event',      name => 'Description' },
        { col => 'event_date', name => 'Date'},
    ]);
}

sub index :ActionClass('REST') {}

sub index_GET {
    my ($self, $c, $id) = @_;
	return if (not defined $id);
	my $event = $c->model('CGC::Event')->single({ id => $id });
    if (!$event) {
        return $self->status_not_found($c, message => 'Event not found');
    }
	return $self->status_ok($c, entity => {
		event => {
			id   => $event->id,
			desc => $event->event,
			date => $event->event_date . "",
			user => $event->user->username
		}
	});
}

sub index_PUT {
	my ($self, $c) = @_;
	
	my ($model, $object_rs, $target_object, @missing);
	my $data = $c->req->data || $c->req->body_parameters;
	for my $required_param (qw/desc type object_id/) {
		push @missing, $required_param if (!defined($data->{$required_param}));
	}
if (!$c->user) { $c->authenticate({username => "shiran", password => 'chaco'}); }
	if (!$c->user) {
		return $self->status_bad_request($c, message => 'Not authorized');
	}
	if (scalar @missing) {
		return $self->status_bad_request($c,
			message => "Missing required parameters ["
				 . join(' ', @missing) ."]");
	}
	if (!exists $EVENT_TYPES{$data->{type}}) {
		return $self->status_bad_request($c, message => 'Invalid event type');
	}
	$model = $c->model('CGC');
	$object_rs = $model->resultset($EVENT_TYPES{$data->{type}}->{class});
	$target_object = $object_rs->find($data->{object_id});
	if (!defined($target_object)) {
		return $self->status_bad_request($c,
			message => 'Cannot find target object');
	}
	my $event = $c->model('CGC::Event')->create({
		event      => $data->{desc},
		event_date => DateTime->now,
		user_id       => $c->user->id
	});
	my $subevent = $event->create_related("$data->{type}_event",
		{ order_id => $data->{object_id} });
	return $self->status_ok($c, entity => {
		event => {
			id   => $event->id,
			desc => $event->event,
			date => $event->event_date . "",
			order => $subevent->order->id
		}
	});
}

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
