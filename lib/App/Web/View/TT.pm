package App::Web::View::TT;

use Moose;
extends 'Catalyst::View::TT';


__PACKAGE__->config({
		     INCLUDE_PATH => [
				      App::Web->path_to( 'templates' ),
				      App::Web->path_to( 'templates' , 'config'),
				      App::Web->path_to( 'static',    'css'    ),
				      App::Web->path_to( 'static',    'css', 'flora'    ),
				     ],
		     PRE_PROCESS  => ['config/main','core_elements.tt2'],
		     WRAPPER      => 'wrapper.tt2',
#		     ERROR        => 'error',
		     TEMPLATE_EXTENSION => '.tt2',
		     RECURSION    => 1,
		     EVAL_PERL => 1,
		     # Automatically pre- and post-chomp to keep
		     # templates simpler and output cleaner.
		     # Might want to use "2" instead, which collapses.
			 
		     PRE_CHOMP    => 2,
		     POST_CHOMP   => 2,
		     # NOT CURRENTLY IN USE!
#		     PLUGIN_BASE  => 'App::Web::View::Template::Plugin',
		     PLUGINS      => {
#				      url    => 'App::Web::View::Template::Plugin::URL',
#				      image  => 'Template::Plugin::Image',
#				      format => 'Template::Plugin::Format',
#				      util   => 'App::Web::View::Template::Plugin::Util',
				     },
#		     TIMER        => 1,
		     DEBUG        => 1,
#		     CONSTANTS    => {
#			 database_version => sub {
#			     App::Web->model('ExternalModel')->version
#			 }
#		     },
		    });



=head1 NAME

App::Web::View::TT - Catalyst View

=head1 SYNOPSIS

See L<WormBase>

=head1 DESCRIPTION

Catalyst View.

=head1 AUTHOR

Todd Harris (todd@hiline.co)

=head1 LICENSE

This library is copyright @ 2011 Hi-Line Informatics, LLC.

=cut

1;

