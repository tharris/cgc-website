package App::Web::Controller::REST;

use Moose;
BEGIN { extends 'Catalyst::Controller::REST'; }

use Time::Duration;
use XML::Simple;
use Crypt::SaltedHash;
use List::Util qw(shuffle);
use URI::Escape;
use DateTime;

__PACKAGE__->config(
    'default'          => 'text/x-json',
    'stash_key'        => 'rest',
    'map'              => {
		'text/x-yaml'      => 'YAML',
		'text/html'        => [ 'View', 'TT' ],
		'text/xml'         => 'XML::Simple',
		'application/json' => 'JSON',
    }
);

=head1 NAME

App::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut
 
# Typeahead support method

sub list :Local : ActionClass('REST') :Args(1) { }

sub list_GET {
	my ($self, $c, $class) = @_;

	$class = ($class eq 'geneclass') ? 'GeneClass' : ucfirst($class);

	my $columns = $c->request->param('columns')
		? [ split(',', $c->request->param('columns')) ]
		: [ qw/name/ ];
	my $transformer = sub {
		my $row = shift;
		return [ map { $row->get_column($_) } @$columns ];
	};
	my $select = exists $c->request->parameters->{distinct}
		? { select => { distinct => $columns }, as => $columns }
		: { columns => $columns };
	my $rows = [ map { $transformer->($_) }
		     $c->model("CGC::$class")->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
	    $c,
	    entity => $rows,
    );
}


sub print :Path('/rest/print') :Args(0) :ActionClass('REST') {}
sub print_POST {
    my ( $self, $c) = @_;
   
    my $api = $c->model('AppAPI');
    $c->log->debug("AppAPI model is $api " . ref($api));
     
    my $path = $c->req->param('layout');
    
    if($path) {
      $path = $c->req->headers->referer.'#'.$path;
      $c->log->debug("here is the path $path");
      my $file = $api->_tools->{print}->run($path);
     
      if ($file) {
      $c->log->debug("here is the file: $file");     
      $file =~ s/.*print/\/print/;
      $c->res->body($file);
      }

    }
}


sub workbench :Path('/rest/workbench') :Args(0) :ActionClass('REST') {}
sub workbench_GET {
    my ( $self, $c) = @_;
    my $session = $self->get_session($c);

    my $url = $c->req->params->{url};
    if($url){
      my $class = $c->req->params->{class};
      my $save_to = $c->req->params->{save_to};
      my $is_obj = $c->req->params->{is_obj} || 0;
#       $c->stash->{is_obj} = $is_obj;
      my $loc = "saved reports";
      $save_to = 'reports' unless $save_to;
      if ($class eq 'paper') {
        $loc = "library";
        $save_to = 'my_library';
      }
      my $name = $c->req->params->{name};

      my $page = $c->model('Schema::Page')->find_or_create({url=>$url,title=>$name,is_obj=>$is_obj});
      my $saved = $page->user_saved->find({session_id=>$session->id});
      if($saved){
            $c->stash->{notify} = "$name has been removed from your $loc";
            $saved->delete();
            $saved->update(); 
      } else{
            $c->stash->{notify} = "$name has been added to your $loc"; 
            $c->model('CGC::AppStarred')->find_or_create({session_id=>$session->id,page_id=>$page->page_id, save_to=>$save_to, timestamp=>time()}) ;
      }
    }
    $c->stash->{noboiler} = 1;
    my $count = $session->pages->count;
    $c->stash->{count} = $count || 0;
$c->response->headers->expires(time);
    $c->stash->{template} = "workbench/count.tt2";
    $c->forward('App::Web::View::TT');
} 

sub workbench_star :Path('/rest/workbench/star') :Args(0) :ActionClass('REST') {}

sub workbench_star_GET{
    my ( $self, $c) = @_;
    my $url = $c->req->params->{url};
    my $page = $self->get_session($c)->pages->find({url=>$url});

    if($page) {
          $c->stash->{star}->{value} = 1;
    } else{
        $c->stash->{star}->{value} = 0;
    }
    $c->stash->{star}->{wbid} = $c->req->params->{wbid};
    $c->stash->{star}->{name} = $c->req->params->{name};
    $c->stash->{star}->{class} = $c->req->params->{class};
    $c->stash->{star}->{url} = $url;
    $c->stash->{star}->{is_obj} = $c->req->params->{is_obj};
    $c->stash->{template} = "workbench/status.tt2";
    $c->stash->{noboiler} = 1;
$c->response->headers->expires(time);
    $c->forward('App::Web::View::TT');
}

