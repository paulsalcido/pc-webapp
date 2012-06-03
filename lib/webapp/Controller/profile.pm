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

    my $member = undef;
    if ( $c->session->{member} && $c->session->{member}->{id} ) {
        $member = $c->model('WebAppDB::Member')->find({ id => $c->session->{member}->{id} });
    }
    $c->stash->{member} = $member;
}

sub view :Local :Args(1) {
    my ( $self, $c ) = @_;

    $c->stash->{member} = $c->model('WebAppDB::Member')->find({ id => $c->request->arguments->[0] });
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
