package webapp::Model::WebAppDB::Schema::Result::OpenID;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("openid");
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
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['member','openid_endpoint']);
__PACKAGE__->add_unique_constraint(['email']);

__PACKAGE__->belongs_to(
    'member',
    'webapp::Model::WebAppDB::Schema::Result::Member',
    { id => 'member' }
);
__PACKAGE__->belongs_to(
    'member',
    'webapp::Model::WebAppDB::Schema::Result::OpenIDEndpoint',
    { id => 'openid_endpoint' }
);

sub sqlt_deploy_hook {
    my ($self,$sqlt) = @_;
    $sqlt->add_index(fields => ['openid_endpoint']);
    $sqlt->add_index(fields => ['identity']);
    $sqlt->add_index(fields => ['member']);
}

1;
