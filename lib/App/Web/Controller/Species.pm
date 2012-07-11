package App::Web::Controller::Species;

use strict;
use warnings;
use parent 'App::Web::Controller';

##############################################################
#
# List all species (with strains at the CGC)
#
##############################################################

sub species :Path('/species') :Args(0)   {
    my ($self,$c) = @_;

    my $page = $c->request->param('page') || 2;
    my $rows = $c->request->param('view') || 10;

#    my $rs = $c->model('CGC::Species')->search(
#	{
#	    'strains.species_id' => { '!=', undef },
#	},
#	{
#	    join => 'strains', # join the strain table
#	}
#	);

    my @species = $c->model('CGC::Species')->search(
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
    
    
#    my @results = $rs->all();

    $c->stash->{results}  = \@species;
#    $c->stash->{pager}    =  $rs->pager();
    $c->stash->{template} = 'species/index.tt2';
}


##############################################################
#
# List all strains for a given species. Should be paginated.
#
##############################################################

sub species_report :Path('/species') :Args(1)   {
    my ($self,$c,$species_id) = @_;

    my $page = $c->request->param('page') || 2;
    my $rows = $c->request->param('view') || 10;

    my @rows = $c->model('CGC::Strain')->search(
	{
	    'species.id' => $species_id,
	},
	{
	    join     => 'species', # join the strain table
#	    group_by => [qw/strains.species_id/],
	}
	);
    
    # These results should be paged.
#    my @results = $rs->all();
    if (@rows) {
	$c->stash->{species} = $rows[0]->species->name;
    }

    $c->stash->{results}  = \@rows;
#    $c->stash->{pager}    =  $rs->pager();
    $c->stash->{template} = 'species/report.tt2';
}




1;
