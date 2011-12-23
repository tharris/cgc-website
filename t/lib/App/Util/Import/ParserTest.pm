package App::Util::Import::ParserTest;

use base qw(Test::Unit::TestCase);

use App::Util::Import::Parser;
use Readonly;

Readonly my @EGO_INPUT => split("\n", <<EGO);
     This file created on  08/30/11
     ======================================================
       Strain: VC1705
      Species: Caenorhabditis elegans
     Genotype: ehbp-1(ok2140) V/nT1[qIs51](IV;V).
  Description: F25B3.1. Homozygous lethal/sterile deletion chromosome
               balanced by GFP-marked translocation. Heterozygotes are WT
               with pharyngeal GFP signal, and segregate WT GFP, arrested
               nT1[qIs51] aneuploids, and non-GFP ok2140 homozygotes (late
               larval or sterile adult arrest). Homozygous nT1[qIs51]
               inviable. Pick WT GFP and check for correct segregation of
               progeny to maintain. External left primer:
               GCTGGCAGCTGACTGATACA. External right primer:
               AACTTCTCACCCGTTGGATG. Internal left primer:
               AACCTACCGAGAGCGTGAGA. Internal right primer:
               GCTTTCCGTGAATTTGGTGT. Internal WT amplicon: 3312 bp.
               Deletion size: 1369 bp. Deletion left flank:
               AGGAACATCGAAAATCGAAAAAAAAATTCG. Deletion right flank:
               TACATAACTGAACATTTCCTACTACCATAT. This strain was provided by
               the C. elegans Reverse Genetics Core Facility at the
               University of British Columbia, which is part of the
               international C. elegans Gene Knockout Consortium, which
               should be acknowledged in any publications resulting from
               its use.  URL: http://www.celeganskoconsortium.omrf.org.
      Mutagen: EMS
   Outcrossed: x1
    Reference:
      Made by: Lucy Liu
     Received: 09/30/09 from Moerman D, C. elegans Reverse Genetics Core,
               Vancouver, BC, Canada
               --------------------
       Strain: STRAIN2
      Species: Caenorhabditis elegans
     Genotype: Another genotype
  Description: Yup. Another description, this one's short
      Mutagen: EMS
   Outcrossed: x1
    Reference: hi
      Made by: Cameron Diaz
     Received: Another date
               --------------------
       Strain: MT2547
      Species: Caenorhabditis elegans
     Genotype: ced-4(n1162)III.
  Description: Cells that normally die survive.   [3/02: A mutation that
               was not reported (nucleotide 1251 C-> T causing codon 80
               ->ochre) was found by Tak Hung.  It turns out the mutation
               was misannotated in the original paper (Development, 1992,
               116:309). Bob Horvitz also confirmed the discovery.
      Mutagen:
   Outcrossed: x
    Reference: CGC #870   Ellis HM;Horvitz HR
               Genetic control of programmed cell death in the nematode C.
               elegans.
               Cell 44: 817-829 1986
      Made by: Chand Desai
     Received: 05/01/85 from Horvitz B, Massachusetts Institute of
               Technology, Cambridge, MA
               --------------------
EGO

Readonly my $EGO_FIXTURE1 => {
    strain   => 'VC1705',
    species  => 'Caenorhabditis elegans',
    genotype => 'ehbp-1(ok2140) V/nT1[qIs51](IV;V).',
    description =>
        qq{F25B3.1. Homozygous lethal/sterile deletion chromosome balanced by GFP-marked translocation. Heterozygotes are WT with pharyngeal GFP signal, and segregate WT GFP, arrested nT1[qIs51] aneuploids, and non-GFP ok2140 homozygotes (late larval or sterile adult arrest). Homozygous nT1[qIs51] inviable. Pick WT GFP and check for correct segregation of progeny to maintain. External left primer: GCTGGCAGCTGACTGATACA. External right primer: AACTTCTCACCCGTTGGATG. Internal left primer: AACCTACCGAGAGCGTGAGA. Internal right primer: GCTTTCCGTGAATTTGGTGT. Internal WT amplicon: 3312 bp. Deletion size: 1369 bp. Deletion left flank: AGGAACATCGAAAATCGAAAAAAAAATTCG. Deletion right flank: TACATAACTGAACATTTCCTACTACCATAT. This strain was provided by the C. elegans Reverse Genetics Core Facility at the University of British Columbia, which is part of the international C. elegans Gene Knockout Consortium, which should be acknowledged in any publications resulting from its use.  URL: http://www.celeganskoconsortium.omrf.org.},
    mutagen    => 'EMS',
    outcrossed => 'x1',
    reference  => undef,
    made_by    => 'Lucy Liu',
    received =>
        qq{09/30/09 from Moerman D, C. elegans Reverse Genetics Core, Vancouver, BC, Canada}
};

Readonly my $EGO_FIXTURE2 => {
    strain   => 'MT2547',
    species  => 'Caenorhabditis elegans',
    genotype => 'ced-4(n1162)III.',
    description =>
        qq{Cells that normally die survive.   [3/02: A mutation that was not reported (nucleotide 1251 C-> T causing codon 80 ->ochre) was found by Tak Hung.  It turns out the mutation was misannotated in the original paper (Development, 1992, 116:309). Bob Horvitz also confirmed the discovery.},
    mutagen    => undef,
    outcrossed => 'x',
    reference =>
        qq{CGC #870   Ellis HM;Horvitz HR Genetic control of programmed cell death in the nematode C. elegans. Cell 44: 817-829 1986},
    made_by => 'Chand Desai',
    received =>
        '05/01/85 from Horvitz B, Massachusetts Institute of Technology, Cambridge, MA',
};

my ($input, $index);

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {
    $input = [];
    $index = {};
}

sub tear_down {

}

sub test_tsv_processor {
    my $self = shift;

    my $primary_index = 1;    # Second column
    my $processor
        = App::Util::Import::Parser::curry_tsv_processor($input, $index,
        $primary_index, [qw/col1 col2 col3/]);
    $processor->("a\tb\tc");
    $processor->("d\te\tf");
    $processor->("g\tb\th");

    my $prototype = $input->[0];
    $self->assert($prototype->col1(),
        "Record was not monkey-patched with col1().");
    $self->assert($prototype->col2(),
        "Record was not monkey-patched with col2().");
    $self->assert($prototype->col3(),
        "Record was not monkey-patched with col3().");

    my $cloner = sub {
        my (@cols) = @_;
        my $record = $prototype->new();
        $record->col1 = $cols[0];
        $record->col2 = $cols[1];
        $record->col3 = $cols[2];
        return $record;
    };
    my $recs = [ $cloner->(qw/a b c/), $cloner->(qw/d e f/),
        $cloner->(qw/g b h/) ];

    $self->assert_deep_equals($recs, $input);
    $self->assert_deep_equals(
        { b => [ $recs->[0], $recs->[2] ], e => [ $recs->[1] ] }, $index);
}

sub test_ego_processor {
    my $self          = shift;
    my $primary_index = 0;                         # First field
    my $fields        = [ keys %$EGO_FIXTURE1 ];
    my $processor
        = App::Util::Import::Parser::curry_ego_processor($input, $index,
        $primary_index, $fields);

    for (@EGO_INPUT) {
        $processor->($_);
    }

    my $result = $input->[0];
    $self->assert_equals($EGO_FIXTURE1->{strain},   $result->strain());
    $self->assert_equals($EGO_FIXTURE1->{species},  $result->species());
    $self->assert_equals($EGO_FIXTURE1->{genotype}, $result->genotype());
    $self->assert_equals($EGO_FIXTURE1->{mutagen},  $result->mutagen());
    $self->assert_equals($EGO_FIXTURE1->{made_by},  $result->made_by());
    $self->assert_equals($EGO_FIXTURE1->{description},
        $result->description());
    $self->assert_equals($EGO_FIXTURE1->{received},   $result->received());
    $self->assert_equals($EGO_FIXTURE1->{reference},  $result->reference());
    $self->assert_equals($EGO_FIXTURE1->{outcrossed}, $result->outcrossed());

    $self->assert_deep_equals($result, $index->{$EGO_FIXTURE1->{strain}});

}

sub test_ego_processor_2 {
    my $self          = shift;
    my $primary_index = 0;                         # First field
    my $fields        = [ keys %$EGO_FIXTURE2 ];
    my $processor
        = App::Util::Import::Parser::curry_ego_processor($input, $index,
        $primary_index, $fields);

    for (@EGO_INPUT) {
        $processor->($_);
    }
	

    my $result = $input->[2];
    $self->assert_equals($EGO_FIXTURE2->{strain},   $result->strain());
    $self->assert_equals($EGO_FIXTURE2->{species},  $result->species());
    $self->assert_equals($EGO_FIXTURE2->{genotype}, $result->genotype());
    $self->assert_null($EGO_FIXTURE2->{mutagen});
    $self->assert_equals($EGO_FIXTURE2->{made_by},  $result->made_by());
    $self->assert_equals($EGO_FIXTURE2->{description},
        $result->description());
    $self->assert_equals($EGO_FIXTURE2->{received},   $result->received());
    $self->assert_equals($EGO_FIXTURE2->{reference},  $result->reference());
    $self->assert_equals($EGO_FIXTURE2->{outcrossed}, $result->outcrossed());

    $self->assert_deep_equals($result, $index->{$EGO_FIXTURE2->{strain}});
}

sub test_parse_lab_name {
    my $self    = shift;
    my $package = App::Util::Import::Parser::_record_class(
        [   qw(
                updated    flag       code       allele     name
                country    location   namelocat  annfeepd   commercial)
        ]
    );

    # Straightforward case
    $self->assert_lab_data(
        {   country   => 'USA',
            namelocat => 'Boisvenue RJ, Eli Lilly Co., Greenfield, IN'
        },
        {   head        => 'Boisvenue RJ',
            city        => 'Greenfield',
            institution => 'Eli Lilly Co.',
            state       => 'IN'
        }
    );

    # No city or state
    $self->assert_lab_data(
        {   country   => 'Japan',
            namelocat => 'Dehm P, Medical University of South Carolina'
        },
        {   head        => 'Dehm P',
            institution => 'Medical University of South Carolina'
        }
    );

    # No city
    $self->assert_lab_data(
        {   country   => 'USA',
            namelocat => 'Sayre R, Plant Protection Institute, MD'
        },
        {   head        => 'Sayre R',
            institution => 'Plant Protection Institute',
            state       => 'MD',
        }
    );

    # No city and state, but have country
    $self->assert_lab_data(
        {   country   => 'Japan',
            namelocat => 'Sadaie Y, National Institute of Genetics, Japan'
        },
        {   head        => 'Sadaie Y',
            institution => 'National Institute of Genetics',
        }
    );
}

sub assert_lab_data {
    my ($self, $input, $expected) = @_;

    my $package = App::Util::Import::Parser::_record_class(
        [   qw(
                updated    flag       code       allele     name
                country    location   namelocat  annfeepd   commercial)
        ]
    );
    my $laboratory = $package->new();
    $laboratory->country   = $input->{country};
    $laboratory->namelocat = $input->{namelocat};

    my $data = App::Util::Import::Parser::parse_lab_name($laboratory);

    for my $field (qw/head institution city state/) {
        if (!defined($expected->{$field})) {
            $self->assert_null($data->{$field}, "$field should be undefined");
        } else {
            $self->assert_equals($expected->{$field}, $data->{$field});
        }
    }
}

1;
