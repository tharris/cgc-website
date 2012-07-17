package App::Web::Controller::Strain;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
		'application/json' => 'JSON',
	}
);

=head1 NAME

App::Web::Controller::Strain - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub strain : Path('/strain') : ActionClass('REST') { }

sub index : Private {
	my ($self, $c) = @_;	
	return "index";
}

sub strain_GET {
	my ($self, $c, $key) = @_;
	
	if (!$key) {
		$c->detach('index');
	}
	my $strain = $c->model('CGC::Strain')->single({ name => $key });
	$c->stash->{template} = 'strain/index.tt2';
	my $entity;
	if (defined($strain)) {


	    
	    # Get the event history for this sample.
	    my $strain_history = $self->get_history($c,'StrainEvent','strain_id',$strain->id);
	    
	    
            # Pull out some admin level fields, mainly samples and their history.
	    my $freezer_samples;

	    # All freezer samples, and history for those samples.
	    my @sample_rows = $c->model('CGC::FreezerSample')->search(
		{ strain_id => $strain->id }
		);
	    
	    foreach my $sample (@sample_rows) {
		my $freezer_history = $self->get_history($c,'FreezerSampleEvent','freezer_sample_id',$sample->id);
		my $freezer = $sample->freezer;

		# Kind of dumb. We reset this meta information each time around.
		$freezer_samples->{$freezer->name}->{id} = $freezer->id;
		$freezer_samples->{$freezer->name}->{type} = $freezer->type;
		
		push @{$freezer_samples->{$sample->freezer->name}->{samples}},
		{ sample_id   => $sample->id,		  
		  freezer_location => $sample->freezer_location,
		  vials       => $sample->vials,
		  history     => $freezer_history,
		}
	    }   

	    $entity = {
			name       => $strain->name,
			species    => $strain->species
				? $strain->species->name : 'No species',
			outcrossed => $strain->outcrossed,
			mutagen    => $strain->mutagen
				? $strain->mutagen->name : 'No mutagen',
			genotype   => $strain->genotype,
			received   => $strain->received,
			# lab_order  => $strain->lab_order,
			made_by    => $strain->made_by,
			laboratory => $strain->laboratory ? $strain->laboratory->name : 'laboratory of origin unknown',
			samples    => $freezer_samples,
		};
		$self->status_ok($c, entity => $entity);
	} else {
		$self->status_not_found($c, message => "Cannot find strain '$key'");
	}
}



sub new_strain : Path('/strain/new-strain') : ActionClass('REST') { }

sub new_strain_GET {
    my ($self,$c) = @_;

    # Get data for populating my form (or typeahead)
    my @mutagen_rows = $c->model('CGC::Mutagen')->search(
	{},
	{ columns => [ qw/name id/ ],
	});

    foreach (@mutagen_rows) {
	$c->stash->{mutagens}->{$_->name} = $_->id;
    }


    # Get data for populating my form (or typeahead)
    my @lab_rows = $c->model('CGC::Laboratory')->search(
	{},
	{ columns => [ qw/name head id/ ],
	});
    
    foreach (@lab_rows) {
	$c->stash->{labs}->{$_->name} = { id   => $_->id,
					  head => $_->head,
	}
    }
    
    # Species
    my @species_rows = $c->model('CGC::Species')->search(
	{
	    'strains.species_id' => { '!=', undef },
	},
	{
	    join     => 'strains', # join the strain table
	    select   => [ 'name', 
			  'id',],
	    group_by => [qw/strains.species_id/],
	    as       => [qw/name id/],
	}
	);
    
    foreach (@species_rows) {
	$c->stash->{species}->{$_->name} = $_->id;
    } 
    
    # No need to state explicitly but I think it's clearer to do so.
    $c->stash->{template} = 'strain/form.tt2';
    $self->status_ok($c,entity => { } );
}


sub new_strain_POST {
    my ($self,$c) = @_;    

    $c->log->warn("processing new submission");

    # Pass some messages for form processing.
    $c->stash->{event} = 'strain submitted for inclusion in the collection';

#    my $body_params = $c->req->body_parameters();

   my $params = $c->request->data;
    $c->log->warn($c->request->data->{strain_name});
    my $name = $self->_process_form($c);
    
    if ($name) {
	$c->stash->{message}  = "New strain submitted successfully.";	
	$c->detach($c->uri_for("/strain/" . $name));
    }
    
#    $self->status_ok($c, entity => $entity);
}




