package auth::Controller::login;
use Moose;
use namespace::autoclean;
use CGI::Simple::Cookie;
use Crypt::OpenSSL::DSA;

# student sign-on comments ------------------
# this file uses the PRIVKEY, LDAPBASE
#-----------------

our $DEFAULT_HOST =  'www.cs.plattsburgh.edu';
our $DEFAULT_PORT =  '8000';
our $DEFAULT_PAGE =  'dash';
our $AUTH_DOMAIN  =  '.cs.plattsburgh.edu';
our $COOKIE_LIFE  = '+4M';

our $dsa_priv;

BEGIN {
    extends 'Catalyst::Controller';
    $dsa_priv = Crypt::OpenSSL::DSA->read_priv_key( $ENV{'PRIVKEY'});
}

=head1 NAME

ldap::Controller::login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

# the host, port, and dest arguments describe where the user should be redirected to after setting their cookie up
sub index : Path : Args(3) {
    my ( $self, $c, $host, $port, $dest ) = @_;

    # Get the username and password from form
    my $username = $c->request->params->{username} || "";
    my $password = $c->request->params->{password} || "";

    # If the username and password values were found in form
    if ( $username && $password ) {

        # Attempt to log the user in
        if ( $c->authenticate( { id => $username, password => $password } ) ) {
            $c->log->debug(
                "logged in with $username");

            $c->stash->{'host'} = $host || $DEFAULT_HOST;
            $c->stash->{'port'} = $port || $DEFAULT_PORT;
            $c->stash->{'dest'} = $dest || $DEFAULT_PAGE;

            $c->stash->{'template'} = 'redirect.tt';

            my $t       = time();
            my $message = "$username-$t";
            my $sig     = $dsa_priv->sign($message);
            my $encoded = unpack( 'H*', $sig );

            $c->response->cookies->{csauth} = {
                value     => "$message",
                domain    => $AUTH_DOMAIN,
                'expires' => $COOKIE_LIFE
            };
            $c->response->cookies->{cssig} = {
                value     => "$encoded",
                domain    => $AUTH_DOMAIN,
                'expires' => $COOKIE_LIFE
            };

            # redirect to destination
            $c->view('TT');

            return;
        }
        else {

            # Set an error message
            $c->log->debug(
                "did not log in with $username");
            $c->stash->{error_msg} = "Bad username or password.";
        }
    }

    # If either of above don't work out, send to the login page
    $c->stash->{template} = 'login.tt';
    $c->view('TT');

}

# provide the default values, would not be used in normal usage
sub basic : Chained('/') : PathPart('login') : Args(0) {
    my ( $self, $c ) = @_;

    $c->detach ('auth::Controller::login', 'index', [ $DEFAULT_HOST, $DEFAULT_PORT, $DEFAULT_PAGE ]);

}    # basic

# show what the cookies look like
sub status : Chained('/') : PathPart('status') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'csauth'} = $c->request->cookies->{csauth};
    $c->stash->{'cssig'}  = $c->request->cookies->{cssig};

    $c->stash->{template} = 'status.tt';
    $c->view('TT');
}    # status

# method to return the public key that corresponds to the private key

=head1 AUTHOR

Del Hart,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

