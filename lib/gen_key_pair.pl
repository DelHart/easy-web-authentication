#!/usr/bin/env perl

use strict;
use warnings;

# use this script to generate the web application private/public key pair

use Crypt::DSA;

my $dsa = Crypt::DSA->new;

my $key = $dsa->keygen( Size => 512, Verbosity => 1 );

$key->write( Type => 'PEM', 'Filename' => 'private.pem' );
$key->{'priv_key'} = undef;
$key->write( Type => 'PEM', 'Filename' => 'public.pem' );

