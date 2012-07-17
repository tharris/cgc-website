package App::Web::Controller::Variation;

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
# List all variations
#
##############################################################

# Not yet implemented. Does it really make sense to provide this?
#sub genes :Path('/variations') :Args(0)   {
#    my ($self,$c) = @_;
#
#    my @rows = $c->model('CGC::Variation')->search();
#    $c->stash->{results}  = \@rows;
#    $c->stash->{template} = 'variation/all.tt2';
#}


##############################################################
#
# List all strains associated with a specific variation
#
##############################################################


sub index : Private {
    my ($self, $c) = @_;    
    return "index";
}

sub variation : Path('/variation') : ActionClass('REST') { }

sub variation_GET  :Path('/variation') :Args(1) {
    my ($self,$c,$key) = @_;
    
    if (!$key) {
        $c->detach('index');
    }
    
    $c->stash->{template} = 'variation/index.tt2';
    
    # Hack! Assume that name entries do not begin with a number.
    my $entity = {};
    my $column = ($key =~ /^\d+$/) ? 'id' : 'name';
    
    my $row = $c->model('CGC::Variation')->single({ $column => $key });
    
    # Get meta information about this gene.
    if ($row) {
	my @genes;
	my @v2g = $row->variation2genes;
	foreach (@v2g) {
	    push @genes,$_->gene;
	}
	
	$entity = {
	    name       => $row->name,
	    id         => $row->id,
	    species    => $row->species->name,
	    chromosome => $row->chromosome,
	    gmap       => $row->gmap,
	    pmap_start => $row->pmap_start,
	    pmap_stop  => $row->pmap_stop,
	    strand     => $row->strand,
	    genes      => \@genes,
	    type       => $row->variation_type,
	};
	
	my @ag = $row->atomized_genotypes;
	$entity->{ag} = \@ag if @ag;
    }
    $self->status_ok($c, entity => $entity);
}



1;
