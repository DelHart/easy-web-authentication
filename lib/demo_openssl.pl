#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;

# test file to see if crypt::openssl::DSA is fast enough
# this module was considered as an alternative to Crypt::DSA

use Crypt::OpenSSL::DSA;

my $message = 'hartdr:34234223423';

# generate keys and write out to PEM files
my $dsa = Crypt::OpenSSL::DSA->generate_parameters(512);
say "starting generation";
$dsa->generate_key;
say "done generating";

$dsa->write_pub_key('pub.pem');
$dsa->write_priv_key('priv.pem');
say "done writing";

# using keys from PEM files
my $dsa_priv = Crypt::OpenSSL::DSA->read_priv_key('priv.pem');
say "starting signing";
my $sig = $dsa_priv->sign($message);
say "done signing $sig";
my $dsa_pub = Crypt::OpenSSL::DSA->read_pub_key('pub.pem');
say "starting verify";
my $valid = $dsa_pub->verify( $message, $sig );
say "done verify $valid";

