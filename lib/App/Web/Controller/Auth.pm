package App::Web::Controller::Auth;

use strict;
use warnings;
use parent 'App::Web::Controller';
#use Net::Twitter;
#use Facebook::Graph;
use Crypt::SaltedHash;
use Data::GUID;

__PACKAGE__->config->{namespace} = '';
 
 
sub login :Path("/login")  :Args(0){
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'auth/login.tt2';
#        $c->stash->{'continue'} = $c->req->params->{continue};
}

# 1. Provide a form so users can submit their email address.
sub password : Chained('/') PathPart('password')  CaptureArgs(0) {
    my ( $self, $c) = @_;
    $c->stash->{template} = 'auth/password_reset_request.tt2';
}

# 2. Process the initial request and send out an email. Return a simple response.
sub password_email : Chained('password') PathPart('email')  Args(0){
    my ( $self, $c ) = @_;
    my $email = $c->req->param("email");
    $c->stash->{template} = "auth/password_reset_request.tt2";
    
    my @users = $c->model('CGC::AppUser')->search({email=>$email, validated=>1});
    if(@users){
	my $guid = Data::GUID->new;
	$c->stash->{token} = $guid->as_string;
	my $time = time() + $c->config->{password_reset_expires};
	foreach (@users){
	    next unless($_->user);
	    my $password = $c->model('CGC::AppPassword')->find($_->user_id);
	    if($password){
		if( time() < $password->expires ){
		    $c->stash->{token} = $password->token;
		}else {
		    $password->token($c->stash->{token}) ;
		    $password->expires($time) ;
		    $password->update();
		}
	    }else{
		$password = $c->model('CGC::AppPassword')->create({token=>$c->stash->{token}, user_id=>$_->user_id,expires=>$time});
	    }
	}
	$c->stash->{noboiler} = 1;
	$c->log->debug("send out password reset email to $email");
	$c->stash->{email} = {
	    to       => $email,
	    from     => $c->config->{register_email},
	    subject  => "CGC Password Request", 
	    template => "auth/password_email.tt2",
	};
	$c->forward( $c->view('Email::Template') );
    }
    $c->stash->{noboiler} = 0;
    $c->stash->{status} = 'request_sent';
    $c->stash->{error} = "No CGC account is associated with this email" unless $c->stash->{email};
}


sub password_index : Chained('password') PathPart('index')  Args(0){
    my ( $self, $c ) = @_;
    if($c->stash->{token}  = $c->req->param("id")) {
	my $user = $c->model('CGC::Password')->search({token=>$c->stash->{token} }, {rows=>1})->next;
	if(!$user || $user->expires < time() ){
	    if($user){
		$user->delete();
		$user->update();
	    }
	    
	    $c->stash->{template} = "shared/generic/message.tt2"; 
	    $c->stash->{message} = "the link has expired";
	}
    }
}





sub password_reset : Chained('password') PathPart('reset')  Args(0){
    my ( $self, $c ) = @_;
    my $token = $c->req->body_parameters->{token};
    my $new_password = $c->req->body_parameters->{password};
    $c->stash->{template} = "shared/generic/message.tt2"; 
    
    my $pass = $c->model('CGC::AppPassword')->search({token=>$token, expires => { '>', time() } }, {rows=>1})->next;
    if($pass && (my $user = $pass->user)){
	my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
	$csh->add($new_password);
	my $hash_password= $csh->generate();
	$user->password($hash_password);
	$pass->delete;
	$user->update();
	$pass->update();
	$c->stash->{request} = 'password-reset';
	$c->stash->{message} = "Your password has been reset. Please login'";
    }
    $c->stash->{message} ||= "The link to reset your password has expired. Please try again.";
}


sub register :Path("/register")  :Args(0){
    my ( $self, $c ) = @_;
#    if ($c->req->params->{inline}){
#	$c->stash->{noboiler} = 1;
    if (defined $c->req->body_parameters) {
	$c->stash->{email}     = $c->req->body_parameters->{email};
	$c->stash->{full_name} = $c->req->body_parameters->{name};
	$c->stash->{password}  = $c->req->body_parameters->{password}; 
	$c->stash->{redirect}  = $c->req->body_parameters->{redirect}; 
    }
    $c->stash->{template} = 'auth/register.tt2';
#     $c->stash->{'continue'}=$c->req->params->{continue};
}

