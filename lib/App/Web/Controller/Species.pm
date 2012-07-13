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

    $c->log->warn("stsh key: $id");
    $c->stash->{template} = 'species/index.tt2';

    # Hack! Assume that name entries do not begin with a number.
    my $column;
    if ($id =~ /^\d/) {
	$column = 'species.id';
    } else {
	$column = 'species.name';
    }

    my @rows = $c->model('CGC::Strain')->search(
	{
	    $column => $id,
	},
	{
	    join     => 'species', # join the strain table
#	    group_by => [qw/strains.species_id/],
	}
	);
    
    if (@rows) {
	$c->stash->{species} = $rows[0]->species->name;
    }

    $c->stash->{results}  = \@rows;
    my $entity;
    if (@rows) { 
	$entity = { 
	    rows => \@rows,
	}
    };
    $self->status_ok($c, entity => $entity);

#    my $entity;
#    if (defined($row)) {
#	$entity = {
#	    name       => $row->name,
#	    id         => $row->id,
#	    genotype   => $row->genotype,
#	    description=> $row->description,
#	};
#    }
#    $self->status_ok($c, entity => $entity);
}



=pod



#    $c->stash->{pager}    =  $rs->pager();
    $c->stash->{template} = 'species/report.tt2';
}


=cut



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
		     $c->model('CGC::Species')->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
	    $c,
	    entity => $rows,
	    );
}





1;
