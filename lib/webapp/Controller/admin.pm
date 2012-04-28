package webapp::Controller::admin;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub loginsetup :Local {
    my ( $self, $c ) = @_;
    my $webapp = $c->config->{name};
    my $google_oid = $c->model('WebAppDB::OpenIDEndpoint')->find({name => 'google'});
    my $facebook_cred = $c->model('WebAppDB::FacebookCredentials')->find({ key_name => $webapp });
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
    } elsif ( $c->request->params->{'facebook-app-key'} ) {
        my $newappname = $c->request->params->{'facebook-app-name'};
        my $newappkey = $c->request->params->{'facebook-app-key'};
        my $newappsecret = $c->request->params->{'facebook-app-secret'};
        if ( $facebook_cred ) {
            $facebook_cred->update({ 
                app_name => $newappname,
                api_key => $newappkey,
                api_secret => $newappsecret,
                key_name => $webapp,
            });
        } else {
            $facebook_cred = $c->model('WebAppDB::FacebookCredentials')->create({
                id => $c->uuid,
                key_name => $webapp,
                app_name => $newappname,
                api_key => $newappkey,
                api_secret => $newappsecret,
            });
        }
    }
    $c->stash->{google_oid} = $google_oid;
    $c->stash->{facebook_credentials} = $facebook_cred;
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