sub layout :Path('/rest/layout') :Args(2) :ActionClass('REST') {}

sub layout_POST {
  my ( $self, $c, $class, $layout) = @_;
  $layout = 'default' unless $layout;
#   my %layoutHash = %{$c->user_session->{'layout'}->{$class}};
  my $i = 0;
  if($layout ne 'default'){
    $c->log->debug("max: " . join(',', (sort {$b <=> $a} keys %{$c->user_session->{'layout'}->{$class}})));
    
    $i = ((sort {$b <=> $a} keys %{$c->user_session->{'layout'}->{$class}})[0]) + 1;
    $c->log->debug("not default: $i");
  }

  my $lstring = $c->request->body_parameters->{'lstring'};
  $c->user_session->{'layout'}->{$class}->{$i}->{'name'} = $layout;

  $c->user_session->{'layout'}->{$class}->{$i}->{'lstring'} = $lstring;
}



sub auth :Path('/rest/auth') :Args(0) :ActionClass('REST') {}

sub auth_GET {
    my ($self,$c) = @_;   
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "nav/status.tt2"; 
    $self->status_ok($c,entity => {});
    $c->forward('App::Web::View::TT');
}

sub get_session {
    my ($self,$c) = @_;
    unless($c->user_exists){
      my $sid = $c->get_session_id;
      return $c->model('CGC::AppSession')->find({session_id=>"session:$sid"});
    }else{
      return $c->model('CGC::AppSession')->find({session_id=>"user:" . $c->user->user_id});
    }
}


sub get_user_info :Path('/auth/info') :Args(1) :ActionClass('REST'){}

sub get_user_info_GET{
    my ( $self, $c, $name) = @_;
    
    my $api = $c->model('AppAPI');
    my $object = $api->fetch({class => 'Person',
			      name  => $name,
			     }) or die "$!";

    my $message;
    my $status_ok = 1;
    my @users = $c->model('CGC::AppUser')->search({wbid=>$name, wb_link_confirm=>1});
    if(@users){
	$status_ok = 0;
	$message = "This account has already been linked";
    }elsif($object && $object->email->{data}){
	my $emails = join (', ', map {"<a href='mailto:$_'>$_</a>"} @{$object->email->{data}});
	$message = "An email will be sent to " . $emails . " to confirm your identity";
    }else{
	$status_ok = 0;
	$message = "This account cannot be linked at this time";
    }
    $self->status_ok(
	$c,
	entity =>  {
	    wbid => $name,
	    fullname => $object->name->{data}->{label},
	    email => $object->email->{data},
	    message => $message,
	    status_ok => $status_ok,
	},
	);
    
}

sub system_message :Path('/rest/system_message') :Args(1) :ActionClass('REST') {}
sub system_message_POST {
    my ($self,$c,$message_id) = @_;
    $c->user_session->{close_system_message}->{$message_id} = 1;
}


sub history :Path('/rest/history') :Args(0) :ActionClass('REST') {}

sub history_GET {
    my ($self,$c) = @_;
    my $clear = $c->req->params->{clear};
    $c->log->debug("history");
    my $session = $self->get_session($c);
    
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "shared/fields/user_history.tt2"; 
    
    if($clear){ 
	$c->log->debug("clearing");
	$session->user_history->delete();
	$session->update();
	$c->stash->{history} = "";
	$c->forward('App::Web::View::TT');
	$self->status_ok($c,entity => {});
    }
    
    my @hist = $session->user_history if $session;
    my $size = @hist;
    my $count = $c->req->params->{count} || $size;
    if($count > $size) { $count = $size; }
    
    @hist = sort { $b->get_column('timestamp') <=> $a->get_column('timestamp')} @hist;
    
    my @histories;
    map {
	if($_->visit_count > 0){
	    my $time = $_->get_column('timestamp');
	    push @histories, {  time_lapse => concise(ago(time()-$time, 1)),
				visits => $_->visit_count,
				page => $_->page,
	    };
	}
    } @hist[0..$count-1];
    $c->stash->{history} = \@histories;
    $c->response->headers->expires(time);
    $c->forward('App::Web::View::TT');
    $self->status_ok($c,entity => {});
}


