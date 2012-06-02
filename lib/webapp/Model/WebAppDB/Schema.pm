package webapp::Model::WebAppDB::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use namespace::autoclean;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-04-26 16:34:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dL/MWlwqMV1j+q9RqPkoKA

=head1 NAME

webapp::Model::WebAppDB::Schema

=head1 DESCRIPTION

This is the original schema for webapp.

=head1 SEE ALSO

L<webapp>, L<webapp::Model::WebAppDB>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