# CGC: Refactored
# Confirm a new user account (via a link sent by email)
sub confirm :Path("/confirm")  :Args(0){
    my ( $self, $c ) = @_;
    my $user = $c->model('CGC::AppUser')->find($c->req->params->{u});
#    my $wb   = $c->req->params->{wb};
    
    $c->stash->{template} = "auth/account_confirmed.tt2"; 
    
    my $message;
    if (($user && !$user->active) || ( $user && !$user->valid_emails)) { 
	if(Crypt::SaltedHash->validate("{SSHA}".$c->req->params->{code}, $user->email . "_" . $user->username)) {
	    $user->validated(1);
	    $user->active(1);
	    $c->stash->{message} = "Your account is now activated, please login! ";		
	}
	$user->update();
    } 
    
    $c->stash->{expired} = $message ? '' :  "This link is not valid or has already expired.";
    $c->forward('App::Web::View::TT');
}



=pod
    sub openid :Path("/openid") {
	my ( $self, $c ) = @_;
	$c->stash->{noboiler} = 1;
	$c->stash->{'template'}='auth/openid.tt2';
}
=cut

sub auth : Chained('/') PathPart('auth')  CaptureArgs(0) {
    my ( $self, $c) = @_;
    $c->stash->{noboiler} = 1;  
    $c->stash->{template} = 'auth/login.tt2';
    $c->stash->{redirect} = $c->req->params->{redirect};
}

sub auth_popup : Chained('auth') PathPart('popup')  Args(0){
    my ( $self, $c) = @_;
    if($c->req->params->{label}) {
	$c->stash->{template} = 'auth/popup.tt2';
	$c->stash->{provider} = $c->req->params;
    } else {
	$c->log->debug("redirect: " . $c->uri_for('/auth/openid')
		       ."?openid_identifier="
		       .$c->req->params->{url}
		       ."&redirect="
		       .$c->req->params->{redirect});
	
	$c->res->redirect($c->uri_for('/auth/openid')."?openid_identifier=".$c->req->params->{url}."&redirect=".$c->req->params->{redirect});
    }     
}

sub auth_login : Chained('auth') PathPart('login')  Args(0){
    my ($self, $c) = @_;
    my $email    = $c->req->body_parameters->{email};
    my $password = $c->req->body_parameters->{password}; 
    
    # Is the table join really necessary here?
    if ( $email && $password ) {
#        my $rs = $c->model('CGC::AppUser')->search({active=>1, email=>$email, validated=>1, password => { '!=', undef }},
#						   {   select => [ 
#							   'me.user_id',
#							   'password', 
#							   'username',
#							   ],
#							   as => [ qw/
#                      user_id
#                      password
#                      username
#                    /], 
#		      join=>'email'
#						   });

        my $rs = $c->model('CGC::AppUser')->search({active=>1, email=>$email, validated=>1, password => { '!=', undef }},
						   {   select => [ 
							   'me.user_id',
							   'password', 
							   'username',
							   ],
							   as => [ qw/
                      user_id
                      password
                      username
                    /]});

	
	if ( $c->authenticate( { password => $password,
				 'dbix_class' => { resultset => $rs }
			       } ) ) {
	    
	    $c->log->debug('Username login was successful. '. $c->user->get("username") . $c->user->get("password"));
	    #                 $self->reload($c);
	    
	    $c->res->redirect($c->uri_for('/')->path);
#                 $c->res->redirect($c->uri_for($c->req->path));
	} else {
	    $c->log->debug('Login incorrect.'.$email);
	    $c->stash->{template} = "auth/login_failed.tt2";
	}
    } else {
	$c->stash->{template} = "auth/login_failed.tt2";
    }
}


