package webapp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use UUID;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Session
    Session::Store::Memcached
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in webapp.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'webapp',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

# Start the application
__PACKAGE__->setup();

=head1 NAME

webapp - Catalyst based application

=head1 SYNOPSIS

    script/webapp_server.pl

=head1 DESCRIPTION

This is a base webapp for use in my application development.  I've included facebook and google openid login capabilities, and put in a front end using template toolkit and twitter bootstrap for html/css work.

=head1 EXPANDED FUNCTIONALITY

=head2 uuid

    my $uuid = $c->uuid;

This subroutine is used to produce new uuids for the application database entries.

=cut

sub uuid {
    my ($str,$uuid) = ();
    UUID::generate($str);
    UUID::unparse($str,$uuid);
    return $uuid;
}

=head2 refresh_member_session

    $c->session->{member}->{id} = '...';
    $c->refresh_member_session;

This will fill in additional member session information based off of the current session member.id.

=cut

sub refresh_member_session {
    my ($self) = @_;
    my $id = $self->session->{member}->{id};
    my $member = $self->model('WebAppDB::Member')->find({ id => $id });
    delete $self->session->{member}->{roles} if ( $self->session->{member}->{roles} );
    foreach my $mr ( $member->memberroles ) {
        $self->session->{member}->{roles}->{$mr->role->name} = 1;
    }
}

=head1 SEE ALSO

L<webapp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Paul Salcido, paulsalcido.79@gmail.com

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
