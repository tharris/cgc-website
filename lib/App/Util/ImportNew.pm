package App::Util::ImportNew;

use Time::HiRes qw(gettimeofday tv_interval);
use Digest::MD5;
use Moose;
use IO::File;
use FindBin qw($Bin);
use Config::General qw/ParseConfig/;
use Log::Log4perl;
use lib "$Bin/../../../lib";
use CGC::Schema;

#use Exporter 'import';

#use strict;
#use warnings;

#our @EXPORT_OK = qw();

has 'bin_path' => (
    is => 'ro',
    default => sub {
	use FindBin qw/$Bin/;
	return $Bin;
    },
    );

has 'dbic_trace_log_file' => (
    is      => 'ro',
    default => 'dbic_trace.log',
    );


has 'database_config_file' => ( 
    is      => 'rw',
    lazy_build => 1,
    );

sub _build_database_config_file {
    my $self = shift;
    return $ENV{CGC_DBIC_CONF} || $self->bin_path . '/../../../dbic.conf',
}


has 'database_config' => (
    is => 'ro',
    default => sub {
	my $self = shift;
	my $conf = $self->database_config_file;
	return +{ ParseConfig($conf) };
    }
    );

# Logging options
has 'log_dir' => (
    is => 'rw',
    lazy_build => 1,
    );

sub _build_log_dir {
    my $self = shift;
    my $dir = $ENV{CGC_LOG_DIR};
    $dir ||= $self->bin_path . '/../../../logs',
    $self->_make_dir($dir);
    return $dir;
}


has 'import_log_dir' => (
    is => 'ro',
    lazy_build => 1,
    );

sub _build_import_log_dir {
    my $self    = shift;
    my $log_dir = $self->log_dir;
    my $date    = `date +%Y-%m-%d`;
    chomp $date;
    my $import_logs = join("/",$log_dir,'import_logs',$date);
    system("mkdir -p $import_logs");
    return $import_logs;
}


has 'schema' => (
    is      => 'ro',
    lazy_build => 1,
    );

sub _build_schema {
    my $self = shift;
    my $dbconf = $self->database_config;
    my @connect_info = map { $dbconf->{'CGC::Schema'}->{connect_info} } qw/dsn user password/;
    my $schema = CGC::Schema->connect(@connect_info) or $self->log->die("Could not load the database schema");
    $schema->storage->debug(1);
    $schema->storage->debugfh(IO::File->new(join('/',
						 $self->log_dir,
						 $self->dbic_trace_log_file), 'w'));
    return $schema;
}
    

# I should break this into STDERR and STDOUT logs.
has 'log' => (
    is => 'ro',
    lazy_build => 1,
);

