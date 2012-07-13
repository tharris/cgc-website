package App::Web::Controller::Freezer;

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
# List all freezers
#
##############################################################

sub freezers :Path('/freezers') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::Freezer')->search();
    $c->stash->{results}  = \@rows;
    $c->stash->{template} = 'freezer/all.tt2';
}


##############################################################
#
# List all samples in a given freezer
#
##############################################################

sub freezer : Path('/freezer') : ActionClass('REST') { }

sub freezer_GET  :Path('/freezer') :Args(1) {
    my ($self,$c,$id) = @_;

    $c->stash->{template} = 'freezer/index.tt2';

    # Hack! Assume that name entries do not begin with a number.
    my $column;
    if ($id =~ /^\d/) {
	$column = 'id';
    } else {
	$column = 'name';
    }

    my $row = $c->model('CGC::Freezer')->single({ $column => $id });

    my $entity;
    if ($row) {
	$entity = {
	    name       => $row->name,
	    id         => $row->id,
	    type       => $row->type,
	};

	foreach my $sample ($row->freezer_samples) {
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
		     $c->model('CGC::Freezer')->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
	    $c,
	    entity => $rows,
	    );
}





1;
