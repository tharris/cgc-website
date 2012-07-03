package App::Util::Import::WormBase::Laboratories;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading laboratories and associated features from WormBase'
    );

has 'address_data' => (
    is   => 'ro',
    isa  => 'HashRef',	
    lazy => 1,
    default => sub {	
	my $self = shift;
	my $object = $self->object;
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
    );

sub street_address {
    my $self    = shift;
    my $address = $self->address_data;
    return $address->{street_address} || undef;
}

sub country {    
    my $self = shift;
    my $address = $self->address_data;
    return $address->{country} || undef;
}

sub institution {
    my $self    = shift;
    my $address = $self->address_data;
    return $address->{institution} || undef;
}


sub email {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'email addresses of the person',
		 data        => $address->{email} || undef };
    return $data;
}


sub web_page {
    my $self    = shift;
    my $address = $self->address_data;
    my $url = $address->{web_page};
    $url =~ s/HTTP\:\/\///;
    return $url || undef;
}


sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $iterator = $ace->fetch_many(Laboratory => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	last if ($test && $test == ++$c);
	$self->log->warn("Processing ($obj)...");
	$self->process_object($obj);
    }
}


sub process_object {
    my ($self,$obj) = @_;
   
    my $lab_rs  = $self->get_rs('Laboratory');

    my $rep    = $obj->Representative;
    my $head   = $rep->Standard_name || undef;
    my $first  = $rep->First_name if $rep;
    my $middle = $rep->Middle_name if $rep;
    my $last   = $rep->Last_name if $rep;

    # Address not aomized at WOrmABse: missing state, city, zip, and missing date_assigned.
    my $lab_row = $lab_rs->update_or_create(
	{   laboratory_designation   => $obj->name   || undef,
	    allele_designation       => $obj->Allele_designation || undef,
	    head                     => $head        || undef,
	    lab_head_first_name      => $first       || undef,
	    lab_head_middle_name     => $middle      || undef,
	    lab_head_last_name       => $last        || undef,
	    address1                 => $self->street_address,
	    country                  => $self->country,
	    institution              => $self->institution,
	    website                  => $self->web_page,
	},
	{ key => 'laboratory_designation_unique' }
        );

    my $l2g_rs = $self->get_rs('Laboratory2GeneClass');    
    foreach my $gen_class ($obj->Gene_classes) {
	my $gene_row = $self->gene_finder($gene_class->name);
	$l2g_rs->update_or_create({
	    laboratory_id => $lab_row->id,
	    gene_class_id => $gene_row->id });
    }

    my $l2v_rs = $self->get_rs('Laboratory2Variation');        
    foreach my $var ($obj->Alleles) {
	my $var_row = $self->variation_finder($var->name);
	$l2v_rs->update_or_create({
	    laboratory_id    => $lab_row->id,
	    variation_id => $var_row->id });
    }
}

1;

