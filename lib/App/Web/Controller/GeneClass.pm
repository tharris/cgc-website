package App::Web::Controller::GeneClass;

use Moose;

BEGIN { extends 'App::Web::Controller::REST'; }

##############################################################
#
# List all gene classes tracked by the CGC
#
##############################################################

sub gene_classes :Path('/geneclasses') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::GeneClass')->search();
    $c->stash->{count}    = scalar @rows;
    $c->stash->{results}  = \@rows;
    $c->stash->{template} = 'gene_class/all.tt2';
}


##############################################################
#
# A single gene_class report
#
##############################################################

sub gene_class : Path('/geneclass') : ActionClass('REST') { }

sub gene_class_GET :Path('/gene-class') :Args(1)   {
    my ($self,$c,$name) = @_;

    my $row = $c->model('CGC::GeneClass')->single({ name => $name });
    $c->stash->{template} = 'gene_class/index.tt2';

    my $entity;
    if ($row) { 
	my @genes   = $row->genes;
	$entity = { 
	    name           => $row->name,
	    description    => $row->description,
	    genes          => \@genes,
	    laboratory     => $row->laboratory,
	}
   };
    $self->status_ok($c, entity => $entity);
}



1;