sub history_POST {
    my ($self,$c) = @_;
    $c->log->debug("history logging");
    my $session = $self->get_session($c);
    my $path = $c->request->body_parameters->{'ref'};
    my $name = URI::Escape::uri_unescape($c->request->body_parameters->{'name'});
    my $is_obj = $c->request->body_parameters->{'is_obj'};
    
    my $page = $c->model('Schema::Page')->find_or_create({url=>$path,title=>$name,is_obj=>$is_obj});
    $c->log->debug("logging:" . $page->page_id . " is_obj: " . $is_obj);
    my $hist = $c->model('Schema::History')->find_or_create({session_id=>$session->id,page_id=>$page->page_id});
    $hist->set_column(timestamp=>time());
    $hist->set_column(visit_count=>($hist->visit_count + 1));
    $hist->update;
}


sub update_role :Path('/rest/update/role') :Args :ActionClass('REST') {}

sub update_role_POST {
    my ($self,$c,$id,$value,$checked) = @_;
    
    if($c->check_user_roles('admin')){
	my $user=$c->model('CGC::AppUser')->find({user_id=>$id}) if($id);
	my $role=$c->model('CGC::AppRole')->find({role=>$value}) if($value);
	
	my $users_to_roles=$c->model('CGC::AppUsersToRole')->find_or_create(user_id=>$id,role_id=>$role->role_id);
	$users_to_roles->delete()  unless($checked eq 'true');
	$users_to_roles->update();
    }
}


sub download : Path('/rest/download') :Args(0) :ActionClass('REST') {}

sub download_GET {
    my ($self,$c) = @_;
     
    my $filename=$c->req->param("type");
    $filename =~ s/\s/_/g;
    $c->response->header('Content-Type' => 'text/html');
    $c->response->header('Content-Disposition' => 'attachment; filename='.$filename);
#     $c->response->header('Content-Description' => 'A test file.'); # Optional line
    $c->response->body($c->req->param("sequence"));
}

# CGC: Already refactored.
# Register a new user
# This rest action is a target of the /register.
sub rest_register :Path('/rest/register') :Args(0) :ActionClass('REST') {}

sub rest_register_POST {
    my ($self,$c) = @_;
    my $email    = $c->req->params->{email};
    my $username = $c->req->params->{username};
    my $password = $c->req->params->{password};
    
    if ($email && $username && $password) {
	my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
	$csh->add($password);
	my $hash_password = $csh->generate();
	
	# Is this email already registered?
	my @emails = $c->model('CGC::AppUser')->search({email=>$email, validated=>1});
	
	# goofy.
	foreach (@emails) {
	    $c->res->body(0);
	    return 0;         
	}
       	
	my $user = $c->model('CGC::AppUser')->find_or_create({username        => $username, 
							      password        => $hash_password,
							      active          => 0,
							      email           => $email,
							     });
	my $user_id = $user->user_id;
	
	$self->rest_register_email($c, $email, $username, $user_id);
	
	$c->stash->{template} = "auth/registration_complete.tt2"; 
	$c->stash->{email}    = $email;
#       $c->stash->{redirect} = $c->req->params->{redirect};
	$c->forward('App::Web::View::TT');
    }
}



# CGC: Already refactored
sub rest_register_email {
    my ($self,$c,$email,$username,$user_id) = @_;
    
    $c->stash->{info}->{username} = $username;
    $c->stash->{info}->{email}    = $email;
    
    $c->stash->{noboiler} = 1;
    
    my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
    $csh->add($email."_".$username);
    my $digest = $csh->generate();
    $digest =~ s/^{SSHA}//;
    $digest =~ s/\+/\%2B/g;
    my $url = $c->uri_for('/confirm') . "?u=" . $user_id . "&code=" . $digest;
    
#    if ($wbid){
#	$c->stash->{info}->{wbid}=$wbid;
#	my $csh2 = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
#	$csh2->add($email . "_" . $wbid);
#	my $wb_hash = $csh2->generate();
#	$wb_hash =~ s/^{SSHA}//;
#	$wb_hash =~ s/\+/\%2B/g;
#	$url     = $url . "&wb=" . $wb_hash;
#    }
    
    $c->stash->{digest} = $url;
    
    $c->log->debug(" send out email to $email");
    $c->stash->{email} = {
	to       => $email,
	from     => $c->config->{register_email},
	subject  => "CGC Account Activation", 
	template => "auth/register_email.tt2",
    };
    
    $c->forward( $c->view('Email::Template') );
}













