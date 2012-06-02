package webapp::Model::WebAppDB::Schema::Result::FacebookCredentials;

=head1 NAME

webapp::Model::WebAppDB::Schema::Result::FacebookCredentials;

=head1 DESCRIPTION

This ResultSet (L<DBIx>) contains routines for the storage facebook credential information, which is specific to your application.  This will be set by an administrator before logins with Facebook can happen.  You will need to look into the Facebook Developer Application.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

=head1 TABLE

This represents the data set "facebook_credentials".

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("facebook_credentials");

=head1 ACCESSORS

=over 4

=item id

An internal uuid for the use of this object.

=item app_name

The application name passed to facebook.

=item api_key

The api key from the facebook developer app.

=item api_secret

The api secred from the facebook developer app.

=item key_name

The name of this key, internal to web app.

=item created

The date this object was created.

=item deactivated

Internal - date of deactivation, not yet recognized by app.

=back

=cut

__PACKAGE__->add_columns(
  "id",
  { 
    data_type => "character varying", 
    default_value => undef, 
    is_nullable => 0, 
  },
  "app_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "api_key",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "api_secret",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
  },
  "key_name",
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

=item id

=cut

__PACKAGE__->set_primary_key('id');

=item key_name

=cut

__PACKAGE__->add_unique_constraint(['key_name']);

=item api_key

=cut

__PACKAGE__->add_unique_constraint(['api_key']);

=back

=cut

=head1 SEE ALSO

L<webapp::Model::WebAppDB::Schema::Result::FacebookApproval>, L<webapp>, L<DBIx>, L<webapp::Model::WebAppDB>

=head1 AUTHOR

Paul Salcido,paulsalcido.79@gmail.com,Twitter: @PaulCodeMonkey

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
