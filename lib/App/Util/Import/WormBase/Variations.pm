package App::Util::Import::WormBase::Variations;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading variations and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'variation',
    );


sub run {
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}





sub process_object {
    my ($self,$obj) = @_;

    my ($chromosome,$gmap) = $self->_get_gmap_position($obj);
    my $schema = $self->schema;

    my $lab = $obj->Laboratory;
    unless ($lab) {
	$lab = eval { $obj->Person->Laboratory } ;
    }
    my ($ref,$start,$stop,$strand) 
	= $self->_get_genomic_position($obj);

    my ($protein_effects,$location_effects) = $self->features_affected($obj);
    my ($type_of_protein_change,$protein_change_position);
    foreach (keys %$protein_effects) {
	$type_of_protein_change  = $_;
	$protein_change_position = $protein_effects->{$_}->{protein_change_position};
	last;
    }

    my ($location) = map { lc($_) } join(';',keys %$location_effects);

    # Variations can remove more than one gene.
    my $variation_rs = $self->get_rs('Variation');
    my $var_row = $variation_rs->update_or_create(
	{   wormbase_id             => $obj->name,
	    name                    => eval { $obj->Public_name }  || $obj,
	    chromosome              => $chromosome                 || undef,
	    gmap                    => $gmap                       || undef,
	    pmap_start              => $start                      || undef,
	    pmap_stop               => $stop                       || undef,
	    strand                  => $strand                     || undef,
	    genic_location          => $location                   || undef,
	    variation_type          => $self->variation_type($obj) || undef,
	    type_of_dna_change      => $obj->Type_of_mutation ? lc($obj->Type_of_mutation) : undef,
	    type_of_protein_change  => $protein_effects->{type_of_protein_change}  || undef,
	    protein_change_position => $protein_effects->{protein_change_position} || undef,	    
	    is_snp                  => $obj->SNP(0)                  ? 1 : undef,
	    is_rflp                 => $obj->RFLP                    ? 1 : undef,
	    is_natural_variant      => $obj->Natural_variant(0)      ? 1 : undef,
	    is_transposon_insertion => $obj->Transposon_insertion(0) ? 1 : undef,
	    is_ko_consortium_allele => $obj->KO_consortium_allele(0) ? 1 : undef,
	    species                 => $obj->Species                 ? $self->species_finder($obj->Species)       : undef,
	    gene_class              => $obj->Gene_class              ? $self->gene_class_finder($obj->Gene_class) : undef,
#	    laboratory_id           => $self->lab_finder($lab ? $lab : 'not specified')->id,
	    laboratory_id           => $lab                          ? $self->lab_finder($lab)->id : undef,
	},
	{ key => 'variation_name_unique' }
	);	

    my $gene_rs = $schema->resultset('Gene');
    my @genes   = $obj->Gene;
    foreach my $gene (@genes) {
	my $gene_row = $gene_rs->update_or_create(
	    {   wormbase_id   => $gene->name,
	    },
	    { key => 'gene_wormbase_id_unique' }
	    );
	
	my $v2gene_rs = $schema->resultset('Variation2gene');
	$v2gene_rs->update_or_create(
	    { variation_id => $var_row->id,
	      gene_id      => $gene_row->id,
	    });
    }
}



sub variation_type {
    my ($self,$object) = @_;

    my $type;
    if ($object->Transposon_insertion(0) && !$object->Allele(0)) {
	return 'transposon insertion';
    } elsif ($object->Natural_variant(0) && !$object->SNP(0)) {
	return 'naturally occurring allele'; 
    } elsif ($object->Natural_variant(0) && $object->SNP(0)) {
	return 'SNP';
    } elsif ($object->Allele(0) && $object->Natural_variant(0)) {
	return 'naturally occurring allele';
    } elsif ($object->Allele(0) && $object->Transposon_insertion(0)) {
       return 'transposon insertion';
    } elsif ($object->SNP(0)) {
	return 'SNP';
    } else {
	return 'allele';
    }
}


# We capture which genes the variation affects later.
sub features_affected {
    my ($self,$object) = @_;
    
    foreach my $type_affected ($object->Affects) {
	next unless $type_affected eq 'Predicted_CDS';

	# We won't disambiguate when multiple CDSs are affected - just take the first.
        foreach my $item_affected ($type_affected->col) { # is a subtree
            my (%protein_effects,%location_effects);	    
	    my %associated_meta = ( # this can be used to identify protein effects
				    Missense    => [qw(position description)],
				    Silent      => [qw(description)],
				    Frameshift  => [qw(description)],
				    Nonsense    => [qw(subtype description)],
				    Splice_site => [qw(subtype description)],
		);
	    
	    # Change type is one of the keys of %associated_meta (eg, Missense)
	    # One or more per affected feature?
	    # Let's just take the first and call it good.
	    foreach my $change_type ($item_affected->col) {
		
		my @raw_change_data = $change_type->row;
		shift @raw_change_data; # first one is the type
		
		my %change_data;
		$change_data{type_of_protein_change} = lc($change_type);
		
		my $keys = $associated_meta{$change_type} || [];
		@change_data{@$keys} = map {"$_"} @raw_change_data;
		
		
		# This should be handled by change_data above. Oh well.
		# Reformat the protein_position_change
		if ($change_type eq 'Missense') {
		    my ($aa_position,$aa_change_string) = $change_type->right->row;
		    $aa_change_string =~ /(.*)\sto\s(.*)/;
		    $change_data{protein_change_position} = "$1$aa_position$2";
		}  elsif ($change_type eq 'Nonsense') {
		    # "Position" here really one of Amber, Ochre, etc.
		    my ($aa_position,$aa_change) = $change_type->right->row;
		    $change_data{protein_change_position} = "$aa_change";
		} elsif ($change_type eq 'Splice_site') {
		    my $subtype = $change_data{subtype};
		    $change_data{type_of_protein_change} = "splice site ($subtype)";
		    $change_data{protein_change_position} = $change_data{description};
		} elsif ($change_type eq 'Framshift' || $change_type eq 'Silent') {
		    $change_data{protein_change_position} = $change_data{description};
		}
		
		if ($associated_meta{$change_type}) { # only protein effects have extra data
		    $protein_effects{$change_type} = \%change_data;
		}
		else {
		    $location_effects{$change_type} = \%change_data;
		}
	    }
	    return (\%protein_effects, \%location_effects);
	}
	return ( {}, {} );  # Good god.
    }
    return ( {}, {} );
}


sub _get_genomic_position {
    my ($self,$obj) = @_;
    my @segments = $self->_segments($obj);
    if (@segments) {
	my @pos = $self->genomic_position($segments[0]);
	return \@pos;
    } else {
	return;
    }
}


sub _segments {
    my ($self,$obj) = @_;
    my $gff_handle  = $self->gff_handle;
    return [$self->gff_handle->segment($obj->class => $obj)];    
}




   
1;

