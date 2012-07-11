package App::Util::Import::WormBase::Genes;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading genes and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'gene',
    );

sub run {
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}



sub process_object {
    my ($self,$gene) = @_;

    my ($chromosome,$gmap) = $self->_get_gmap_position($gene);

    my $gene_resultset = $self->get_rs('Gene');

    my ($ref,$start,$stop,$strand) = $self->_get_genomic_position($gene);
    my ($type,$confirmed) = $self->_get_type($gene);
    
    # Create a unique key for name so that we can track dead genes.
    # Not sure if this is the best way to track wormbase data.
    my $name = $gene->Public_name || "$gene";
    if ($gene->Status eq 'Dead') {
	$name .= "-dead";
    }
    
    my $gene_row = $gene_resultset->update_or_create(
	{   wormbase_id   => $gene->name,
	    name          => $name,
	    locus_name    => $gene->CGC_name      || undef,
	    sequence_name => $gene->Sequence_name || undef,
	    chromosome    => $chromosome          || undef,
	    gmap          => $gmap                || undef,
	    pmap_start    => $start               || undef,
	    pmap_stop     => $stop                || undef,
	    strand        => $strand              || undef,
	    gene_class_id  => $gene->Gene_class ? $self->gene_class_finder($gene->Gene_class)->id : undef,
	    species_id    => $gene->Species    ? $self->species_finder($gene->Species)->id       : undef,
	    status        => $gene->Status        || undef,
	    type          => $type                || undef,
	    confirmed     => $confirmed,
	},
	{ key => 'gene_wormbase_id_unique' }
#	{ key => 'gene_name_unique' }
        );
   
    # Variations can remove more than one gene.
    my $variation_resultset = $self->get_rs('Variation');
    foreach my $variation ($gene->Allele) {
	my $var_row = $variation_resultset->update_or_create(
	    {   wormbase_id   => $variation->name,
		name          => $variation->Public_name || $variation->name || undef,
	    },
	    { key => 'variation_name_unique' }
	    );	

	my @genes     = $variation->Gene;
	my $v2gene_rs = $self->get_rs('Variation2gene');
	foreach (@genes) {
	    my $gene_row = $self->gene_finder($_->name,'wormbase_id');
	    $v2gene_rs->update_or_create(
		{ variation_id => $var_row->id,
		  gene_id      => $gene_row->id,
		});
	}	
    }
}


sub _get_type {
    my ($self,$object) = @_; 

    my $type;

    # General type: coding gene, pseudogene, or RNA
    if ($object->Corresponding_pseudogene) {
	$type = 'pseudogene';
    } elsif ($object->Corresponding_CDS) {
        $type = "protein coding";
    }
    
    unless ($type) {
	# Is this a non-coding RNA?
	if (my @transcripts = $object->Corresponding_transcript) {
	    $type = $transcripts[0]->Transcript;
	}
    }
    
    # Confirmed?
    my @cds = $object->Corresponding_CDS;
    my $confirmed = @cds ? $cds[0]->Prediction_status->name : 0;
    return ($type,$confirmed);
}


sub _get_genomic_position {
    my ($self,$obj) = @_;
    my $segments = $self->_get_segments($obj);
    if ($segments) {
	my $longest  = $self->_longest_segment($segments);
	my @pos = $self->genomic_position($longest);
	return @pos;
    } else {
	return;
    }
}


sub _get_sequences {
    my ($self,$obj) = @_;
    my %seen;
    my @sequences = grep { !$seen{$_}++} $obj->Corresponding_transcript;
    
    for my $cds ($obj->Corresponding_CDS) {
        next if defined $seen{$cds};
        my @transcripts = grep {!$seen{$cds}++} $cds->Corresponding_transcript;
	
        push (@sequences, @transcripts ? @transcripts : $cds);
    }
    return \@sequences if @sequences;
    return [$obj->Corresponding_Pseudogene];
}

sub _get_segments {
    my ($self,$obj) = @_;
    my $sequences = $self->_get_sequences($obj);

    my @segments;
    my $dbh = $self->gff_handle();

    my $species = $obj->Species;
        

    # Yuck. Still have some species specific stuff here.

    if (@$sequences and $species =~ /briggsae/) {
        if (@segments = map {$dbh->segment(CDS => "$_")} @$sequences
            or @segments = map {$dbh->segment(Pseudogene => "$_")} @$sequences) {
            return \@segments;
        }
    }
    
    if (@segments = $dbh->segment(Gene => $obj)
        or @segments = map {$dbh->segment(CDS => $_)} @$sequences
        or @segments = map { $dbh->segment(Pseudogene => $_) } $obj->Corresponding_Pseudogene # Pseudogenes (B0399.t10)
        or @segments = map { $dbh->segment(Transcript => $_) } $obj->Corresponding_Transcript # RNA transcripts (lin-4, sup-5)
    ) {
        return \@segments;
    }

    return;
}



# TODO: Logically this might reside in Model::GFF although I don't know if it is used elsewhere
# Find the longest GFF segment
sub _longest_segment {
    my ($self,$segments) = @_;
    # Not all genes are cloned and will have segments associated with them.
    my ($longest) = sort { $b->abs_end - $b->abs_start <=> $a->abs_end - $a->_abs_start}
    @$segments;
    return $longest;
}






1;

