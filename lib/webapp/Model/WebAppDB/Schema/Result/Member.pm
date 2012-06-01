package webapp::Model::WebAppDB::Schema::Result::Member;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::Member;

=head1 DESCRIPTION

This ResultSet (L<DBIx>) contains routines for the storage of member information for this application.  This class could be extended with additional information for future web applications.

If you are looking at improving member data, then this is a good starting point.  As far as webapp is concerned, what is here is good.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the data set 'member'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("member");

=head1 ACCESSORS

=over

=item id

The distinct uuid for this member.

=item display_name

The display name of this member.

=item created

The date this member was created.

=item deactivated

The date this member was deactivated (not currently used by webapp).

=back

=cut

__PACKAGE__->add_columns(
  "id",
  { 
    data_type => "character varying", 
    default_value => undef, 
    is_nullable => 0, 
  },
  "display_name",
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

=back

=cut

__PACKAGE__->set_primary_key('id');

=head1 REFERENCES

=cut

=head2 memberroles -> MemberRole

L<webapp::Model::WebAppDB::Schema::Result::MemberRole>

=cut

__PACKAGE__->has_many(
    'memberroles',
    'webapp::Model::WebAppDB::Schema::Result::MemberRole',
    { 'foreign.member' => 'self.id' }
);

=head2 facebook_approvals -> FacebookApproval

L<webapp::Model::WebAppDB::Schema::Result::FacebookApproval>

=cut

__PACKAGE__->has_many(
    'facebook_approvals',
    'webapp::Model::WebAppDB::Schema::Result::FacebookApproval',
    { 'foreign.member' => 'self.id' }
);

=head2 openids -> OpenID

L<webapp::Model::WebAppDB::Schema::Result::OpenID>

=cut

__PACKAGE__->has_many(
    'openids',
    'webapp::Model::WebAppDB::Schema::Result::OpenID',
    { 'foreign.member' => 'self.id' }
);

=head1 SEE ALSO

L<webapp::Model::WebAppDB>,L<webapp::Model::WebAppDB::Schema::Result::FacebookApproval>,L<webapp::Model::WebAppDB::Schema::Result::OpenID>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


# You can replace this text with custom content, and it will be preserved on regeneration
1;
