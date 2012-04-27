package webapp::Controller::login::google;
use Moose;
use namespace::autoclean;

use Net::OpenID::Consumer;
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
    my $google_oid = $c->model('WebAppDB::OpenIDEndpoint')->find({
        name => 'google'
    });
       
    my $oid = Net::OpenID::Consumer->new(
        ua => LWP::UserAgent->new,
        required_root => $c->request->base,
        consumer_secret => $google_oid->openid_secret,
    );
    my $cid = $oid->claimed_identity($google_oid->endpoint);
    if ( $cid ) {
        $cid->set_extension_args(
            'http://openid.net/srv/ax/1.0',
            {
                required => 'email,firstname,lastname',
                mode => 'fetch_request',
                'type.email' => 'http://axschema.org/contact/email',
                'type.firstname' => 'http://axschema.org/namePerson/first',
                'type.lastname' => 'http://axschema.org/namePerson/last',
            },
        );
        my $redurl = $cid->check_url(
            return_to => $c->request->base.'/login/google/check',
            trust_root => $c->request->base,
            delayed_return => 1,
        );
        $redurl =~ s/\.e1([\=\.])/.ax$1/g;
        $c->log->info('Redirect url: '.$redurl);
        $c->response->redirect($redurl);
        $c->detach;
        return;
    }
    $c->stash->{cid} = $cid;
}

sub check :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $google_oid = $c->model('WebAppDB::OpenIDEndpoint')->find({name => 'google'});
    
    my $oid = Net::OpenID::Consumer->new(
        ua => LWP::UserAgent->new,
        required_root => $c->request->base,
        consumer_secret => $google_oid->openid_secret,
        args => $c->request->params,
    );
    $oid->handle_server_response(
        not_openid => sub {
            $c->log->info("not_openid");
        },
        setup_required => sub {
            my $setup_url = shift;
            $c->log->info("setup_required $setup_url");
            $c->response->redirect($setup_url);
            $c->detach;
        },
        cancelled => sub {
            $c->log->info("cancelled");
        },
        verified => sub {
            my $vident = shift;
            my $items = $vident->signed_extension_fields('http://openid.net/srv/ax/1.0');
            my $fullname = undef;
            my $email = undef;
            my $identity = $vident->url;
            if ( $items->{'value.fullname'} ) {
                $fullname = $items->{'value.fullname'};
            } elsif ( $items->{'value.firstname'} && $items->{'value.lastname'} ) {
                $fullname = $items->{'value.firstname'} . ' ' . $items->{'value.lastname'};
            }
            if ( $items->{'value.email'} ) {
                $email = $items->{'value.email'};
            }
            my $oid = $c->model('WebAppDB::OpenID')->find({
                email => $email,
                openid_endpoint => $google_oid->id,
            });
            my $member;
            unless ( $oid ) {
                $c->model('WebAppDB')->schema->txn_do(sub{
                    $member = $c->model('WebAppDB::Member')->create({
                        id => $c->uuid,
                        display_name => $fullname,
                    });
                    $oid = $member->openids->create({
                        id => $c->uuid,
                        identity => $identity,
                        openid_endpoint => $google_oid->id,
                        email => $email,
                    });
                });
            } else {
                $member = $oid->member;
            }
            if ( $oid->identity ne $identity ) { 
                $oid->update({identity => $identity});
            }
            if ( $member->display_name ne $fullname) {
                $member->update({display_name => $fullname});
            }
            $c->stash->{member} = $member;
            $c->session->{member} = {
                id => $member->id,
                display_name => $member->display_name,
            };
        },
        error => sub {
            my $err = shift;
            $c->log->info("error $err");
        },
    );
    $c->response->redirect('/');
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