sub check_user_info {
  my ($self,$c) = @_;
  my $user;
  if($c->user_exists) {
      $user=$c->user; 
      $user->username($c->req->params->{username}) if($c->req->params->{username});
      $user->email($c->req->params->{email}) if($c->req->params->{email});
  }else{
      if($user = $c->model('CGC::AppUser')->find({email=>$c->req->params->{email},active =>1})){
	  $c->res->body(0) ;return 0 ;
      }
      $user=$c->model('CGC::AppUser')->find_or_create({email=>$c->req->params->{email}}) ;
      $user->username($c->req->params->{username}),
  }
  $user->update();
  return $user;
}




sub recently_saved {
 my ($self,$c,$count) = @_;
    my $api = $c->model('AppAPI');
    my @saved = $c->model('Schema::Starred')->search(undef,
                {   select => [ 
                      'page_id', 
                      { max => 'timestamp', -as => 'latest_save' }, 
                    ],
                    as => [ qw/
                      page_id 
                      timestamp
                    /], 
                    order_by=>'latest_save DESC', 
                    group_by=>[ qw/page_id/]
                })->slice(0, $count-1);

    my @ret = map { $self->_get_search_result($c, $api, $_->page, ago((time() - $_->timestamp), 1)) } @saved;

    $c->stash->{type} = 'all'; 

    return \@ret;
}

sub most_popular {
 my ($self,$c,$count) = @_;

    my $api = $c->model('AppAPI');
#     my $interval = "> UNIX_TIMESTAMP() - 604800"; # one week ago
    my $interval = "> UNIX_TIMESTAMP() - 86400"; # one day ago
#     my $interval = "> UNIX_TIMESTAMP() - 3600"; # one hour ago
#     my $interval = "> UNIX_TIMESTAMP() - 60"; # one minute ago
    my @saved = $c->model('Schema::History')->search({is_obj=>1, timestamp => \$interval},
                {   select => [ 
                      'page.page_id', 
                      { sum => 'visit_count', -as => 'total_visit' }, 
                    ],
                    as => [ qw/
                      page_id 
                      visit_count
                    /], 
                    order_by=>'total_visit DESC', 
                    group_by=>[ qw/page_id/],
                    join=>'page'
                })->slice(0, $count-1);

    my @ret = map { $self->_get_search_result($c, $api, $_->page, $_->visit_count . " visits") } @saved;

    $c->stash->{type} = 'all'; 
    return \@ret;
}


