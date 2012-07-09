package App::Web::Controller::Root;

use strict;
use warnings;
use parent 'App::Web::Controller';
 
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in App.pm
__PACKAGE__->config->{namespace} = '';

=head1 NAME

App::Web::Controller::Root - Root Controller for App

=head1 DESCRIPTION

Root level controller actions for the App web application.

=head1 METHODS

=cut

=head2 INDEX

=cut
 
sub index :Path Args(0) {
    my ($self,$c) = @_;
#    $c->stash->{template} = 'index.tt2';  # This should be unecessary.  make sure it is.
#    my $page = $c->model('Schema::Page')->find({url=>"/"});
#    my @widgets = $page->static_widgets if $page;
#    $c->stash->{static_widgets} = \@widgets if (@widgets);
    $c->stash->{template} = 'index.tt2';
}


=head2 DEFAULT

The default action is run last when no other action matches.

=cut

sub default :Path {
    my ($self,$c) = @_;    
    my $path = $c->request->path;

    # A user may be trying to request the top level page
    # for a class. Capturing that here saves me
    # having to create a separate index for each class.
    my ($class) = $path =~ /reports\/(.*)/;

    # Does this path exist as one of our pages?
    # This saves me from having to add an index action for
    # each class.  Each class will have a single default screen.
    if (defined $class && $c->config->{pages}->{$class}) {
	
		# Use the debug index pages.
		if ($c->config->{debug}) {
		  $c->stash->{template} = 'debug/index.tt2';
		} else {
			$c->stash->{template} = 'species/report.tt2';
			$c->stash->{path} = $c->request->path;
		}
    } else {
		$c->detach('/soft_404');
    }
}

sub soft_404 :Path('/soft_404') {
    my ($self,$c) = @_;
    # 404: Page not found...
    $c->stash->{template} = 'status/404.tt2';
    $c->error('Page not found');
    $c->response->status(404);
}
    


#sub gbrowse :Path("/gbrowse") Args(0) {
#    my ($self,$c) = @_;
#    $c->stash->{noboiler}=1;
#    $c->stash->{template} = 'gbrowse.tt2';
#}
sub header :Path("/header") Args(0) {
    my ($self,$c) = @_;
    $c->stash->{noboiler}=1;
    $c->stash->{template} = 'header/default.tt2';
}

sub footer :Path("/footer") Args(0) {
      my ($self,$c) = @_;
      $c->stash->{noboiler}=1;
      $c->stash->{template} = 'footer/default.tt2';
} 


sub issue_rss {
 my ($self,$c,$count) = @_;
 my @issues = $c->model('Schema::Issue')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
    my $threads= $c->model('Schema::IssueThread')->search(undef,{order_by=>'timestamp DESC'} );
     
    my %seen;
    my @rss;
    while($_ = $threads->next) {
      unless(exists $seen{$_->issue_id}) {
	  $seen{$_->issue_id} =1 ;
	  
	  push @rss, {	time=>$_->timestamp,
			people=>$_->user,
			title=>$_->issue->title,
			location=>$_->issue->page,
			id=>$_->issue->issue_id,
			re=>1,
		    } ;
      }
      last if(scalar(keys %seen)>=$count)  ;
    };

    map {	 
		push @rss, {      time=>$_->timestamp,
					      people=>$_->reporter,
					      title=>$_->title,
					      location=>$_->page,
				  id=>$_->issue_id,
			};
	} @issues;

    my @sort = sort {$b->{time} <=> $a->{time}} @rss;
    return \@sort;
}
 

=head2 end
    
    Attempt to render a view, if needed.

=cut

# This is a kludge.  RenderView keeps tripping over itself
# for some Model/Controller combinations with the dynamic actions.
#  Namespace collision?  Missing templates?  I can't figure it out.

# This hack requires that the template be specified
# in the dynamic action itself. 



#sub end : Path {
sub end : ActionClass('RenderView') {
  my ($self,$c) = @_;      
  
  # Forward to our view FIRST.
  # If we catach any errors, direct to
  # an appropriate error template.
  my $path = $c->req->path;
  if($path =~ /\.html/){
	$c->serve_static_file($c->path_to("root/static/$path"));
  } else{
  	$c->forward('App::Web::View::TT') unless ($c->req->path =~ /cgi-bin|cgibin/i || $c->action->name eq 'draw');
 }

  # 404 errors will be caught in default.
  #$c->stash->{template} = 'status/404.tt2';
  #$c->response->status(404);

  # 5xx
#  if ( my @errors = @{ $c->errors } ) {
#      $c->response->content_type( 'text/html' );
#      $c->response->status( 500 );
#      $c->response->body( qq{
#                        <html>
#                        <head>
#                        <title>Error!</title>
#                        </head>
#                        <body>
#                                <h1>Oh no! An Error!</h1>
#			  } . ( map { "<p>$_</p>" } @errors ) . qq{
#                        </body>
#                        </html>
#			  } );
#  }

}

# /quit, used for profiling so that NYTProf can exit cleanly.
sub quit :Global { exit(0) }


#sub end : ActionClass('RenderView') {  }


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
