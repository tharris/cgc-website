package App::Web::Controller::Gene;

use Moose;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
	}
);

##############################################################
#
# List all genes
#
##############################################################

# Not yet implemented. Does it really make sense to provide this?
#sub genes :Path('/gene') :Args(0)   {
#    my ($self,$c) = @_;
#
#    my @rows = $c->model('CGC::Gene')->search();
#    $c->stash->{results}  = \@rows;
#    $c->stash->{template} = 'freezer/all.tt2';
#}


##############################################################
#
# List all strains associated with a specific gene
#
##############################################################

sub gene : Path('/gene') : ActionClass('REST') { }

sub gene_GET  :Path('/gene') :Args(1) {
    my ($self,$c,$id) = @_;

    $c->stash->{template} = 'gene/index.tt2';

    # Hack! Assume that name entries do not begin with a number.
#    my $column;
#    if ($id =~ /^\d/) {
#	$column = 'id';
#    } else {
#	$column = 'name';
#    }

#    my $row = $c->model('CGC::Gene')->single({ id => $id });
    my $row = $c->model('CGC::Gene')->single({ id => $id });
    
    # Get some meta information about this gene.
    my $entity;
    if ($row) {
	$entity = {
	    name       => $row->name,
	    id         => $row->id,
	    species    => $row->species->name,
	    chromosome => $row->chromosome,
	    gmap       => $row->gmap,
	    pmap_start => $row->pmap_start,
	    pmap_stop  => $row->pmap_stop,
	    strand     => $row->strand,
	    locus      => $row->locus_name,
	    sequence   => $row->sequence_name,
	    type       => $row->type,
	};
	
	my @strains = $row->atomized_genotypes;
	$self->log->warn(@strains);

    }
    
=pod

	my @strains = $c->model('CGC::AtomizedGenotype')->search(
	    {
		'gene_id' => $row->id,
	    },
	    {
		join     => 'strain', # join the strain table
#	    group_by => [qw/strains.species_id/],
	    }
	    );

	

	foreach my $strain ($row->freezer_samples) {
	    push @{$entity->{samples}},{ id => $sample->id,
					 genotype => $sample->strain->genotype,
					 strain   => $sample->strain->name,
					 location => $sample->freezer_location,
					 sample_count => $sample->sample_count,
					 date_first_frozen => 'pending',
					 date_last_thawed  => 'pending',
	    }
	}	
    }

=cut

    $self->status_ok($c, entity => $entity);
}



1;
