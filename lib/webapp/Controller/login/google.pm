package webapp::Controller::login::google;
use Moose;
use namespace::autoclean;

use Net::OpenID::Consumer;
use Data::Dumper;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::login::google - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

Forwards to the end point.

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
        # requrests specific items using auth naming extensions.
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
        # Return to check url.
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

=head2 check

This finalizes the google user and adds them to the database, or logs in an existing user (with a small update).

=cut

# TODO: Subroutines of this length are not acceptable, time to start a refactor.

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
            # This means that we have a successful login.  Pull necessary information and 
            # create the user.
            my $vident = shift;
            my $items = $vident->signed_extension_fields('http://openid.net/srv/ax/1.0');
            my $fullname = undef;
            my $email = undef;
            # Pull the necessary identity information for our data fields.
            my $identity = $vident->url;
            if ( $items->{'value.fullname'} ) {
                $fullname = $items->{'value.fullname'};
            } elsif ( $items->{'value.firstname'} && $items->{'value.lastname'} ) {
                $fullname = $items->{'value.firstname'} . ' ' . $items->{'value.lastname'};
            }
            if ( $items->{'value.email'} ) {
                $email = $items->{'value.email'};
            }
            # Find the openid object.
            my $oid = $c->model('WebAppDB::OpenID')->find({
                email => $email,
                openid_endpoint => $google_oid->id,
            });
            my $member;
            unless ( $oid ) {
                # Create the member and openid entries if they don't already exist.
                $c->model('WebAppDB')->schema->txn_do(sub{
                    $member = $c->model('WebAppDB::Member')->create({
                        id => $c->uuid,
                        display_name => $fullname,
                    });
                    $member->add_default_roles({ c => $c });
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
            # Otherwise, time to update some stuff.
            # An important note: If anything changes with an identity or login model/url
            # etc., the identity that google will send back will be different, but the email
            # will stay the same.  We thus keep the email as the secondary key, and update
            # the identity here.
            if ( $oid->identity ne $identity ) { 
                $oid->update({identity => $identity});
            }
            if ( $member->display_name ne $fullname) {
                $member->update({display_name => $fullname});
            }
            # Store up the necessary member data in the session before the refresh.
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
    my $final_redirect = '/';
    # Do the necessary redirects.
    if ( $c->session->{member} ) {
        if ( $c->session->{post_login_redirect} ) {
            $final_redirect = $c->session->{post_login_redirect};
            delete $c->session->{post_login_redirect};
        }
        #Refresh the member session.
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
