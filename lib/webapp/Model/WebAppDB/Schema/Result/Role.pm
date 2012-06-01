package webapp::Model::WebAppDB::Schema::Result::Role;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::Role

=head1 DESCRIPTION

This model result set class represents roles in the database.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This class represents the data set 'role'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("role");

=head1 ACCESSORS

=over 4

=item id

This represents the unique id (uuid) of the current row.

=item name

This represents the name of the role.

=item created

The date this role was created.

=item deactivated

The date this role was deactivated.

=back

=cut

__PACKAGE__->add_columns(
  "id",
  { 
    data_type => "character varying", 
    default_value => undef, 
    is_nullable => 0, 
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "created",
  {
    data_type => "timestamp with time zone",
    default_value => \"now()",
    is_nullable => 0,
    size => 8,
  },
  "deactivated",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);

=head1 UNIQUE CONSTRAINTS

=over 4

=item id (primary key)

=cut

__PACKAGE__->set_primary_key('id');

=item name

=cut

__PACKAGE__->add_unique_constraint(['name']);

=back

=cut

=head1 REFERENCES

=cut

=head2 memberroles -> MemberRole

L<webapp::Model::WebAppDB::Schema::Result::MemberRole>

=cut

__PACKAGE__->has_many(
    'memberroles',
    'webapp::Model::WebAppDB::Schema::Result::MemberRole',
    { 'foreign.role' => 'self.id' }
);

=head1 SEE ALSO

L<webapp>, L<DBIx>, L<webapp::Model::WebAppDB>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
