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
    my $self = shift; 
    my $ace  = $self->ace_handle;

    $|++;

    my $class = $self->class;
    my $log  = join('/',$self->import_log_dir,"$class.log");
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(ucfirst($class) => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	if ($previous{$obj}) {
	    print STDERR "Already seen $obj. Skipping...";
	    print STDERR -t STDOUT && !$ENV{EMACS} ? "\r" : "\n"; 
	    next;
	}
	last if ($test && $test == ++$c);
	$self->log->info("Processing ($obj)...");
	$self->process_object($obj);
	print OUT "$obj\n";
    }
    close OUT;
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
	    laboratory_id => $self->lab_finder($lab ? $lab : 'not specified')->id,
	    males       => $obj->Males        || undef,	    
	    inbreeding_state_selfed      => $obj->Selfed      || undef,
	    inbreeding_state_isofemale   => $obj->Isofemale   || undef,
	    inbreeding_state_multifemale => $obj->Multifemale || undef,
	    inbreeding_state_inbred      => $obj->Inbred      || undef,
#	    reference_strain => $finder->($obj->Reference_strain,'Strain','name'),
	    sample_history   => $obj->Sample_history || undef,
	    mutagen_id       => $self->mutagen_finder($obj->Mutagen ? $obj->Mutagen : 'not specified')->id,
	    genotype    => $obj->Genotype || undef,
	    species     => $self->species_finder($obj->Species || 'not specified'),
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

