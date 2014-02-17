#!/usr/bin/perl:

use strict;

$\ = "\n";

package OCR;
use AI::NeuralNet::Simple;
use Imager;

require "magic_match_sticks.pl";

sub train
{
    my @sticks_list = @_;
    my $net = AI::NeuralNet::Simple->new(1, 1, 1);

    for (my $i = 0; $i < 10; $i++)
    {
        my $example_image = Imager->new;
        $example_image->read(file => "Patterns/$i/$i\_0.png")
            or die $example_image->errstr;

        my @pattern = get_magic_sticks_pattern $example_image, @sticks_list;
        print "$i pattern:";
        print join("", @pattern);
        print "----";

        $net->train([@pattern] => [$i]);
    }
    $net;
}

sub ocr
{
    my $filename = $_[0];
    $filename =~ s{.*/}{};
    $filename =~ s{\.[^.]+$}{};
    my $sticks_number = $_[1];
    my $symbols_number = $_[2];

    for (my $i = 0; $i < $symbols_number; $i++)
    {
        my $image = Imager->new;
        $image->read(file => "./Preprocessed images/$filename\_$i.png")
            or die $image->errstr;

        my @sticks_list = generate_magic_sticks_list $image->getwidth(), $image->getheight(), $sticks_number;
        my $threshold = calculate_threshold("./Preprocessed images/$filename\_$i.png");
        my @image_pattern = get_magic_sticks_pattern $image,$threshold ,@sticks_list;
        print "$filename\_$i pattern:";
        print join("", @image_pattern);
        print "----";

        my $net = train(@sticks_list);
        my $winner = $net->winner([@image_pattern]);
        print "Winner: $winner";
    }
}

ocr("1.png", 10, 1);
