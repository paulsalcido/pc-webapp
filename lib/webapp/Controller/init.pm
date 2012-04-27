package webapp::Controller::init;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::init - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub begin :Private {
    my ( $self, $c ) = @_;

    unless( $c->config->{initialize} ) {
        $c->response->status(301);
        $c->response->redirect('/');
        $c->detach;
    }
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub deploy :Local {
    my ( $self, $c ) = @_;

    if ( $c->request->params->{deploy} ) {
        $c->model('WebAppDB')->schema->deploy;
        eval {
            $c->model('WebAppDB::Role')->create({
                id => $c->uuid,
                name => 'admin',
            });
        };
    }
}

sub loginsetup :Local {
    my ( $self, $c ) = @_;
    my $google_oid = undef;
    eval {
        $google_oid = $c->model('WebAppDB::OpenIDEndpoint')->find({name => 'google'});
    };
    unless ( $google_oid ) {
        if ( $c->request->params->{'google-openid-secret'} ) {
            my $newoid = $c->request->params->{'google-openid-secret'};
            if ( $google_oid && $google_oid->openid_secret ne $newoid ) {
                $google_oid->update({ openid_secret => $newoid });
            } else {
                $google_oid = $c->model('WebAppDB::OpenIDEndpoint')->create({
                    id => $c->uuid,
                    name => 'google',
                    openid_secret => $newoid,
                    endpoint => 'https://www.google.com/accounts/o8/id',
                });
            }
        }
    }
    $c->stash->{google_oid} = $google_oid;
}

sub admin :Local {
    my ( $self,$c ) = @_;

    if ( $c->session->{member} ) {
        my $role = $c->model('WebAppDB::Role')->find({
            name => 'admin',
        });
        $role->memberroles->create({
            id => $c->uuid,
            member => $c->session->{member}->{id},
            role => $role,
        });
        $c->refresh_member_session;
    } else {
        $c->session->{post_login_redirect} = "/init/admin";
    }
}

sub end :Private {
    my ( $self, $c ) = @_;
    
    $c->forward( $c->view('main') );
}

=head1 AUTHOR

Paul Salcido,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
