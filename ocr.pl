#!/usr/bin/perl:

use strict;
use AI::NeuralNet::Simple;
use Imager;

require "magic_match_sticks.pl";

$\ = "\n";

my $net = AI::NeuralNet::Simple->new(1, 1, 1);
my $image = Imager->new;
$image->read(file => "Preprocessed images/1_1.png")
    or die $image->errstr;

my @sticks_list = generate_magic_sticks_list $image->getwidth(), $image->getheight(), 20;

for (my $i = 0; $i < 10; $i++)
{
    my $example_image = Imager->new;
    $example_image->read(file => "Patterns/$i/$i\_0.png")
        or die $example_image->errstr;
    my @pattern = get_magic_sticks_pattern $example_image, @sticks_list;
    print "$i pattern:";
    print join("", @pattern);
    print "\n----\n";
}
