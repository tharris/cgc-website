#!/usr/bin/perl

use strict;
use Getopt::Long;
use FindBin qw/$Bin/;
use lib "$Bin/../../../lib";
use App::Util::Import::WormBase::Laboratories;

my ($help,$log_dir,$dbic_conf_file,$ace_host,$ace_port,$test);
GetOptions('log_dir=s'  => \$log_dir,
	   'help=s'     => \$help,
	   'ace_host=s' => \$ace_host,
	   'ace_port=s'  => \$ace_port,
	   'test=i'     => \$test,
    );

if ($help) {
    die <<END;
    
Usage: $0 [ -options ]
      
With options of:
  --log_dir         Processing log directory (default: project_src/logs)
  --dbic_conf_file  Full path including filename where your dbic config lives or ENV CGC_DBIC_CONF or dbic.conf
  --ace_host        Acedb host to query against (default: localhost)
  --ace_port        Acedb host to query against (default: 2005)
  --test            An integer. If set, the number of objects to load.

END
;
}

my $agent = App::Util::Import::WormBase::Laboratories->new();

# This causes all moose attributes to be undef if not provided on command line.
#my $agent = App::Util::Import::WormBase::Genes->new({ #log_dir              => $log_dir,
#						      database_config_file => $dbic_conf_file,
#						      ace_host             => $ace_host,
#						      ace_port             => $ace_port,
#						      test                 => $test,
#						    });
#print $agent->log_dir;
#print $agent->database_config_file;
#print $agent->ace_host;
#print $agent->ace_port;

$agent->execute();

