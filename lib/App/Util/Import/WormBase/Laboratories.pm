package App::Util::Import::WormBase::Laboratories;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading laboratories and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'laboratory',
    );

sub address_data {
    my ($self,$object) = @_;
    my %address;
    
    foreach my $tag ($object->Address) {
	if ($tag =~ m/street|email|office/i) {		
	    my @data = map { $_->name } $tag->col;
	    $address{lc($tag)} = \@data;
	} else {
	    $address{lc($tag)} =  $tag->right->name;
	}
    }
    return \%address;
}    

sub street_address {
    my ($self,$object) = @_;   
    my $address = $self->address_data($object);

    if ($address->{street_address}) {
	return join("\n",@{$address->{street_address}});
    } else {
	return undef;
    }
}

sub country {    
    my ($self,$object) = @_;   
    my $address = $self->address_data($object);
    return $address->{country} || undef;
}

sub institution {
    my ($self,$object) = @_;   
    my $address = $self->address_data($object);
    return $address->{institution} || undef;
}


sub email {
    my ($self,$object) = @_;   
    my $address = $self->address_data($object);
    if ($address->{email}) {
	return join(",",@{$address->{email}});
    } else {
	return undef;
    }
}


sub web_page {
    my ($self,$object) = @_;   
    my $address = $self->address_data($object);
    my $url     = $address->{web_page};
    if ($url) { $url =~ s/HTTP\:\/\///; }
    return $url || undef;
}


sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    $|++;
    my $class = $self->class;
    my $log      = join('/',$self->import_log_dir,"$class.log");    
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log" or $self->log->die("uh oh: $!");

    my $iterator = $ace->fetch_many(ucfirst($class) => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	if ($previous{$obj}) {	
	    print STDERR "Already seen $obj. Skipping...\n";
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
  
    my $lab_rs  = $self->get_rs('Laboratory');

    my $rep    = $obj->Representative;
    my ($head,$first,$middle,$last);
    my ($address,$country,$institution,$website,$email);
    if ($rep) {
	$head    = $rep->Standard_name;
	$first   = $rep->First_name;
	$middle  = $rep->Middle_name;
	$last    = $rep->Last_name;
	$address = $self->street_address($rep);
	$country = $self->country($rep);
	$institution = $self->institution($rep);
	$website = $self->web_page($rep);
	$email   = $self->email($rep);
    }
    
    # Address not atomized at WOrmABse: missing state, city, zip, and missing date_assigned.
    my $lab_row = $lab_rs->update_or_create(
	{   name                   => $obj->name   || undef,
	    allele_designation     => $obj->Allele_designation || undef,
	    head                   => $head        || undef,
	    lab_head_first_name    => $first       || undef,
	    lab_head_middle_name   => $middle      || undef,
	    lab_head_last_name     => $last        || undef,
	    address1               => $address     || undef,
	    country                => $country     || undef,
	    institution            => $institution || undef,
	    website                => $website     || undef,
	    contact_email          => $email       || undef,
	},
	{ key => 'name_unique' }
        );

# This should already have been handled by GeneClasses.pm
    my $gc_rs = $self->get_rs('GeneClass');    
    foreach my $gene_class ($obj->Gene_classes) {
	my $row = $self->gene_class_finder($gene_class->name);
	$gc_rs->update_or_create({
	    laboratory_id => $lab_row->id,
	    name          => $gene_class->name,
				 },
				 { key => 'gene_class_name_unique' });
    }

    return if $obj eq 'CP'; # Seg faulting. Skip for now.
    return if $obj eq 'OTN'; # Seg faulting. Skip for now.
    return if $obj eq 'RW'; # Seg faulting. Skip for now.
    return if $obj eq 'VC'; # Seg faulting. Skip for now.

    # Associate variations <-> laboratories, using the laboratory_id foreign key.
    my $var_rs = $self->get_rs('Variation');
    foreach my $var ($obj->Alleles) {
	my $var_row = $self->variation_finder($var->Public_name || $var->name);
	$var_rs->update_or_create({
	    laboratory_id  => $lab_row->id,
	    id             => $var_row->id,
				  },
				  { primary => 'id' });
    }
}

1;

