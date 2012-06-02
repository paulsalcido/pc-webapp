package webapp::Controller::login::facebook;
use Moose;
use namespace::autoclean;

use Facebook::Graph;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::login::facebook - Catalyst Controller

=head1 DESCRIPTION

This contains methods for logging in with facebook.

=head1 METHODS

=cut

=head2 index

Pulls up facebook credentials, then tries to use permission extensions to get the current user email, and redirects to the facebook login page with the request for the email.

Request for information from facebook:

=over 4

=item basic information

=item email

=back

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $fb = $c->model('WebAppDB::FacebookCredentials')->find({
        key_name => $c->config->{name},
    });

    if ( $fb ) {
        my $fg = Facebook::Graph->new(
            app_id => $fb->api_key,
            secret => $fb->api_secret,
            postback => $c->request->base . '/login/facebook/check',
        );

        my $uri = $fg->authorize->extend_permissions(qw/email/)->uri_as_string;

        $c->response->redirect($uri);
        $c->detach;
    }
}

=head2 check

This does the official 'check' for facebook information on response, and creates the user if they don't exist, or logs them in if they do.

=cut

sub check :Local {
    my ( $self, $c ) = @_;
    my $fb = $c->model('WebAppDB::FacebookCredentials')->find({
        key_name => $c->config->{name},
    });
    if ( $fb ) {
        my $fg = Facebook::Graph->new(
            app_id => $fb->api_key,
            secret => $fb->api_secret,
            postback => $c->request->base . '/login/facebook/check',
        );
        # Get back the access token
        $fg->request_access_token($c->request->params->{code});
        if ( $fg->access_token ) {
            $c->session->{access_token} = $fg->access_token;
        }
        # Get the user information.
        my $user = $fg->fetch('me');
        warn Dumper($user);
        if ( $user ) {
            # Find this user in the facebook approval table...
            my $fba = $c->model('WebAppDB::FacebookApproval')->find({ uid => $user->{id} });
            my $member = undef;
            unless ( $fba ) {
                # Create a new member if one doesn't already exist.
                $member = $c->model('WebAppDB::Member')->create({
                    id => $c->uuid,
                    display_name => $user->{name},
                });
                $member->add_default_roles({ c => $c });
                $member->facebook_approvals->create({
                    id => $c->uuid,
                    uid => $user->{id},
                    facebook_credentials => $fb->id,
                    email => $user->{email},
                });
            } else {
                # Update the new member email if it is different if the user already exists.
                if ( $fba->email ne $user->{email} ) {
                    $fba->update({ email => $user->{email} });
                }
                $member = $fba->member;
                if ( $member->display_name ne $user->{name} ) {
                    $member->update({ display_name => $user->{name} });
                }
            }
            # Push initial member session information before the call to refresh.
            $c->session->{member} = {
                id => $member->id,
                display_name => $member->display_name,
            };
        }
    } 
    my $final_redirect = '/';
    if ( $c->session->{member} ) {
        # Send to the appropriate redirect if one was requested.
        if ( $c->session->{post_login_redirect} ) {
            $final_redirect = $c->session->{post_login_redirect};
            delete $c->session->{post_login_redirect};
        }
        $c->refresh_member_session;
    }
    $c->response->redirect($final_redirect);
    $c->detach;
}

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
