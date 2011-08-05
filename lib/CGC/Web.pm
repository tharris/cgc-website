package CGC::Web;


use Moose;
use namespace::autoclean;
use Hash::Merge;
use Catalyst qw/
	  ConfigLoader
	  Cache
	  Static::Simple
	  Unicode
	  ErrorCatcher
	  Authentication
	  Authorization::Roles  
	  Session
	  Session::PerUser
	  Session::Store::DBI
 	  Session::State::Cookie
          StackTrace
	  Scheduler
           /;
extends 'Catalyst';
our $VERSION = '0.01';

use Catalyst::Log::Log4perl; 
use HTTP::Status qw(:constants :is status_message);


##################################################
#
#   What type of installation are we?
#   
#   The startup script should set an environment variable
#   for installation type; otherwise it defaults to staging.
#
##################################################
my $installation_type = $ENV{WORMBASE_INSTALLATION_TYPE} || 'staging';


__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(__PACKAGE__->path_to( 'conf', 'log4perl', "$installation_type.conf")->stringify)
    );


__PACKAGE__->config->{'Plugin::Session'} = {
              expires   => 3600,
	      dbi_dbh   => 'Schema', 
	      dbi_table => 'sessions',
	      dbi_id_field => 'session_id',
	      dbi_data_field => 'session_data',
	      dbi_expires_field => 'expires',
};

 
__PACKAGE__->config->{authentication} =
{
    default_realm => 'default',
    realms => {
	default => {
	    credential => {
		class => 'Password',
		password_field => 'password',
		#password_type => 'clear'
		password_type => 'salted_hash',
		password_salt_len => 4,
	    },
	    store => {
		class => 'DBIx::Class',
		user_model => 'Schema::User',
		role_relation => 'roles',
		role_field => 'role',
		#  ignore_fields_in_find => [ 'remote_name' ],
		#  use_userdata_from_session => 0,
	    }
	},
	openid => {
	    credential => {
		class => 'OpenID',
		ua_class => 'LWP::UserAgent',
		extensions => [
		    'http://openid.net/srv/ax/1.0' => {
                        mode => 'fetch_request',
                        'type.nickname' => 'http://axschema.org/namePerson/friendly',
                        'type.email' => 'http://axschema.org/contact/email',
                        # 'type.fullname' => 'http://axschema.org/namePerson',
                        'type.firstname' => 'http://axschema.org/namePerson/first',
                        'type.lastname' => 'http://axschema.org/namePerson/last',
                        # 'type.dob' => 'http://axschema.org/birthDate',
                        'type.gender' => 'http://axschema.org/person/gender',
                        'type.country' => 'http://axschema.org/contact/country/home',
                        'type.language' => 'http://axschema.org/pref/language',
                        'type.timezone' => 'http://axschema.org/pref/timezone',
                        required => 'nickname,email,firstname,lastname',
                        if_available => 'gender,country,language,timezone',
		    },
                    ],  
	    },
	},
	members => {
	    credential => {
		class => 'Password',
		password_field => 'password',
		password_type => 'none'
	    },
		    store => {
			class => 'DBIx::Class',
			user_model => 'Schema::User',
			role_relation => 'roles',
			role_field => 'role',
			# use_userdata_from_session => 0,
		}
	},
	
    }
};





# Set configuration for static files
# Force specific directories to be handled by Static::Simple.
# These should ALWAYS be served in static mode.
__PACKAGE__->config(
    static => {
    dirs => [qw/ css js img tmp /],
#    include_path => [ '/tmp/wormbase',
#              __PACKAGE__->config->{root},
#        ],  
    include_path => [ '/usr/local/wormbase/shared/tmp',
              __PACKAGE__->config->{root},
        ],  
#   logging  => 1,
    });


# Dynamically set the base URL for production; also requires the prepare_path
if ($installation_type eq 'production') {
    __PACKAGE__->config->{base} = 'http://beta.wormbase.org/';
} else {
#    __PACKAGE__->config->{base} = '';
}




# Configure the application based on the type of installation.
# Application-wide configuration is located in wormbase.conf
# which can be over-ridden by wormbase_local.conf.
__PACKAGE__->config( 'Plugin::ConfigLoader' => {
    file => 'wormbase.conf',
    driver => {
        'General' => {
            -InterPolateVars => 1,
            -ForceArray      => 0,
            # Plugin::ConfigLoader uses Config::Any[::General]
            # which ForceArray by default. We don't want that.
        },
    },
} ) or die "$!";



# Which elements of the data structure should be exposed in JSON renders?
__PACKAGE__->config->{'View::JSON'} = {
    expose_stash => 'data' };


##################################################
#
#   Dynamically establish the cache backend
#
##################################################

# First, if we are a development site, we still want
# to test the caching mechanism, we just don't want 
# it to persist.
my $expires_in = ($installation_type eq 'production')
    ? '4 weeks'
    : '1 minute';

