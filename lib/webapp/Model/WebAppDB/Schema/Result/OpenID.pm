package webapp::Model::WebAppDB::Schema::Result::OpenID;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::OpenID

=head1 DESCRIPTION

This is a L<DBIx> result class representing an OpenID Identity.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the data set 'openid'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("openid");

=head1 ACCESSORS

=over 4

=item id

The id for this item.

=item member

The member id that this identity refers to.

=item identity

The actual identity endpoint returned by the server.

=item openid_endpoint

The openid_endpoint object in the database.

=item email

The email returned by the server.

=item created

The date this was created.

=item deactivated

The deactivated date (not used by the application webapp).

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
  "identity",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "openid_endpoint",
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

=cut

=over 4

=item id

=cut

__PACKAGE__->set_primary_key('id');

=item member, openid_endpoint

=cut

__PACKAGE__->add_unique_constraint(['member','openid_endpoint']);

=item email

=cut

__PACKAGE__->add_unique_constraint(['email']);

=back

=cut

=head1 REFERENCES

=head2 member -> Member

L<webapp::Model::WebAppDB::Schema::Result::Member>

=cut

__PACKAGE__->belongs_to(
    'member',
    'webapp::Model::WebAppDB::Schema::Result::Member',
    { id => 'member' }
);

=head2 openid_endpoint -> OpenIDEndpoint

L<webapp::Model::WebAppDB::Schema::Result::OpenIDEndpoint>

=cut

__PACKAGE__->belongs_to(
    'openid_endpoint',
    'webapp::Model::WebAppDB::Schema::Result::OpenIDEndpoint',
    { id => 'openid_endpoint' }
);

=head1 ADDITIONAL INDEXES

=over 4

=item openid_endpoint

=item identity

=item member

=back

=cut

sub sqlt_deploy_hook {
    my ($self,$sqlt) = @_;
    $sqlt->add_index(fields => ['openid_endpoint']);
    $sqlt->add_index(fields => ['identity']);
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
