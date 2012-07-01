package App::Web;

use Moose;
use namespace::autoclean;
use Hash::Merge;
use Catalyst qw/
    ConfigLoader
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
    /;
extends 'Catalyst';
our $VERSION = '0.01';

use Log::Log4perl::Catalyst;
use HTTP::Status qw(:constants :is status_message);
use Cwd qw/abs_path/;

##################################################
#
#   Configure the application based on our environment.
#
#   The startup script should set an environment variable
#   for installation type; otherwise it defaults to staging.
#
##################################################
$ENV{APP_ROOT} ||= abs_path("@{[__FILE__]}/../../..");
my $installation_type = $ENV{APP_INSTALLATION_TYPE} || 'staging';

# Different loggers.
__PACKAGE__->log(
    Log::Log4perl::Catalyst->new(
        __PACKAGE__->path_to('conf', 'log4perl', "$installation_type.conf")
            ->stringify
    )
);

__PACKAGE__->config->{'Plugin::Session'} = {
    expires           => 3600,
    dbi_dbh           => 'cgc',
    dbi_table         => 'app_sessions',
    dbi_id_field      => 'session_id',
    dbi_data_field    => 'session_data',
    dbi_expires_field => 'expires',
};

__PACKAGE__->config->{authentication} = {
    default_realm => 'default',
    realms        => {
        default => {
            credential => {
                class          => 'Password',
                password_field => 'password',
                #password_type => 'clear'
                password_type     => 'salted_hash',
                password_salt_len => 4,
            },
            store => {
                class         => 'DBIx::Class',
                user_model    => 'CGC::AppUser',
                role_relation => 'roles',
                role_field    => 'role',
                #  ignore_fields_in_find => [ 'remote_name' ],
                #  use_userdata_from_session => 0,
            }
        },
        openid => {
            credential => {
                class      => 'OpenID',
                ua_class   => 'LWP::UserAgent',
                extensions => [
                    'http://openid.net/srv/ax/1.0' => {
                        mode => 'fetch_request',
                        'type.nickname' =>
                            'http://axschema.org/namePerson/friendly',
                        'type.email' => 'http://axschema.org/contact/email',
                        # 'type.fullname' => 'http://axschema.org/namePerson',
                        'type.firstname' =>
                            'http://axschema.org/namePerson/first',
                        'type.lastname' =>
                            'http://axschema.org/namePerson/last',
                        # 'type.dob' => 'http://axschema.org/birthDate',
                        'type.gender' => 'http://axschema.org/person/gender',
                        'type.country' =>
                            'http://axschema.org/contact/country/home',
                        'type.language' =>
                            'http://axschema.org/pref/language',
                        'type.timezone' =>
                            'http://axschema.org/pref/timezone',
                        required     => 'nickname,email,firstname,lastname',
                        if_available => 'gender,country,language,timezone',
                    },
                ],
            },
        },
        members => {
            credential => {
                class          => 'Password',
                password_field => 'password',
                password_type  => 'none'
            },
            store => {
                class         => 'DBIx::Class',
                user_model    => 'CGC::AppUser',
                role_relation => 'roles',
                role_field    => 'role',
                # use_userdata_from_session => 0,
            }
        },

    }
};

# Force specific directories to be handled by Static::Simple.
# These should ALWAYS be served in static mode.
# This also impacts A::W::V::TT configuration.
__PACKAGE__->config(
    static => {
        dirs         => [qw/css js img tmp /],
        include_path => [ "$ENV{APP_ROOT}/tmp", __PACKAGE__->config->{root}, "$ENV{APP_ROOT}/external/bootstrap/assets"]
        #   logging  => 1,
    }
);

# Configure the application based on the type of installation.
# Application-wide configuration is located in app.conf
# which can be over-ridden by app_local.conf.
__PACKAGE__->config(
    'Plugin::ConfigLoader' => {
        file   => 'app.conf',
        driver => {
            'General' => {
                -InterPolateVars => 1,
                -ForceArray      => 0,
                # Plugin::ConfigLoader uses Config::Any[::General]
                # which ForceArray by default. We don't want that.
            },
        },
    }
) or die "$!";


__PACKAGE__->setup;


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

