package webapp::Model::WebAppDB::Schema::Result::FacebookCredentials;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("facebook_credentials");
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
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['key_name']);
__PACKAGE__->add_unique_constraint(['api_key']);
__PACKAGE__->has_many(
    'openids',
    'webapp::Model::WebAppDB::Schema::Result::OpenID',
    { 'foreign.openid' => 'self.id' },
);

1;
