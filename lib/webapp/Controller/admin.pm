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

sub deploy :Local {
    my ( $self, $c ) = @_;
    $c->model('WebAppDB')->schema->deploy;
    #$c->stash->{deployment_statements} = [ $c->model('WebAppDB')->schema->deployment_statements ];
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
