package webapp::Controller::login::facebook;
use Moose;
use namespace::autoclean;

use Facebook::Graph;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

foosball::Controller::openid - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

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
        $fg->request_access_token($c->request->params->{code});
        if ( $fg->access_token ) {
            $c->session->{access_token} = $fg->access_token;
        }
        my $user = $fg->fetch('me');
        warn Dumper($user);
        if ( $user ) {
            my $fba = $c->model('WebAppDB::FacebookApproval')->find({ uid => $user->{id} });
            my $member = undef;
            unless ( $fba ) {
                $member = $c->model('WebAppDB::Member')->create({
                    id => $c->uuid,
                    display_name => $user->{name},
                });
                $member->facebook_approvals->create({
                    id => $c->uuid,
                    uid => $user->{id},
                    facebook_credentials => $fb->id,
                    email => $user->{email},
                });
            } else {
                if ( $fba->email ne $user->{email} ) {
                    $fba->update({ email => $user->{email} });
                }
                $member = $fba->member;
                if ( $member->display_name ne $user->{name} ) {
                    $member->update({ display_name => $user->{name} });
                }
            }
            $c->session->{member} = {
                id => $member->id,
                display_name => $member->display_name,
            };
        }
    } 
    my $final_redirect = '/';
    if ( $c->session->{member} ) {
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

Paul Salcido,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
