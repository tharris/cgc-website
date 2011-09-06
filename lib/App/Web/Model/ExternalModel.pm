package App::Web::Model::ExternalModel;
use parent qw/Catalyst::Model::Adaptor/;

# Generically glue our App to an external model.

#use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  
  # Mangle external model arguments provided in configuration.
  my $args     = $c->config->{'Model::ExternalModel'}->{args};
  $args->{log} = $c->log;
  return $args;
}


1;
