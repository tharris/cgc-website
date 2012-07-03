package App::Util::Import::WormBase::Strains;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading strains and associated features from WormBase'
    );


sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $log  = join('/',$self->import_log_dir,'strains.log');
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(Strain => '*');
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
    my $lab = eval { $obj->Made_by->Laboratory };

    # Get a name for who made this.
    my $name;
    if (my $made_by = $obj->Made_by) {
	$name = $made_by->Standard_name || $made_by->Full_name || 'unknown';
    }

    my $strain_row = $strain_rs->update_or_create(
	{   name        => $obj->name         || '',
	    description => $obj->Remark       || undef,
	    outcrossed  => $obj->Outcrossed   || undef,
	    received    => $obj->CGC_received || undef,
	    made_by     => $name              || undef,
	    laboratory_id => $lab ? $self->lab_finder($lab)->id : undef,
	    males       => $obj->Males        || undef,	    
	    inbreeding_state_selfed      => $obj->Selfed      || undef,
	    inbreeding_state_isofemale   => $obj->Isofemale   || undef,
	    inbreeding_state_multifemale => $obj->Multifemale || undef,
	    inbreeding_state_inbred      => $obj->Inbred      || undef,
#	    reference_strain => $finder->($obj->Reference_strain,'Strain','name'),
	    sample_history   => $obj->Sample_history || undef,
	    mutagen_id       => $obj->Mutagen ? $self->mutagen_finder($obj->Mutagen)->id : undef,
	    genotype    => $obj->Genotype || undef,
	    species     => $self->species_finder($obj->Species || 'not specified; probably C. elegans'),
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
    
    foreach my $var ($obj->Variation) {
	my $var_row = $self->variation_finder($var->name,'wormbase_id');
	$ag_rs->update_or_create({
	    strain_id    => $strain_row->id,
	    variation_id => $var_row->id });
    }
}

1;