sub finalize_error {
    my $c = shift;
    $c->config->{'response_status'} = $c->response->status;
    $c->config->{'Plugin::ErrorCatcher'}->{'emit_module'} = [
        "Catalyst::Plugin::ErrorCatcher::Email",
        "App::Web::ErrorCatcherEmit"
    ];
    shift @{ $c->config->{'Plugin::ErrorCatcher'}->{'emit_module'} }
        unless (is_server_error($c->config->{'response_status'}));
    $c->maybe::next::method;
}

=pod

Detect if a controller request is via ajax to disable template wrapping.

=cut

sub is_ajax {
    my $c       = shift;
    my $headers = $c->req->headers;
    return $headers->header('X-Requested-With');
}


#######################################################
#
#    Helper Methods
#
#######################################################

sub secure_uri_for {
    my ($self, @args) = @_;

    my $u = $self->uri_for(@args);
    if ($self->config->{enable_ssl}) {
        $u->scheme('https');
    }
    return $u;
}

=pod

# overloaded from Per_User plugin to move saved items
sub merge_session_to_user {
    my $c = shift;

    $c->log->debug("merging guest session into per user session")
        if $c->debug;

    my $merge_behavior = Hash::Merge::get_behavior;
    my $clone_behavior = Hash::Merge::get_clone_behavior;

    Hash::Merge::set_behavior($c->config->{user_session}{merge_type});
    Hash::Merge::set_clone_behavior(0);

    my $sid  = $c->get_session_id;
    my $s_db = $c->model('CGC::AppSession')
        ->find({ session_id => "session:$sid" });
    my $uid = $c->user->user_id;

    # Instead of merging un-authenticated users,
    # we will force them to log in before adding
    # items to their cart.
#    my @user_saved = $s_db->user_saved;
#
#    my $user_items = $c->model('CGC::AppStarred')
#        ->search_rs({ session_id => "user:$uid" });
#
#    foreach my $saved_item (@user_saved) {
#        unless ($user_items->find({ page_id => $saved_item->page_id })) {
#            $saved_item->session_id("user:$uid");
#        } else {
#            $saved_item->delete();
#        }
#        $saved_item->update();
    }

    my $user_history = $c->model('CGC::ApHistory')
        ->search_rs({ session_id => "user:$uid" });
    my @save_history = $s_db->user_history;
    foreach my $s_history (@save_history) {
        my $u_history
            = $user_history->find({ page_id => $s_history->page_id });
        unless ($u_history) {
            $s_history->session_id("user:$uid");
        } else {
            $u_history->timestamp($s_history->timestamp)
                if ($u_history->timestamp < $s_history->timestamp);
            $u_history->visit_count(
                $u_history->visit_count + $s_history->visit_count);
            $s_history->delete();
            $u_history->update();
        }
        $s_history->update();
    }

    my $s = $c->session;
    my @keys
        = grep { !/^__/ } keys %$s;  # __user, __expires, etc don't apply here

    my %right;
    @right{@keys} = delete @{$s}{@keys};

    %{ $c->user_session }
        = %{ Hash::Merge::merge($c->user_session || {}, \%right) };

    Hash::Merge::set_behavior($merge_behavior);
    Hash::Merge::set_clone_behavior($clone_behavior);
}

=cut

#######################################################
#
#    TEMPLATE SELECTION
#
#######################################################

# Template assignment is a bit of a hack.
# Maybe I should just maintain
# a hash, where each field/widget lists its corresponding template
sub _select_template {
    my ($self, $render_target, $class, $type) = @_;

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
    my ($self, $class, $widget) = @_;

    my $section = $self->config->{sections}{species}{$class}
        || $self->config->{sections}{resources}{$class};

    if (ref $section eq 'ARRAY') {
        die
            "There appears to be more than one $class section in the config file\n";
    }

    # this is here to prevent a widget section from getting added to config
    unless (defined $section->{widgets}{$widget}) { return (); }

    my $fields = $section->{widgets}{$widget}{fields};
    my @fields = ref $fields eq 'ARRAY' ? @$fields : $fields // ();

    $self->log->debug(
        "The $widget widget is composed of: " . join(", ", @fields));
    return @fields;
}


=head1 NAME

Application - Generic Catalyst based application

=head1 SYNOPSIS

  script/app_server.pl -p PORT

=head1 DESCRIPTION

App - A generic Catalyst based web-application.

=head1 SEE ALSO

L<App::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Todd Harris (todd@hiline.co)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