sub auth_openid : Chained('auth') PathPart('openid')  Args(0){
    my ( $self, $c) = @_;
    
    $c->user_session->{redirect} = $c->user_session->{redirect} || $c->req->params->{redirect};
    my $redirect = $c->user_session->{redirect};
    my $param = $c->req->params;
    
#      $c->user_session->{redirect_after_login} ||= $param->{'continue'};
#      $c->stash->{'template'}='auth/openid.tt2';
    
    # Facebook: OAuth
    if (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ 'facebook') {
	my $fb = $self->connect_to_facebook($c); 
	$c->response->redirect($fb->authorize->uri_as_string);
	
	# Mendeley: OAuth
    } elsif (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ 'mendeley') {
	my $mendeley = $c->model('Mendeley')->private_api;
	
	my $url = $mendeley->get_authorization_url();
	
	# The URL that the user will be returned to after authenticating.
	$mendeley->callback($c->uri_for('/auth/mendeley'));
	$c->response->redirect($url);
	
	# Twitter uses OAUTH, not openid.
    } elsif (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ /twitter/i) {
	my $nt = $self->connect_to_twitter($c);
	
	# Weird. I have to approve app each and every time since I can't
	# get session data appropriate for the user until I log in. Circular.
	
	# Are we already linked to Twitter? Are our auth tokens still good?
	#  unless ($self->check_twitter_authorization_status($c)) {
	
	# The URL that the user will be returned to after authenticating.
	my $url = $nt->get_authorization_url(callback => $c->uri_for('/auth/twitter'));
	
	# Save the current request tokens as a cookie.
	$c->response->cookies->{oauth} = {
	    value => {
		token        => $nt->request_token,
		token_secret => $nt->request_token_secret,
	    },
	};
	$c->response->redirect($url);
	
    } else {
	# eval necessary because LWPx::ParanoidAgent
	# croaks if invalid URL is specified
	#  eval {
	# Authenticate against OpenID to get user URL
	$c->config->{user_session}->{migrate}=0;
	
	if ( $c->authenticate({}, 'openid' ) ) {
	    $c->stash->{'status_msg'} = 'OpenID login was successful.';
	    
	    # Google and other OpenID sites.
	    $self->auth_local({c          => $c, 
			       openid_url => $c->user->url,
			       # Entirely google specific here.
			       email      => $param->{'openid.ext1.value.email'},
			       first_name => $param->{'openid.ext1.value.firstname'}, 
			       last_name  => $param->{'openid.ext1.value.lastname'}, 
			       auth_type  => 'openid',      
			       provider   => 'google',
			       redirect   => $redirect });
	} else {
	    $c->stash->{'error_notice'}='Failure during OpenID login';
	}
    }
}



sub connect_to_facebook {
    my ($self,$c) = @_;
    
    my $secret = $c->config->{facebook_secret_key};
    my $app_id = $c->config->{facebook_app_id};
    
    my $fb = Facebook::Graph->new({app_id  => $app_id,
				   secret  => $secret,
				   postback => $c->uri_for('/auth/facebook/')});
    return $fb;
}

sub connect_to_twitter {
    my ($self,$c) = @_;
    
    my $consumer_key    = $c->config->{twitter_consumer_key};
    my $consumer_secret = $c->config->{twitter_consumer_secret};
    
    my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], 
			       consumer_key        => $consumer_key,
			       consumer_secret     => $consumer_secret,
	);
    return $nt;
}



# The URL users are returned to after authenticating with Facebook (postback, even though it's a GET. Typical).
sub auth_facebook_callback : Chained('auth') PathPart('facebook')  Args(0){
    my ($self,$c) = @_;
    
    my $authorization_code = $c->req->params->{code};
    
    my $fb = $self->connect_to_facebook($c);
    
    $fb->request_access_token($authorization_code);
    my $access_token = $fb->access_token;
    
    # Get the user's name and email.
    # See the Facebook Graph API: http://developers.facebook.com/docs/reference/api/
    # and perldoc for Facebook::Graph.
    my $response   = $fb->query->find('me')->request;
    my $user       = $response->as_hashref;
    my $email      = $user->{email};  # can throw errors if not authorized by user
    
    $self->auth_local({c          => $c, 
		       provider   => 'facebook',       
		       oauth_access_token   => $access_token,
		       first_name  => $user->{first_name},
		       last_name   => $user->{last_name},
		       screen_name => $user->{username},
		       email       => $email,
#       oauth_access_token_secret => $access_token_secret,
		       auth_type     => 'oauth',
		      });        
}


