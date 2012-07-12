package App::Web::Controller::GeneClass;


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
# List all gene classes tracked by the CGC
#
##############################################################

sub gene_classes :Path('/gene-classes') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::GeneClass')->search();
    $c->stash->{count} = scalar @rows;
    $c->stash->{results}  = \@rows;
    $c->stash->{template} = 'gene_class/all.tt2';
}


##############################################################
#
# A single gene_class report
#
##############################################################

sub gene_class : Path('/gene-class') : ActionClass('REST') { }

sub gene_class_GET :Path('/gene-class') :Args(1)   {
    my ($self,$c,$name) = @_;

    my $row = $c->model('CGC::GeneClass')->single({ name => $name });
    $c->stash->{template} = 'gene_class/index.tt2';

    my $entity;
    if ($row) { 
	my @genes = $row->genes;
	$entity = { 
	    name => $row->name,
	    description => $row->description,
	    genes  => \@genes,
	    laboratory => $row->laboratory,
	}
   };
    $self->status_ok($c, entity => $entity);
}



sub list : Local : ActionClass('REST') { }

sub list_GET {
	my ($self, $c) = @_;

	my $columns = $c->request->param('columns')
		? [ split(',', $c->request->param('columns')) ]
		: [ qw/name/ ];
	my $transformer = sub {
		my $row = shift;
		return [ map { $row->get_column($_) } @$columns ];
	};
	my $select = exists $c->request->parameters->{distinct}
		? { select => { distinct => $columns }, as => $columns }
		: { columns => $columns };
	my $rows = [ map { $transformer->($_) }
		     $c->model('CGC::GeneClass')->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
	    $c,
	    entity => $rows,
	    );
}





1;
