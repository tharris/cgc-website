package App::Util::Import::WormBase::Strains;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading strains and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'strain',
    );


sub run {
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}



sub process_object {
    my ($self,$obj) = @_;
   
    my $strain_rs  = $self->get_rs('Strain');
    
    # Get a name for who made this.  This should maybe be a foreign key (no; prob not, most peeps not in system).
    my ($made_by,$lab);
    if (my $o = $obj->Made_by) {
	$made_by = $o->Standard_name || $o->Full_name || $o || 'unknown';
	$lab = $o->Laboratory;
    }

    my $strain_row = $strain_rs->update_or_create(
	{   name        => $obj->name         || '',
	    description => $obj->Remark       || undef,
	    outcrossed  => $obj->Outcrossed   || undef,
	    received    => $obj->CGC_received || undef,
	    made_by     => $made_by           || undef,
	    laboratory_id => $lab ? $self->lab_finder($lab)->id : undef,
	    males       => $obj->Males        || undef,	    
	    inbreeding_state_selfed      => $obj->Selfed      || undef,
	    inbreeding_state_isofemale   => $obj->Isofemale   || undef,
	    inbreeding_state_multifemale => $obj->Multifemale || undef,
	    inbreeding_state_inbred      => $obj->Inbred      || undef,
#	    reference_strain => $finder->($obj->Reference_strain,'Strain','name'),
	    sample_history   => $obj->Sample_history || undef,
	    mutagen_id       => $obj->Mutagen ? $self->mutagen_finder($obj->Mutagen)->id : undef,
	    genotype         => $obj->Genotype || undef,
	    species_id       => $obj->Species ? $self->species_finder($obj->Species) : undef,
	},
	{ key => 'strain_name_unique' }
        );

    my $ag_rs = $self->get_rs('AtomizedGenotype');    
    foreach my $gene ($obj->Gene) {
	my $gene_row = $self->gene_finder($gene->name,'wormbase_id');
	$ag_rs->update_or_create({
	    strain_id => $strain_row->id,
	    gene_id   => $gene_row->id });
    }

    foreach my $trans ($obj->Transgene) {
	my $trans_row = $self->transgene_finder($trans->name);
	$ag_rs->update_or_create({
	    strain_id    => $strain_row->id,
	    transgene_id => $trans_row->id });
    }

    foreach my $rearg ($obj->Rearrangement) {
	my $rearg_row = $self->rearrangement_finder($rearg->name);
	$ag_rs->update_or_create({
	    strain_id        => $strain_row->id,
	    rearrangement_id => $rearg_row->id });
    }

    return if $obj eq 'CB4856'; # Seg faulting. Skip for now.
    return if $obj eq 'CB4858'; # Seg faulting. Skip for now.
    return if $obj eq 'N2';     # Seg faulting. Skip for now.
    return if $obj eq 'HK104';  # Seg faulting. Skip for now.
    return if $obj eq 'HK105';  # Seg faulting. Skip for now.
    foreach my $var ($obj->Variation) {
	my $var_row = $self->variation_finder($var->Public_name || $var->name);
	$ag_rs->update_or_create({
	    strain_id    => $strain_row->id,
	    variation_id => $var_row->id });
    }
}

1;

