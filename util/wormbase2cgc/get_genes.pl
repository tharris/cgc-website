#!/usr/bin/perl

use Ace;
use strict;


my $db = Ace->connect(-host => 'localhost',-port=>'2005');
my @genes = $db->fetch(Gene => '*');

my $version = $db->version;
open OUT,">$version-wormbase_genes.txt";
foreach my $gene (@genes) {
    my $name = $gene->Public_name;
    my $chrom = get_chromosome($gene);
    print OUT join("\t",$gene,$name,$chrom),"\n";
}



sub get_chromosome {    
    my $object = shift;
    my $class  = $object->class;
    
    my ($chromosome,$position,$error,$method);
    
    # CDSs and Sequence are only interpolated                                                                   
    # AD: no... only Sequence... (that's what the models suggests)                                              
    #  if ($class eq 'CDS' || $class eq 'Sequence') {                                                           
    if ($class eq 'Sequence' || $class eq 'Variation') {
        my $imp = eval {$object->Interpolated_map_position};
        if ($imp) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';

            # Fetch the interpolated map position if it exists...                                               
            # if (my $m = $object->get('Interpolated_map_position')) {                                          
            if (my $m = eval {$object->get('Interpolated_map_position') }) {
                #my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;                
                my ($chromosome,$position) = $m->right->row;
                return ($chromosome,$position) if $chromosome;
            }
            elsif (my $l = $object->Gene) {
#		return $self->_get_interpolated_position($l);
            }
        }
        elsif ($object->class eq 'Sequence') {
            #my ($chromosome,$position,$error) = $obj->Interpolated_map_position(1)->row;                       
            my $chromosome = $object->get(Interpolated_map_position=>1);
            my $position   = $object->get(Interpolated_map_position=>2);
            return ($chromosome,$position) if $chromosome;
	} else {
            # Try fetching from the gene                                                                        
            if (my $gene    = $object->Gene) {
                $chromosome = $gene->get(Map=>1);
                $position   = $gene->get(Map=>3);
                $method     = 'interpolated';
            }
	}
    } else {
        ($chromosome,undef,$position,undef,$error) = eval{$object->Map(1)->row};
        # TH: Can't conclude that this is experimentally determined. Model used inconsistently.                 
        #  $method = 'experimentally determined' if $chromosome;                                                
        $method = '';
    }
    
    # Nothing yet? Trying fetching interpolated position.                                                       
    unless ($chromosome) {
        #      if ($object->Interpolated_map_position) {                                                        
        if ($class eq 'Sequence' && $object->Interpolated_map_position) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';
        }
    }
    
    my $label;
    if ($position) {
        $label= sprintf("$chromosome:%2.2f +/- %2.3f cM",$position,$error || 0);
    }
    else {
        $label = $chromosome;
    }
    
    return $chromosome;
    
#    return {
#        description => "the genetic position of the $class:$object",
#        data        => {
#	    chromosome => $chromosome && "$chromosome",
#            position   => $position   && "$position",
#            error      => $error      && "$error",
#            formatted  => $label      && "$label",
#            method     => $method     && "$method",
#        }
#    };
}