sub _build_log {
    my $self    = shift;    
    my $step    = $self->step;
    $step =~ s/ /_/g;
    my $log_dir = $self->log_dir;    

    # Make sure that our log dirs exist
    $self->_make_dir($log_dir);
    $self->_make_dir($log_dir . "/steps");
    $self->_make_dir($log_dir . "/steps/$step");

    my $log_config = qq(

		log4perl.rootLogger=INFO, MASTERLOG, MASTERERR, STEPLOG, STEPERR, SCREEN

                # MatchTRACE: lowest level for the STEPLOG
                log4perl.filter.MatchTRACE = Log::Log4perl::Filter::LevelRange
                log4perl.filter.MatchTRACE.LevelToMatch = TRACE
                log4perl.filter.MatchTRACE.AcceptOnMatch = true

                # MatchWARN: Exact match for warnings
                log4perl.filter.MatchWARN = Log::Log4perl::Filter::LevelMatch
                log4perl.filter.MatchWARN.LevelToMatch = WARN
                log4perl.filter.MatchWARN.AcceptOnMatch = true

                # MatchERROR: ERROR and UP
                log4perl.filter.MatchERROR = Log::Log4perl::Filter::LevelRange
                log4perl.filter.MatchERROR.LevelMin = ERROR
                log4perl.filter.MatchERROR.AcceptOnMatch = true

                # MatchINFO: INFO and UP. For SCREEN.
                log4perl.filter.MatchINFO = Log::Log4perl::Filter::LevelRange
                log4perl.filter.MatchINFO.LevelMin = INFO
                log4perl.filter.MatchINFO.AcceptOnMatch = true

                # The SCREEN
                log4perl.appender.SCREEN           = Log::Log4perl::Appender::Screen
                log4perl.appender.SCREEN.mode      = append
                log4perl.appender.SCREEN.layout    = Log::Log4perl::Layout::PatternLayout
		#log4perl.appender.SCREEN.layout.ConversionPattern=[%d %r]%K%F %L %c − %m%n
		log4perl.appender.SCREEN.layout.ConversionPattern=[%d %p]%K%m %n
#		log4perl.appender.Screen.stderr  = 0
                log4perl.appender.SCREEN.Filter   = MatchINFO
         
                # The MASTERLOG: INFO, WARN, ERROR, FATAL
		log4perl.appender.MASTERLOG=Log::Log4perl::Appender::File
		log4perl.appender.MASTERLOG.filename=$log_dir/master.log
		log4perl.appender.MASTERLOG.mode=append
		log4perl.appender.MASTERLOG.layout = Log::Log4perl::Layout::PatternLayout
		log4perl.appender.MASTERLOG.layout.ConversionPattern=[%d %p]%K%m (%M [%L])%n
                log4perl.appender.MASTERLOG.Filter   = MatchINFO


                # The MASTERERR: ERROR, FATAL
		log4perl.appender.MASTERERR=Log::Log4perl::Appender::File
		log4perl.appender.MASTERERR.filename=$log_dir/master.err
		log4perl.appender.MASTERERR.mode=append
		log4perl.appender.MASTERERR.layout = Log::Log4perl::Layout::PatternLayout
		log4perl.appender.MASTERERR.layout.ConversionPattern=[%d %p]%K%m (%M [%L])%n
                log4perl.appender.MASTERERR.Filter   = MatchERROR

                # The STEPLOG: TRACE to get everything.
		log4perl.appender.STEPLOG=Log::Log4perl::Appender::File
		log4perl.appender.STEPLOG.filename=$log_dir/steps/$step/step.log
		log4perl.appender.STEPLOG.mode=append
		log4perl.appender.STEPLOG.layout = Log::Log4perl::Layout::PatternLayout
		#log4perl.appender.STEPLOG.layout.ConversionPattern=[%d %p]%K%l − %r %m%n
		log4perl.appender.STEPLOG.layout.ConversionPattern=[%d %p]%K%m (%M [%L])%n
		#log4perl.appender.STEPLOG.layout.ConversionPattern=[%d %p]%K %n	       
                log4perl.appender.STEPLOG.Filter   = MatchTRACE

                # The STEPERR: ERROR and up
		log4perl.appender.STEPERR=Log::Log4perl::Appender::File
		log4perl.appender.STEPERR.filename=$log_dir/steps/$step/step.err
		log4perl.appender.STEPERR.mode=append
		log4perl.appender.STEPERR.layout = Log::Log4perl::Layout::PatternLayout
		#log4perl.appender.STEPERR.layout.ConversionPattern=[%d %p]%K%l − %r %m%n
		log4perl.appender.STEPERR.layout.ConversionPattern=[%d %p]%K%m (%M [%L])%n
		#log4perl.appender.STEPERR.layout.ConversionPattern=[%d %p]%K %n	       
                log4perl.appender.STEPERR.Filter   = MatchERROR
		);
    
    Log::Log4perl::Layout::PatternLayout::add_global_cspec('K',
							       sub {
								   
								   my ($layout, $message, $category, $priority, $caller_level) = @_;
								   # FATAL, ERROR, WARN, INFO, DEBUG, TRACE
								   return "    "  if $priority eq 'DEBUG';
								   return "    "  if $priority eq 'INFO';
								   return "  "  if $priority eq 'WARN';  # potential errors
								   return " !  "  if $priority eq 'ERROR'; # errors
								   return " !  "  if $priority eq 'FATAL';  # fatal errors
								   return "    ";
							   });
    
    Log::Log4perl::init(\$log_config) or die "Couldn't create the Log::Log4Perl object";
        
    my $logger = Log::Log4perl->get_logger('rootLogger');
    return $logger;	
}



sub execute {
    my $self = shift;
    my $start = [gettimeofday]; # starting time
    
    $self->log->warn('BEGIN : ' . $self->step);
    # Subclasses should implement the run() method.
    $self->run();
    
    my $end = [gettimeofday];
    my $interval = tv_interval($start,$end);
    my $time = $self->sec2human($interval);
    
    $self->log->warn('END : ' . $self->step . "; in $time");
}


sub sec2human {
    my ($self,$secs) = @_;
    my ($dd,$hh,$mm,$ss) = (gmtime $secs)[7,2,1,0];
    my $time = sprintf("%d days, %d hours, %d minutes and %d seconds",$dd,$hh,$mm,$ss);
    return $time;
}

sub _reset_dir {
    my ($self,$target) = @_;
        
    $target =~ /\S+/ or return;
    
#    $self->_remove_dir($target) or return;
    $self->_make_dir($target) or return;    
    return 1;
}

sub _remove_dir {
    my ($self,$target) = @_;

    $target =~ /\S+/ or return;
    $self->log->error("trying to remove $target directory which doesn't exist") unless -e $target;
    system ("rm -rf $target") or $self->log->warn("couldn't remove the $target directory");
    return 1;
}

sub _make_dir {
  my ($self,$target) = @_;
  
  $target =~ /\S+/ or return;
  if (-e $target) {
    return 1;
  }
  mkdir $target, 0775;
  return 1;
}




# DBIC helpers
sub find_or_create {
    my ($self,$schema, $name, $params) = @_;
    my $resultset = $schema->resultset($name);
    my $object    = $resultset->find($params);
    if (!$object) {
        $object = $resultset->new($params);
        $object->insert();
    }
    return $object;
}




1;
