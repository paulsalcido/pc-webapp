package webapp::Controller::profile;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

webapp::Controller::profile - Catalyst Controller

=head1 DESCRIPTION

This allows a person to view their profile.

TODO: Build profile information output.

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub end :Private {
    my ($self , $c ) = @_;
    $c->forward($c->view('main'));
}

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
