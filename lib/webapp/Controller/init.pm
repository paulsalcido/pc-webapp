package webapp::Controller::init;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::init - Catalyst Controller

=head1 DESCRIPTION

Catalyst controller that allows for the initialization of the system.

WARNING: After you have completed initialization, it is strongly recommended that you remove the 'initialize' line from the configuration.

=head1 METHODS

=cut

=head2 begin

Checks to make sure that the 'initialize' configuration option is set, if it is not, forwards to root.

=cut

sub begin :Private {
    my ( $self, $c ) = @_;

    unless( $c->config->{initialize} ) {
        $c->response->status(301);
        $c->response->redirect('/');
        $c->detach;
    }
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

=head2 deploy

Deploys the schema described by the model 'WebAppDB'.

=cut

sub deploy :Local {
    my ( $self, $c ) = @_;

    if ( $c->request->params->{deploy} ) {
        $c->model('WebAppDB')->schema->deploy;
        eval {
            $c->model('WebAppDB::Role')->create({
                id => $c->uuid,
                name => 'admin',
                default_role => 'false',
            });
        };
    }
}

=head2 loginsetup

Allows the setup of the Google OpenID Secret that will be stored in the database and used for login capabilities.  You never want to check these credentials into the code base, so I figured that the database is a good alternative.

=cut

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

=head2 admin

This allows for the creation of an admin user.  Will use the login utility and forward back here (some info here is in the template).

=cut

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

=head2 end

Forwards to the main view.

=cut

sub end :Private {
    my ( $self, $c ) = @_;
    
    $c->forward( $c->view('main') );
}

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
