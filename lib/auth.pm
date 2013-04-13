package auth;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# student sign-on comments ------------------
# the only thing that may need to be modified in this file is to change which user_ fields are used
# there may be a performance difference between different ldap implementations, notable openLDAP and Active Directory
# 
# this file also uses four environment variables that must be set for the server to run
# 
#-----------------

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    Authentication
    ConfigLoader
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in auth.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

=examples

             store => {
               # binddn              => your username on the ldap server
               # bindpw              => your password on the ldap server
               # ldap_server         => the ip address of the ldap server
               # user_basedn         => the base domain name for the user accounts that you are authenticating against
                 binddn              => $ENV{'LDAPUSER'},
                 bindpw              => $ENV{'LDAPPASS'},
                 ldap_server         => $ENV{'LDAPSERV'},
                 user_basedn         => $ENV{'LDAPBASE'},
               class               => "LDAP",
               ldap_server_options => { timeout => 30 },
               #role_basedn         => "ou=groups,ou=OxObjects,dc=yourcompany,dc=com",
               #role_field          => "uid",
               #role_filter         => "(&(objectClass=posixGroup)(memberUid=%s))",
               #role_scope          => "one",
               #role_search_options => { deref => "always" },
               #role_value          => "dn",
               #role_search_as_user => 0,
               start_tls           => 0,
               start_tls_options   => { verify => "none" },
               entry_class         => "Net::LDAP::Entry",
               use_roles           => 0,
         # these user_ fields are better for open ldap
               #user_field          => "uid",
               #user_filter         => "(&(objectClass=user)(uid=%s))",
               #user_scope          => "one",
         # these user_ fields are better for active driectory
               user_field          => "samaccountname",
               user_filter         => "(sAMAccountName=%s)",
               user_scope          => "sub",
               user_search_options => { deref => "always" },
               user_results_filter => sub { return shift->pop_entry },
             },

=cut

__PACKAGE__->config(
    name => 'auth',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
      'authentication' => {
         default_realm => "auth",
         realms => {
           auth => {
             credential => {
               class => "Password",
               password_field => "password",
               password_type => "self_check",
             },
		store => {
                                class => 'Minimal',
                                users => {
                                    del => {
                                        password => "password",
                                        editor => 'yes',
                                        roles => [qw/edit delete/],
                                    },
                                    guest => {
                                        password => "guest",
                                        roles => [qw/comment/],
                                    },
	},
	},
           },
         },
       },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

auth - Catalyst based application

=head1 SYNOPSIS

    script/auth_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<auth::Controller::Root>, L<Catalyst>

=head1 AUTHOR

del,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