#input page obj from user db, return result
sub _get_search_result {
  my ($self,$c, $api, $page, $footer) = @_;

  if($page->is_obj){
    my @parts = split(/\//,$page->url); 
    my $class = $parts[-2];
    my $id = uri_unescape($parts[-1]);
    $c->log->debug("class: $class, id: $id");

    my $obj = $api->fetch({class=> ucfirst($class),
                              name => $id}) or die "$!";
    my %ret = %{$api->xapian->_wrap_objs($c, $obj, $class, $footer);};
    unless (defined $ret{name}) {
      $ret{name}{id} = $id;
      $ret{name}{class} = $class;
    }
    return \%ret;
  }

  return { 'name' => {  url => $page->url, 
                                label => $page->title,
                                id => $page->title,
                                class => 'page' },
            footer => "$footer",
                    };
}


sub comment_rss {
 my ($self,$c,$count) = @_;
 my @rss;
 my @comments = $c->model('Schema::Comment')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
 map {
        my $time = ago((time() - $_->timestamp), 1);
        push @rss, {      time=>$_->timestamp,
                          time_lapse=>$time,
                          people=>$_->reporter,
                          page=>$_->page,
                          content=>$_->content,
                          id=>$_->comment_id,
             };
     } @comments;
 return \@rss;
}

sub issue_rss {
  my ($self,$c,$count) = @_;
  my @issues = $c->model('Schema::Issue')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
  my $threads= $c->model('Schema::IssueThread')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
    
  my %seen;
  my @rss;
  while($_ = $threads->next) {
    unless(exists $seen{$_->issue_id}) {
    $seen{$_->issue_id} =1 ;
    my $time = ago((time() - $_->timestamp), 1);
    push @rss, {  time=>$_->timestamp,
          time_lapse=>$time,
          people=>$_->user,
          title=>$_->issue->title,
          page=>$_->issue->page,
          id=>$_->issue->issue_id,
          re=>1,
          } ;
    }
    last if(scalar(keys %seen)>=$count)  ;
  };

  map {    
    my $time = ago((time() - $_->timestamp), 1);
      push @rss, {      time=>$_->timestamp,
                        time_lapse=>$time,
                        people=>$_->reporter,
                        title=>$_->title,
                        page=>$_->page,
                id=>$_->id,
          };
  } @issues;

  my @sort = sort {$b->{time} <=> $a->{time}} @rss;
  return \@sort;
}

sub widget_me :Path('/rest/widget/me') :Args(1) :ActionClass('REST') {}

sub widget_me_GET {
    my ($self,$c,$widget) = @_; 
    my $api = $c->model('AppAPI');
    my $type;
    $c->stash->{'bench'} = 1;
$c->response->headers->expires(time);
    if($widget=~m/user_history/){
      $self->history_GET($c);
      return;
    } elsif($widget=~m/profile/){
      $c->stash->{noboiler} = 1;
      $c->res->redirect('/profile');
      return;
    }elsif($widget=~m/issue/){
      $self->feed_GET($c,"issue");
      return;
    }

    if($widget=~m/my_library/){ $type = 'paper';} else { $type = 'all';}

    my $session = $self->get_session($c);
    my @reports = $session->user_saved->search({save_to => $widget});
#     $c->log->debug("getting saved reports @reports for user $session->id");  

    my @ret = map { $self->_get_search_result($c, $api, $_->page, "added " . ago((time() - $_->timestamp), 1) ) } @reports;

    $c->stash->{'results'} = \@ret;
    $c->stash->{'type'} = $type; 
    $c->stash->{template} = "workbench/widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('App::Web::View::TT');
    return;
}






######################################################
#
#   CGC API
#
######################################################

sub search :Path('/rest/search') :Args(2) :ActionClass('REST') {}

sub search_GET {
    my ($self,$c,$class,$query) = @_;
    
    if ($class eq 'laboratory') {
	$class ='CGC::Laboratory';
    } 
    
#    my @results = $c->model($class)->search({laboratory_designation => $query });
    my @results = $c->model($class)->search({id => $query });
    $c->log->info(@results . ": $class");
    my @data;
    foreach (@results) {
	$c->log->info($_->head);
	push @data,{ id => $_->id,
		     lab => $_->laboratory_designation,
		     pi  => $_->lab_head_first_name . ' ' . $_->lab_head_last_name,
		     institution => $_->institution };
	
    }
    $self->status_ok( $c, entity => { data => \@data } );
    return;
}    







sub logout :Path("/rest/logout") :Args(0) :ActionClass('REST') {}

sub logout_GET {
    my ($self, $c) = @_;
    # Clear the user's state
    $c->logout;
#    $c->stash->{noboiler} = 1;  
    
    $c->stash->{'template'} = 'auth/logout.tt2';
#     $c->response->redirect($c->uri_for('/'));
#    $self->reload($c,1) ;
#     $c->session_expire_key( __user => 0 );
}




sub cart :Path('/cart') :Args(1) :ActionClass('REST') {}

sub cart_GET {
	my ($self, $c, $cart_id) = @_;
	my %carts = (
		601 => {
			strains => [ 'CA257', 'N2', 'RGD1' ],
		},
		602 => {
			strains => [ 'CR1', 'GF63', 'JJ1237' ],
		}
	);
	$c->stash->{template} = 'cart.tt2';
	my $cart = $carts{$cart_id};
	if (!defined $cart) {
		$c->forward('404.tt2');
	}
	$self->status_ok($c, entity => $cart);
}

sub cart_POST {
}










=cut

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
