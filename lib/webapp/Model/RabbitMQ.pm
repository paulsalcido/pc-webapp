package webapp::Model::RabbitMQ;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

webapp::Model::RabbitMQ - Catalyst Model

=head1 DESCRIPTION

Catalyst Model for handling requests to RabbitMQ and maintaining a good connection for realtime analytics.

=head2 rmq

A configured rabbitmq instance.  If undef, then don't use.

Expected configuration:

    'Net::RabbitMQ' => {
        connect => {
            host => '...'
            options => {
                user => ...,            #default 'guest'
                password => ...,        #default 'guest'
                port => ...,            #default 5672
                vhost => ...,           #default '/'
                channel_max => ...,     #default 0
                frame_max => ...,       #default 131072
                heartbeat => ...,       #default 0
            }
        },
        channel => 1,
        exchange_declare => [
            { 
                channel => 1,
                name => ...,
                options => {
                    exchange_type => ...,   #default 'direct'
                    passive => ...,         #default 0
                    durable => ...,         #default 0
                    auto_delete => ...,     #default 1
                },
            },
            ...
        ],
        pageview_exchange => '...'
    };

There is an example configuration commented out in the webapp.conf file.

=cut

# TODO: This is a fucking mess.  Clean this shit up.

has 'connect' => ( is => 'ro' );
has 'channel' => ( is => 'ro' );
has 'exchange_declare' => ( is => 'ro' );
has 'pageview_exchange' => ( is => 'ro' );

has '_rmq' => ( is => 'ro' , lazy => 1 , builder => '_build_rmq' );

sub _build_rmq {
    my $self = shift;
    my $rmq = undef;
    warn "Rebuilding RabbitMQ";
    if ( $self->connect ) {
        eval 'use Net::RabbitMQ';
        if ( $@ ) {
            warn('Could not configure RabbitMQ: '.$@);
        } else {
            warn('Preparing RabbitMQ');
            warn('Connecting to host: '.$self->connect->{host});
            eval {
                $rmq = Net::RabbitMQ->new();
                $rmq->connect($self->connect->{host},$self->connect->{options});
            };

            if ( $@ ) {
                warn $@;
                $rmq = undef;
            }
            if ( $rmq ) {
                warn('Opening channel: '.$self->channel);
                $rmq->channel_open($self->channel);
                my $ed = $self->exchange_declare;
                if ( ref $ed ) {
                    if ( ref $ed eq 'HASH' ) {
                        $ed = [ $ed ];
                    }
                    if ( ref $ed eq 'ARRAY' ) {
                        foreach my $dec ( @{$ed} ) {
                            warn('Declaring Exchange '.$dec->{name}.' in channel '.$dec->{channel});
                            $rmq->exchange_declare($dec->{channel},$dec->{name},$dec->{options});
                        }
                    }
                }
            } else {
                warn('Could not connect RabbitMQ to host.');
            }
        }
    }
    return $rmq;
}

=head1 SUBROUTINES

=cut

=head2 publish_pageview({ routing_key => ... , c => $c })

Requires that you send the catalyst $c object, so that it can derive information from it.

This will publish a page view to the pageview_exchange.  For more information about routing keys, read the documentation on rabbbitmq.

=cut

sub publish_pageview {
    my $self = shift;
    my $p = shift;
    my $c = $p->{c};
    if ( $c && $self->_rmq ) {
        my $message = { 
            'member' => $c->session->{member} ? $c->session->{member}->{id} : undef,
            'page' => $c->request->path,
        };
        $self->_rmq->publish($self->channel,
            $p->{routing_key},
            JSON::encode_json($message),
            { exchange => $self->pageview_exchange }
        );
    }
}

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
