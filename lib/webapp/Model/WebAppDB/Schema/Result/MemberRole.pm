package webapp::Model::WebAppDB::Schema::Result::MemberRole;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("member_role");
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
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['member','role']);

__PACKAGE__->belongs_to(
    'member',
    'webapp::Model::WebAppDB::Schema::Result::Member',
    { id => 'member' }
);
__PACKAGE__->belongs_to(
    'role',
    'webapp::Model::WebAppDB::Schema::Result::Role',
    { id => 'role' }
);

sub sqlt_deploy_hook {
    my ($self,$sqlt) = @_;
    $sqlt->add_index(fields => ['role']);
    $sqlt->add_index(fields => ['member']);
}

1;