sub _process_form {
    my ($self,$c) = @_;
    
 
#    my $params = $c->req->body_parameters();
   my $params = $c->req->data;
    my $strain_rs = $c->model('CGC::Strain');
    
    # Does the strain already exist?  Should be part of form validation?
        
    my $strain_row = $strain_rs->find_or_create(
	{   name          => $params->{strain_name} || undef,
	    description   => $params->{remark}      || undef,
	    outcrossed    => $params->{outcrossed}  || undef,
	    made_by       => $params->{made_by}     || undef,
	    laboratory_id => $params->{laboratory}  || undef,
	    
#	    males       => $obj->Males        || undef,	    
#	    inbreeding_state_selfed      => $obj->Selfed      || undef,
#	    inbreeding_state_isofemale   => $obj->Isofemale   || undef,
#	    inbreeding_state_multifemale => $obj->Multifemale || undef,
#	    inbreeding_state_inbred      => $obj->Inbred      || undef,
##	    reference_strain => $finder->($obj->Reference_strain,'Strain','name'),
	    mutagen_id       => $params->{mutagen},
	    genotype         => $params->{genotype} || undef,
	    species_id       => $params->{species}  || undef,
	},
	{ key => 'strain_name_unique' }
        );
    
    # Add a strain event for the date it was added OR updated.
    my $event_rs   = $c->model('CGC::Event');
    my $event_row  = $event_rs->update_or_create({
	event => $c->{stash}->{event},
#	event_date => $date,
	user_id    => $c->user->id,
						 });
    
    # Create entry in the join table. Necessary?
    my $event_join_rs  = $c->model('CGC::StrainEvent');
    my $event_join_row = $event_join_rs->create({
	event_id  => $event_row->id,
	strain_id => $strain_row->id,
						});

#    $c->stash->{template} = "strain/form.tt2";

			   
=pod
	
    
    my $ag_rs = $self->get_rs('AtomizedGenotype');    
    foreach my $gene ($obj->Gene) {
	my $gene_row = $self->gene_finder($gene->name,'wormbase_id');
	$ag_rs->update_or_create({
	    strain_id => $strain_row->id,
	    gene_id   => $gene_row->id });
    }

    foreach my $trans ($obj->Transgene) {
	my $trans_row = $self->transgene_finder($trans->name);
	$ag_rs->update_or_create({
	    strain_id    => $strain_row->id,
	    transgene_id => $trans_row->id });
    }

    foreach my $rearg ($obj->Rearrangement) {
	my $rearg_row = $self->rearrangement_finder($rearg->name);
	$ag_rs->update_or_create({
	    strain_id        => $strain_row->id,
	    rearrangement_id => $rearg_row->id });
    }

    return if $obj eq 'CB4856'; # Seg faulting. Skip for now.
    return if $obj eq 'CB4858'; # Seg faulting. Skip for now.
    return if $obj eq 'N2';     # Seg faulting. Skip for now.
    return if $obj eq 'HK104';  # Seg faulting. Skip for now.
    return if $obj eq 'HK105';  # Seg faulting. Skip for now.
    foreach my $var ($obj->Variation) {
	my $var_row = $self->variation_finder($var->Public_name || $var->name);
	$ag_rs->update_or_create({
	    strain_id    => $strain_row->id,
	    variation_id => $var_row->id });
    }

=cut
    if ($strain_row) {
	return $params->{strain_name};
    } else {
	return undef;
    }

}




# Generically get the history for sample/freezer/whatever.
# Kind of bizarre that this is in REST controller, but subclasses
# inherit from us.
sub get_history {
    my ($self,$c,$model,$column,$id) = @_;
    
    my @history_rows = $c->model("CGC::" . $model)->search(
	{ $column => $id },
	{ join => [qw/event/] });
    
    my @flattened_history;
    foreach my $history (@history_rows) {
	my $event = $history->event;
	push @flattened_history,{
	    event  => $event->event,
	    date   => $event->event_date,
	    remark => $event->remark,
	};
    }
    return \@flattened_history;
}
    



=cut


=head1 AUTHORS

Shiran Pasternak and Todd Harris

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
