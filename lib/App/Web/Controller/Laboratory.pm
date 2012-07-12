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
    
    my $row;
    if ($query) {
	($row) = $c->model('CGC::Laboratory')->search({
	    -or => [
		 name                 => $query,
		 allele_designation   => $query,
		 head                 => $query,
		],
						      });
    }
    
    my $entity;
    if (defined($row)) {
	my (@strains)      = $row->strains;
	my (@gene_classes) = $row->gene_classes;
	$entity = {
	    name       => $row->name,
	    head       => $row->head,
	    allele_designation => $row->allele_designation,
	    address1   => $row->address1,
	    state      => $row->state,
	    country    => $row->country,
	    institution=> $row->institution,
	    commerical => $row->commercial,
	    website    => $row->website,
	    gene_classes => \@gene_classes,
	    strains    => \@strains,
	};
    }
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
		     $c->model('CGC::Laboratory')->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
	    $c,
	    entity => $rows,
	    );
}





__PACKAGE__->meta->make_immutable;

1;