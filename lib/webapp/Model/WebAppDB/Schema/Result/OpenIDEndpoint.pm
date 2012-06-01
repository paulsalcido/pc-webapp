package webapp::Model::WebAppDB::Schema::Result::OpenIDEndpoint;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::OpenIDEndpoint

=head1 DESCRIPTION

This is a L<DBIx> result class representing data for openid endpoints.  Currently, only google is represented by the app, but that could be expanded, but the data source would have to be made aware of how attribute exchange is different for each one.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the result set 'openid_endpoint'.

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("openid_endpoint");

=head1 ACCESSORS

=over 4

=item id

Distinct uuid for the current object.

=item endpoint

Endpoint url.

=item openid_secred

Internal secret passed to openid.

=item name

Internal name of this openid entry.

=item created

timestamp for creation of current record.

=item deactivated

timestamp for deactivation of current record (not used by L<webapp>).

=back

=cut

__PACKAGE__->add_columns(
  "id",
  { 
    data_type => "character varying", 
    default_value => undef, 
    is_nullable => 0, 
  },
  "endpoint",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "openid_secret",
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

=item endpoint

=cut

__PACKAGE__->add_unique_constraint(['endpoint']);

=item name

=cut

__PACKAGE__->add_unique_constraint(['name']);

=back

=cut

=head1 REFERENCES

=cut

=head2 openids -> OpenID

L<webapp::Model::WebAppDB::Schema::Result::OpenID>

=cut

__PACKAGE__->has_many(
    'openids',
    'webapp::Model::WebAppDB::Schema::Result::OpenID',
    { 'foreign.openid' => 'self.id' },
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
