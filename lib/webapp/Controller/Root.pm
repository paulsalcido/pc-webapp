package webapp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

webapp::Controller::Root - Root Controller for webapp

=head1 DESCRIPTION

The root controller for webapp includes logout, contact, about, along with the main index.  Almost all of these are simply placeholders for the template files.

=head1 METHODS


=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

=head2 logout

Removes the user session information under 'member'.

=cut

sub logout :Local {
    my ( $self, $c ) = @_;
    
    if ( $c->session->{member} ) {
        delete $c->session->{member};
    }
}

=head2 contact

The contact page.

=cut

sub contact :Local {
}

=head2 about

The about page.

=cut

sub about :Local {
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Forwards to the main view (Template Toolkit/Twitter Bootstrap).

=cut

sub end :Private {
    my ( $self , $c ) = @_;

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
