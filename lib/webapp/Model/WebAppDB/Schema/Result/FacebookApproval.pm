package webapp::Model::WebAppDB::Schema::Result::FacebookApproval;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::FacebookApproval;

=head1 DESCRIPTION

This ResultSet (L<DBIx>) contains routines for the storage of facebook approval information, based on the Facebook Graph model.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the data set 'facebook_approval'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("facebook_approval");

=head1 ACCESSORS

=over 4

=item id

Contains the uuid for this item.  Should be set by the application.

=item member

References the member in the database.

=item uid

The facebook user id.

=item facebook_credentials

The internal facebook graph credentials used to get the user information.

=item email

The email address for the user (from facebook).

=item created

The date that this entry was created.

=item deactivated

A deactivated date.  Not currently used by the application.

=back

=cut

__PACKAGE__->add_columns(
  "id",
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
  "uid",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "facebook_credentials",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "email",
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

=item member, facebook_credentials

=cut

__PACKAGE__->add_unique_constraint(['member','facebook_credentials']);

=item email

=cut

__PACKAGE__->add_unique_constraint(['email']);

=item uid

=cut 

__PACKAGE__->add_unique_constraint(['uid']);

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

=head2 facebook_credentials -> FacebookCredentials

L<webapp::Model::WebAppDB::Schema::Result::FacebookCredentials>

=cut

__PACKAGE__->belongs_to(
    'facebook_credentials',
    'webapp::Model::WebAppDB::Schema::Result::FacebookCredentials',
    { id => 'facebook_credentials' }
);

=head1 INDEXES

=over 4

=item member

=back

=cut

sub sqlt_deploy_hook {
    my ($self,$sqlt) = @_;
    $sqlt->add_index(fields => ['member']);
}

=head1 SEE ALSO

L<webapp>, L<DBIx>, L<webapp::Model::WebAppDB>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
