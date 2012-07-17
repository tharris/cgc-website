package App::Web::Controller::Species;


use Moose;

#use parent 'App::Web::Controller';


BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
	}
);

##############################################################
#
# List all species (with strains at the CGC)
#
##############################################################

sub species_list :Path('/species-list') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::Species')->search(
	{
	    'strains.species_id' => { '!=', undef },
	},
	{
	    join     => 'strains', # join the strain table
	    select   => [ 'name', 
			  'id',
			  'ncbi_taxonomy_id',
			  { count => 'strains.species_id' } ],
	    group_by => [qw/strains.species_id/],
	    as       => [qw/name id ncbi_taxonomy_id strain_count/],
	}
	);
       
    $c->stash->{results}  = \@rows;
    $c->stash->{template} = 'species/all.tt2';
}


##############################################################
#
# List all strains for a given species.
#
##############################################################

sub species : Path('/species') : ActionClass('REST') { }

sub species_GET :Path('/species') :Args(1)   {
    my ($self,$c,$id) = @_;
    $c->stash->{template} = 'species/index.tt2';

    # Hack! Assume that name entries do not begin with a number.
    
    # If returing DBIx::Class objects
    my $entity = {};
    my $column;
    if ($id =~ /^\d/) {
	$column = 'id';
    } else {
	$column = 'name';
    }
    
    if ($id) {
	my $row = $c->model('CGC::Species')->find(
	    {
		$column => $id,
	    },
	    );
	
	# If we found rows, get meta information about the species from the first row.
	
	if ($row) {	    
	    my @strains = $row->strains;
	    $c->stash->{species} = $row;
	    $c->stash->{strains} = \@strains; 	
	    
	    $self->status_ok($c, entity => $entity);
	} else {
	    $self->status_not_found($c, message => "Cannot find species");
	}
    } else {
	$self->status_ok($c, entity => { } );
    }
}
        

=pod

    # If flattening
sub species_GET :Path('/species') :Args(1)   {
    my ($self,$c,$id) = @_;
    $c->stash->{template} = 'species/index.tt2';
    
    my $column;
    if ($id =~ /^\d/) {
		$column = 'species.id';
    } else {
		$column = 'species.name';
    }

    if ($id) {
	
    my @rows = $c->model('CGC::Strain')->search(
	    {
	    $column => $id,
	},
	{
	    join     => 'species', # join the strain table
##		group_by => [qw/strains.species_id/],
	}
	);
    
	
	my $entity = {};
    if (@rows) {
	    $entity->{species}->{name} = $rows[0]->species->name;
	    $entity->{species}->{id}   = $rows[0]->species->id;
	    $entity->{species}->{ncbi} = $rows[0]->species->ncbi_taxonomy_id;
	    
	    foreach my $row (@rows) {
		push @{$entity->{strains}},{
		    name        => $row->name,
		    id          => $row->id,
		    genotype    => $row->genotype,
		    description => $row->description
		};
    }

	    $self->status_ok($c, entity => $entity);
	} else {
		$self->status_not_found($c, message => "Cannot find species");
	}
    }  else {	
	$self->status_ok($c, entity => { } );
}
}

=cut


1;
