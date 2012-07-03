package App::Util::Import::WormBase::GeneClasses;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading gene_classes and associated features from WormBase'
    );

sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $log  = join('/',$self->import_log_dir,'gene_classes.log');
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(Gene_class => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	if ($previous{$obj}) {
	    print STDERR "Already seen $obj. Skipping...";
	    print STDERR -t STDOUT && !$ENV{EMACS} ? "\r" : "\n"; 
	    next;
	}
	last if ($test && $test == ++$c);
	$self->log->warn("Processing ($obj)...");
	$self->process_object($obj);
	print OUT "$obj\n";
    }
    close OUT;
}


sub process_object {
    my ($self,$obj) = @_;
   
    my $rs  = $self->get_rs('GeneClass');
    my $row = $rs->update_or_create(
	{   name          => $obj->name        || undef,
	    description   => $obj->Description || undef,
	    designating_laboratory_id   => $self->lab_finder($obj->Designating_laboratory || 'not specified')->id,
	},
	{ key => 'gene_class_name_unique' }
        );
}

1;

