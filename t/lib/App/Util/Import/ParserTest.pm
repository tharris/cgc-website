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
EGO

Readonly my $EGO_FIXTURE => {
    Strain   => 'VC1705',
    Species  => 'Caenorhabditis elegans',
    Genotype => 'ehbp-1(ok2140) V/nT1[qIs51](IV;V).',
    Description =>
        qq{F25B3.1. Homozygous lethal/sterile deletion chromosome balanced by GFP-marked translocation. Heterozygotes are WT with pharyngeal GFP signal, and segregate WT GFP, arrested nT1[qIs51] aneuploids, and non-GFP ok2140 homozygotes (late larval or sterile adult arrest). Homozygous nT1[qIs51] inviable. Pick WT GFP and check for correct segregation of progeny to maintain. External left primer: GCTGGCAGCTGACTGATACA. External right primer: AACTTCTCACCCGTTGGATG. Internal left primer: AACCTACCGAGAGCGTGAGA. Internal right primer: GCTTTCCGTGAATTTGGTGT. Internal WT amplicon: 3312 bp. Deletion size: 1369 bp. Deletion left flank: AGGAACATCGAAAATCGAAAAAAAAATTCG. Deletion right flank: TACATAACTGAACATTTCCTACTACCATAT. This strain was provided by the C. elegans Reverse Genetics Core Facility at the University of British Columbia, which is part of the international C. elegans Gene Knockout Consortium, which should be acknowledged in any publications resulting from its use.  URL: http://www.celeganskoconsortium.omrf.org.},
    Mutagen    => 'EMS',
    Outcrossed => 'x1',
    Reference  => undef,
    'Made by'    => 'Lucy Liu',
    Received =>
        qq{09/30/09 from Moerman D, C. elegans Reverse Genetics Core, Vancouver, BC, Canada}
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
    my $primary_index = 0;                        # First field
    my $fields        = [ keys %$EGO_FIXTURE ];
    my $processor
        = App::Util::Import::Parser::curry_ego_processor($input, $index,
        $primary_index, $fields);

    for (@EGO_INPUT) {
        $processor->($_);
    }

    my $result = $input->[0];
    $self->assert_equals($EGO_FIXTURE->{Strain},      $result->strain());
    $self->assert_equals($EGO_FIXTURE->{Species},     $result->species());
    $self->assert_equals($EGO_FIXTURE->{Genotype},    $result->genotype());
    $self->assert_equals($EGO_FIXTURE->{Mutagen},     $result->mutagen());
    $self->assert_equals($EGO_FIXTURE->{'Made by'},     $result->made_by());
    $self->assert_equals($EGO_FIXTURE->{Description}, $result->description());
    $self->assert_equals($EGO_FIXTURE->{Received},    $result->received());
    $self->assert_equals($EGO_FIXTURE->{Reference},   $result->reference());
    $self->assert_equals($EGO_FIXTURE->{Outcrossed},  $result->outcrossed());

    $self->assert_deep_equals({ 'VC1705' => $result }, $index);
}

1;
