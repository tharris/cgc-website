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
    my $column;
    if ($id =~ /^\d/) {
	$column = 'id';
    } else {
	$column = 'name';
    }

#    my $row = $c->model('CGC::Gene')->single({ id => $id });
    my $row = $c->model('CGC::Gene')->single({ $column => $id });
#    my $row = $c->model('CGC::Gene')->search(
#	{ "gene.$column" => $id },
#	{ join => { 'atomized_genotypes' => 'strain' } }
#	);
    
    # Get meta information about this gene.
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
	
	my @ag = $row->atomized_genotypes;
	$entity->{ag} = \@ag if @ag;
    }
    $self->status_ok($c, entity => $entity);
}



1;