# The URL users are returned to after authenticating with Twitter.
sub auth_twitter_callback : Chained('auth') PathPart('twitter')  Args(0){
    my($self, $c) = @_;
#       $c->stash->{'template'}='auth/openid.tt2';
    my %cookie   = $c->request->cookies->{oauth}->value;
    my $verifier = $c->req->params->{oauth_verifier};
    
    my $nt = $self->connect_to_twitter($c);
    
    $nt->request_token($cookie{token});
    $nt->request_token_secret($cookie{token_secret});
    
    my ($access_token, $access_token_secret, $user_id, $screen_name)
	= $nt->request_access_token(verifier => $verifier);
    
    $self->auth_local({c          => $c, 
		       provider   => 'twitter',       
		       oauth_access_token        => $access_token,
		       oauth_access_token_secret => $access_token_secret,
		       screen_name   => $screen_name,
		       auth_type     => 'oauth',
		      });        
}


# The URL users are returned to after authenticating with Mendeley.
sub auth_mendeley_callback : Chained('auth') PathPart('mendeley')  Args(0){
    my($self, $c) = @_;
    
    my %cookie   = $c->request->cookies->{oauth}->value;
    my $verifier = $c->req->params->{oauth_verifier};    
    
    my $mendeley = $c->model('Mendeley')->private_api;
    my ($access_token, $access_token_secret) = $mendeley->request_access_token;
    
    $self->auth_local({c          => $c, 
		       provider   => 'mendeley',
		       oauth_access_token        => $access_token,
		       oauth_access_token_secret => $access_token_secret,
#       screen_name   => $screen_name,
		       auth_type     => 'oauth',
		      });        
}

