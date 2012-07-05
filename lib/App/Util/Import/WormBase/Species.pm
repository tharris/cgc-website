package App::Util::Import::WormBase::Species;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading species and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'species',
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

    my $rs  = $self->get_rs('Species');
    my $name      = $obj->name;
    my $truncated = substr($name,0,200);
    return if length $name > 250;  # kludge for some seriously broken object names
    my $row = $rs->update_or_create(
	{   name             => $truncated,
	    ncbi_taxonomy_id => $obj->NCBITaxonomyID || undef,
	},
	{ key => 'species_name_unique' }
        );    
}






1;

