#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'webapp';
all_from 'lib/webapp.pm';

requires 'Catalyst::Runtime' => '5.80032';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'MooseX::NonMoose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires "Catalyst::View::TT";
requires "Catalyst::Model::DBIC::Schema";
requires "DBD::Pg";
requires "DateTime::Format::Pg";
requires "UUID::Tiny";
requires "Net::OpenID::Consumer";
requires "Catalyst::Plugin::Session::Store::Memcached";
requires "Catalyst::Plugin::Session::State::Cookie";
requires "Net::RabbitMQ"; # This is actually optional.

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