# Memcached/libmemcached support built into the app.
# Development and mirror distributions should point to localhost.
# The production installation points to our distributed memcached.
my $servers = ($installation_type eq 'production')
    ? [ '206.108.125.175:11211', '206.108.125.177:11211' , '206.108.125.190:11211','206.108.125.168:11211','206.108.125.178:11211']
    : [ '127.0.0.1:11211' ];

#__PACKAGE__->config->{'Plugin::Cache'}{backend} = {
#    class          => 'CHI',
#    driver         => 'Memcached::libmemcached',
#    servers        => $servers, 
#    expires_in     => $expires_in,	
#};#

# CHI based memcache
#__PACKAGE__->config->{'Plugin::Cache'}{backends}{memcache} = {
#    class          => 'CHI',
#    driver         => 'Memcached::libmemcached',
#    servers        => $servers, 
#    expires_in     => $expires_in,	
#};


# Path to the cache is hard-coded.
# If I pre-cache via WWW::Mech will the cache be portable?
# Also, can I make this dynamic?
#__PACKAGE__->config->{'Plugin::Cache'}{backends}{filecache} = {
#    class          => 'CHI',
#    driver         => 'File',
#    root_dir       => '/usr/local/wormbase/shared/test_cache',
#    store          => 'File',
#    depth          => 3,
#    max_key_length => 64,
#};

# For now, let's make the file cache the default.
#__PACKAGE__->config->{'Plugin::Cache'}{default_store} = 'File';

__PACKAGE__->config->{'Plugin::Cache'}{backend} = {
    class          => 'CHI',
    driver         => 'File',
    root_dir       => '/usr/local/wormbase/shared/cache',
    store          => 'File',
    depth          => 3,
    max_key_length => 64,
};



# Start the application!
__PACKAGE__->setup;




##################################################
#
#   Set headers for squid
#
##################################################

