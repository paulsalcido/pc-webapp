package webapp::Model::WebAppDB::Schema::Result::MemberRole;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::MemberRole

=head1 DESCRIPTION

Result Set for the cross reference table connecting:

L<webapp::Model::WebAppDB::Schema::Result::Member>
L<webapp::Model::WebAppDB::Schema::Result::Role>

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the data set 'member_role'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("member_role");

=head1 ACCESSORS

=over 4

=item id

Unique id for this role-member relationship.

=item role

The role.id.

=item member

The member.id.

=item created

The date of creation of this record.

=item deactivated

The deactivated time for this object (not used currently by webapp).

=back

=cut

__PACKAGE__->add_columns(
  "id",
  { 
    data_type => "character varying", 
    default_value => undef, 
    is_nullable => 0, 
  },
  "role",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "member",
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

=cut

=over 4

=item id (primary key)

=cut

__PACKAGE__->set_primary_key('id');

=item member, role

=cut

__PACKAGE__->add_unique_constraint(['member','role']);

=back

=cut

=head1 REFERENCES

=cut

=head2 member -> Member

L<webapp::Model::WebAppDB::Schema::Result::Member>

=cut

__PACKAGE__->belongs_to(
    'member',
    'webapp::Model::WebAppDB::Schema::Result::Member',
    { id => 'member' }
);

=head2 role -> Role

L<webapp::Model::WebAppDB::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
    'role',
    'webapp::Model::WebAppDB::Schema::Result::Role',
    { id => 'role' }
);

=head1 INDEXES

=over 4

=item role

=item member

=back

=cut

sub sqlt_deploy_hook {
    my ($self,$sqlt) = @_;
    $sqlt->add_index(fields => ['role']);
    $sqlt->add_index(fields => ['member']);
}

=head1 SEE ALSO

L<webapp>, L<DBIx>, L<webapp::Model::WebAppDB>, L<webapp::Model::WebAppDB::Schema::Result::Member>, L<webapp::Model::WebAppDB::Schema::Result::Role>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
