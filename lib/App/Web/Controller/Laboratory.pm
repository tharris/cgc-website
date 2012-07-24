package App::Web::Controller::Laboratory;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
	}
);


=head1 NAME

App::Web::Controller::Laboratory - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head1 laboratories()

Return a list of ResultSet rows for all laboratories.
Note: these are not flattened and will probably choke
if requested as JSON.

=cut

sub laboratories :Path('/laboratories') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::Laboratory')->search(
	{
	    'gene_classes.laboratory_id' => { '!=', undef },
	},
	{
	    join     => 'gene_classes',
	    group_by => [qw/gene_classes.laboratory_id/],
	    order_by => [qw/name/],
	}
	);
    
    $c->stash->{results}  = \@rows;
    $c->stash->{template} = 'laboratory/all.tt2';
}



sub laboratory : Path('/laboratory') : ActionClass('REST') { }

sub laboratory_GET :Path('/laboratory') :Args(1)   {
    my ($self, $c, $query) = @_;
    $c->stash->{template} = 'laboratory/index.tt2';

    # Edit could be url parameter instead of a specific target.
    my $entity = $self->_get_laboratory($c,$query);
    $self->status_ok($c, entity => $entity);
}


sub _get_laboratory {
    my ($self,$c,$query) = @_;
    my ($row) = $c->model('CGC::Laboratory')->search({
	-or => [
	     name                 => $query,
#		 allele_designation   => $query,
	     head                 => $query,
	    ],
	    
#	    -or => [
#		 name                 => $query,
#		 allele_designation   => $query,
#		 head                 => $query,
#		],
						     });

    my $entity;
    if (defined($row)) {
	my (@strains)      = $row->strains;
	my (@alleles)      = $row->variations;
	my (@gene_classes) = $row->gene_classes;
	$entity = {
	    name           => $row->name,
	    head           => $row->head,
	    first_name     => $row->lab_head_first_name,
	    last_name      => $row->lab_head_last_name,
	    allele_designation => $row->allele_designation,
	    address1       => $row->address1,
	    state          => $row->state,
	    country        => $row->country,
	    institution    => $row->institution,
	    commerical     => $row->commercial,
	    website        => $row->website,
	    gene_classes   => \@gene_classes,
	    strains        => \@strains,
	    alleles        => \@alleles,
	};
    }
    return $entity;
}


sub new_laboratory : Path('/laboratory/new-laboratory') : ActionClass('REST') { }

sub new_laboratory_GET  {
    my ($self, $c) = @_;
    $c->stash->{template} = 'laboratory/form.tt2';
    $c->assert_any_user_roles( qw/admin manager employee/ ); # users cannot add labs.
    my $entity = { action => 'add' };
    $self->status_ok($c, entity => $entity);
}

sub edit_laboratory : Path('/laboratory/edit-laboratory') : ActionClass('REST') { }

sub edit_laboratory_GET :Path('/laboratory/edit-laboratory') :Args(1)   {
    my ($self, $c, $query) = @_;
    $c->stash->{template} = 'laboratory/form.tt2';
    $c->assert_any_user_roles( qw/admin manager employee/ ); # users cannot edit labs.
    my $entity = $self->_get_laboratory($c,$query);
    $entity->{action} = 'edit';    
    $self->status_ok($c, entity => $entity);
}

sub laboratory_PUT {
    my ($self, $c) = @_;
}


sub laboratory_POST {
    my ($self, $c) = @_;
   
    my $params = $c->req->parameters;
    my $action = $params->{action};

    # Pass some messages for form processing.
    if ($action eq 'add') {
	$c->log->warn("processing new laboratory submission");
	$c->stash->{event} = 'new laboratory added to the CGC';
    } else {
	$c->log->warn("editing a laboratory...");
	$c->stash->{event} = 'laboratory edited';
    }

    my $name = $self->_process_form($c);

    if ($name) {
	if ($action eq 'add') {
	    $c->stash->{message} = "New laboratory added to the CGC registry.";
	    $c->detach($c->uri_for("/laboratory/" . $name));
	} else {
	    $c->stash->{message} = "Laboratory information updated.";
	    $c->detach($c->uri_for("/laboratory/" . $name));
	}
    }
    #    $self->status_ok($c, entity => $entity);
}


sub _process_form : Private {
    my ($self, $c) = @_;

    my $params    = $c->req->parameters;
    my $rs = $c->model('CGC::Laboratory');
    $c->log->debug("Params: ", Dumper($params));

    my $lab_row = $rs->update_or_create(
        {   name               => $params->{name} || undef,
            allele_designation => $params->{allele_dsignation}      || undef,
            head               => $params->{first_name} . ' ' . $params->{last_name},
	    lab_head_first_name         => $params->{first_name},
	    lab_head_last_name          => $params->{last_name},
	    institution        => $params->{institution} || undef,
	    website            => $params->{website}     || undef,
	    is_commercial      => $params->{is_commercial} || undef,
            address1           => $params->{address1},
            state              => $params->{state},
	    country            => $params->{country},
	    # Need to add this to model.
#	    postal_code        => $params->{postal_code},
        },
        { key => 'laboratory_name_unique' }
    );

    # Add an event for the date the lab was added OR updated.
    my $event_rs  = $c->model('CGC::Event');
    my $event_row = $event_rs->update_or_create(
        {   event => $c->{stash}->{event},
            # event_date => $date,
            user_id => $c->user->id,
        }
    );

    # Create entry in the join table. Necessary?
    my $event_join_rs  = $c->model('CGC::LaboratoryEvent');
    my $event_join_row = $event_join_rs->create(
        {   event_id      => $event_row->id,
            laboratory_id => $lab_row->id,
        }
    );

    #    $c->stash->{template} = "strain/form.tt2";


    # Now, need to process gene_classes;
    my @gene_classes = split(',',$params->{gene_classes});    
    my $geneclass_rs = $c->model('CGC::GeneClass');
    foreach my $gene_class (@gene_classes) {
	$gene_class =~ s/\s//g;
	$geneclass_rs->update_or_create({
	    name            => $gene_class,
	    laboratory_id   => $lab_row->id });    
    }

    if ($lab_row) {
        return $params->{name};
    } else {
        return undef;
    }
    
}












__PACKAGE__->meta->make_immutable;

1;
