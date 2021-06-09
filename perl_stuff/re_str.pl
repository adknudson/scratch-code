#!/usr/bin/perl

use strict;
use warnings;

use String::Random qw/random_regex/;

my $reps   = $ARGV[0];
my $re_str = $ARGV[1];

my @a = (1..$reps);
for(@a){
    print random_regex($re_str), "\n";
}
