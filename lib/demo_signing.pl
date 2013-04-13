#!/usr/bin/env perl

use strict;
use warnings;

# this script demonstrates signing of a message

use Crypt::DSA;
use Crypt::DSA::Key;

use Data::Dumper;

print "loading keys ... \n";
my $public = Crypt::DSA::Key->new( Filename => 'public.pem',  Type => 'PEM' );
my $priv   = Crypt::DSA::Key->new( Filename => 'private.pem', Type => 'PEM' );

my $dsa = Crypt::DSA->new;

print "signing ... \n";
my $str = $dsa->sign( Message => 'hartdr-234234242', Key => $priv );

print "printing ... \n";
print Dumper $str->serialize() . "\n";