sub finalize_error {
	my $c = shift;
	$c->config->{'response_status'}=$c->response->status;
	$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'} = ["Catalyst::Plugin::ErrorCatcher::Email", "WormBase::Web::ErrorCatcherEmit"];
 	shift @{$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'}} unless(is_server_error($c->config->{'response_status'})); 
	$c->maybe::next::method; 
}
 

# There's a problem with c.uri_for when running behind a reverse proxy.
# We need to reset the base URL.
# We set the base URL above (which should probably be dynamic...)
# This isn't the best way of doing this as it only accounts for 
# URIs generated with c.uri_for.
after prepare_path => sub {
    my $c = shift;
    if ($c->config->{base}) {
    $c->req->base(URI->new($c->config->{base}));
    }
};
    

#if __PACKAGE__->config->{debug}
#$ENV{CATALYST_DEBUG_CONFIG} && print STDERR 'cat config looks like: '. dump(__PACKAGE__->config) . "\n";# . dump(%INC)."\n";


 

=pod

Detect if a controller request is via ajax to disable
template wrapping.

=cut

sub is_ajax {
  my $c       = shift;
  my $headers = $c->req->headers;
  return $headers->header('X-Requested-With');
}



sub get_example_object {
  my ($self,$class) = @_;
  my $api = $self->model('WormBaseAPI');

  my $ace = $api->_services->{acedb};
  # Fetch the total number of objects
  my $total = $ace->fetch(-class => ucfirst($class),
              -name  => '*');
  
  my $object_index = 1 + int rand($total-1);

  # Fetch one object starting from the randomly determined one
  my ($object) = $ace->fetch(ucfirst($class),'*',1,$object_index);
  return $object;
}



########################################
#
#  Helper methods for interacting with the cache.
#
########################################
sub check_cache {
    my ($self,$name,@keys) = @_;
    
    # First get the cache.
    # Single cache.
    my $cache = $self->cache;

    # filecache or memcache?
    # my $cache = $self->cache(backend => $name);
    
=pod
    # Now get the database version from the cache. Heh.
    my $version;
    unless ($version = $cache->get('wormbase_version')) {
	# The version isn't cached. So on this our first
	# check of the cache, stash the database version.
	
	$version = $self->model('WormBaseAPI')->version;
	$cache->set('wormbase_version',$version);
	$self->log->warn("tried to set a cache key");
    }
 
    # Build a cache key that includes the version.
    my $cache_id = join("_",@keys,$version);
=cut
    my $cache_id = join("/",@keys);
    # Now check the cache for the data we are looking for.
    my $cached_data = $cache->get($cache_id);

    # From which memcached server did this come from?
    my $cache_server;
    if ($name eq 'memcache'
	&& ($self->config->{timer} || $self->check_user_roles('admin'))) {
	if ($cached_data) {
	    $cache_server = $cache->get_server_for_key($cache_id);
	}
    } else {
	$cache_server = 'filecache' if $cached_data;
    }
    
    if ($cached_data) {
	$self->log->debug("CACHE: $cache_id: ALREADY CACHED; retrieving from server $cache_server.");
    } else {
	$self->log->debug("CACHE: $cache_id: NOT PRESENT; generating widget.");
    }

#	my $memd = $self->default_cache_backend->memd;
##     my $cached_data = $memd->get($cache_id);
#	my $cached_server;
#	
#	if ($cached_data) {
#	    $cached_server = $memd->get_server_for_key($cache_id) if ($self->config->{timer} || $self->check_user_roles('admin'));
#	    $self->log->debug("CACHE: $cache_id: ALREADY CACHED; retrieving from server $cached_server.");
#	} else {
#	    $self->log->debug("CACHE: $cache_id: NOT PRESENT; generating widget.");
#    }

    return ($cache_id,$cached_data,$cache_server);
}

 
# Provided with a pregenerated cache_id and (probably hash reference) of data,
# store it in the cache.
sub set_cache {
    my ($self,$name,$cache_id,$data) = @_;

#    my $cache = $self->cache(backend => $name);
#    $cache->set($cache_id,$data) or $self->log->warn("Couldn't cache data into $name: $!");
    $self->cache->set($cache_id,$data) or $self->log->warn("Couldn't cache data: $!");
    return;
}


#######################################################
#
#    Helper Methods
#
#######################################################

sub secure_uri_for {
    my ($self, @args) = @_;
    
    my $u = $self->uri_for(@args);
    if($self->config->{enable_ssl}){
      $u->scheme('https');
    }
    return $u;
}

# overloaded from Per_User plugin to move saved items
sub merge_session_to_user {
   my $c = shift;
   
    $c->log->debug("merging guest session into per user session") if $c->debug;

    my $merge_behavior = Hash::Merge::get_behavior;
    my $clone_behavior = Hash::Merge::get_clone_behavior;

    Hash::Merge::set_behavior( $c->config->{user_session}{merge_type} );
    Hash::Merge::set_clone_behavior(0);

    my $sid = $c->get_session_id;
    my $s_db = $c->model('Schema::Session')->find({session_id=>"session:$sid"});
    my $uid = $c->user->user_id;

    my @user_saved = $s_db->user_saved;

    my $user_items = $c->model('Schema::Starred')->search_rs({session_id=>"user:$uid"});

    foreach my $saved_item (@user_saved){
      unless($user_items->find({page_id=>$saved_item->page_id})){
        $saved_item->session_id("user:$uid");
      }else{
        $saved_item->delete();
      }
      $saved_item->update();
    }

    my $user_history = $c->model('Schema::History')->search_rs({session_id=>"user:$uid"});
    my @save_history = $s_db->user_history;
    foreach my $s_history (@save_history){
      my $u_history = $user_history->find({page_id=>$s_history->page_id});
      unless($u_history){
        $s_history->session_id("user:$uid");
      }else{
        $u_history->timestamp < $s_history->timestamp ? $u_history->timestamp($s_history->timestamp) : '' ;
        $u_history->visit_count($u_history->visit_count + $s_history->visit_count);
        $s_history->delete();
        $u_history->update();
      }
      $s_history->update();
    }

    my $s    = $c->session;
    my @keys =
      grep { !/^__/ } keys %$s;    # __user, __expires, etc don't apply here

    my %right;
    @right{@keys} = delete @{$s}{@keys};

    %{ $c->user_session } =
      %{ Hash::Merge::merge( $c->user_session || {}, \%right ) };

    Hash::Merge::set_behavior($merge_behavior);
    Hash::Merge::set_clone_behavior($clone_behavior);


}


#######################################################
#
#    TEMPLATE SELECTION
#
#######################################################

# Template assignment is a bit of a hack.
# Maybe I should just maintain
# a hash, where each field/widget lists its corresponding template
sub _select_template {
    my ($self,$render_target,$class,$type) = @_;

    # Normally, the template defaults to action name.
    # However, we have some shared templates which are
    # not located under root/classes/CLASS
    if ($type eq 'field') { 
    # Some templates are shared across Models
    if (defined $self->config->{common_fields}->{$render_target}) {
        return "shared/fields/$render_target.tt2";
        # Others are specific
    } else {
        return "classes/$class/$render_target.tt2";
    }
    } else {       
	# Widget template selection
	# Some widgets are shared across Models
	if (defined $self->config->{common_widgets}->{$render_target}) {
	    return "shared/widgets/$render_target.tt2";
	} else {  
	    return "classes/$class/$render_target.tt2"; 
	}
    }   
}



sub _get_widget_fields {
    my ($self,$class,$widget) = @_;

    my $section = $self->config->{sections}{species}{$class}
               || $self->config->{sections}{resources}{$class};

    if (ref $section eq 'ARRAY') {
        die "There appears to be more than one $class section in the config file\n";
    }

    # this is here to prevent a widget section from getting added to config
    unless(defined $section->{widgets}{$widget}){ return (); }

    my $fields = $section->{widgets}{$widget}{fields};
    my @fields = ref $fields eq 'ARRAY' ? @$fields : $fields // ();

    $self->log->debug("The $widget widget is composed of: " . join(", ",@fields));
    return @fields;
}



=head1 NAME

WormBase - Catalyst based application

=head1 SYNOPSIS

    script/wormbase_server.pl

=head1 DESCRIPTION

WormBase - the WormBase web application

=head1 SEE ALSO

L<WormBase::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