sub auth_local {
    my ($self,$params) = @_;
    my $c          = $params->{c};
    my $auth_type  = $params->{auth_type};
    
    # Create a new openid or oauth entry in openid. POSSIBLITY FOR DUPLICATION HERE?
    # Should echeck and see if the user is already logged in.
    # (or use auto_create_user: 1)
    my $authid;
    if ($auth_type eq 'openid') {
	$authid = $c->model('CGC::AppOpenID')->find_or_create({ openid_url => $params->{openid_url} });
    } elsif ($auth_type eq 'oauth') {
	$authid = $c->model('CGC::AppOpenID')->find_or_create({ oauth_access_token        => $params->{oauth_access_token},
								oauth_access_token_secret => $params->{oauth_access_token_secret}
							      });
    }
    
    my $first_name = $params->{first_name};
    my $last_name  = $params->{last_name};
    my $email      = $params->{email};
    my $redirect   = $params->{redirect};
    
    my $user;  
    # If we haven't yet associated a user_id to the new openid/oauth entry, do so now.
    unless ($authid->user_id) {
	
	# create a username based on
	#   * supplied first/last
	#   * extracted first/last (google)
	#   * screen name (Twitter)
	#   * or URL (really?)
        my $username;      
        if ($first_name) {
            $username = $first_name . " " . $last_name;
        } elsif ($last_name) {
            $username = $last_name;
	} elsif ($params->{screen_name}) {
	    $username = $params->{screen_name};
        } else {
            $username = $params->{openid_url};
        }
	
	# Does a user already exist for this account? Try looking up by email
        my @users = $c->model('CGC::AppUser')->search({email=>$email, validated=>1});
        @users = map { $_->user } @users;
	
        foreach (@users){
	    next unless $_;
	    next if( $_->active eq 0);
	    $user=$_; 
	    last;
        }
	
	# We're attaching something like a new Google account association to an existing user.
        if ($email && $user) {
            $username = $user->username if ($user->username);
            $c->log->debug("adding openid to existing user $username");
            $user->set_columns({username=>$username, active=>1});
            $user->update();
	} elsif (($c->user && $auth_type eq 'oauth') || ($params->{provider} eq 'facebook')) {
	    $user = $c->user unless $user;
	}
	
	# No user exists yet?  Let's create a new one.
	unless ($user) {
            $c->stash->{prompt_wbid} = 1;
            $c->stash->{redirect} = $redirect;
            $c->log->debug("creating new user $username, $email");
            $user=$c->model('CGC::AppUser')->create({username      => $username,
							active        => 1, 
							email         => $email,
							validated     => 1,
							primary_email => 1}) ;
        }
	
	# HARD-CODED!  The following people become admins automatically if they've
	# logged in with this email or openid account.
	if ($email =~ m{
                        todd\@wormbase\.org            |
                        toddwharris\@gmail\.com         |
                        me\@todd\.co                   |
                        shiranpasternak\@gmail\.com    |
	    }x) {
	    my $role=$c->model('CGC::AppRole')->find({role=>"admin"}) ;
	    $c->model('CGC::AppUsersToRole')->find_or_create({user_id=>$user->id,role_id=>$role->id});
	}
	
	# Update the authid entry
	if ($authid) {
	    $authid->user_id($user->id);                   # Link to my user.
	    $authid->auth_type($auth_type);                # One of openid or oauth
	    $authid->provider($params->{provider});        # twitter, google, etc.
	    $authid->screen_name($params->{screen_name});  # mostly only used by twitter.
	    $authid->update();
	}
    }
    
    # Re-authenticate against local DBIx store
    $c->config->{user_session}->{migrate}=1;
    if ( $c->authenticate({ user_id=>$authid->user_id }, 'members') ) {
        $c->stash->{'status_msg'} = 'Local Login was also successful.';
        $c->log->debug('Local Login was also successful.');
        $self->reload($c) ;
#   $c->res->redirect($c->user_session->{redirect_after_login});
    }
    else {
        $c->log->debug('Local login failed');
        $c->stash->{'error_notice'}='Local login failed.';
    }
}

sub reload {
    my ($self, $c,$logout) = @_;
    $c->stash->{logout}=0;
    $c->stash->{reload}=1;
    
    $c->stash->{logout}=1 if($logout);    
    return;
}


sub logout :Path("/logout") :Args(0){
    my ($self, $c) = @_;
    # Clear the user's state
    $c->logout;
    $c->stash->{'template'} = 'auth/logout.tt2';
#     $c->response->redirect($c->uri_for('/'));
#    $self->reload($c,1) ;
#     $c->session_expire_key( __user => 0 );
}


sub profile :Path("/profile") :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;    
    $c->stash->{template} = 'auth/profile.tt2';
} 


sub profile_update :Path("/profile_update")  :Args(0) {
    my ( $self, $c ) = @_;
    my $email    = $c->req->params->{email};
    my $username = $c->req->params->{username};
    my $message;
    if($email){
	my $found;
	my @emails = $c->model('CGC::AppUser')->search({email=>$email, validated=>1});
	foreach (@emails) {
	    $message="The email address <a href='mailto:$email'>$email</a> has already been registered.";     
	    $found = 1;
	}
	unless($found){
	    $c->model('CGC::AppUser')->find_or_create({email=>$email, user_id=>$c->user->user_id});
	    $c->controller('REST')->rest_register_email($c, $email, $c->user->username, $c->user->user_id);
	    $message="An email has been sent to <a href='mailto:$email'>$email</a>. ";
	}
    }
    unless($c->user->username =~ /^$username$/){
	$c->user->username($username);
	$c->user->update();
	$message= $message . "Your name has been updated to $username";
    }
    
    $c->stash->{message} = $message; 
    $c->stash->{template} = "shared/generic/message.tt2"; 
    $c->stash->{redirect} = $c->uri_for("me")->path;
    $c->forward('App::Web::View::TT');
} 


=pod

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
    
1;





