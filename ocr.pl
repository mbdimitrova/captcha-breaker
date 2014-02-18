#!/usr/bin/perl:

use strict;

$\ = "\n";

use AI::NeuralNet::Simple;
use Imager;

use lib '.';
use MagicStick;
#require "symbol_separation.pl";

sub train
{
    my @sticks_list = @_;
    my $sticks_number = $#sticks_list + 1;
    my $net = AI::NeuralNet::Simple->new($sticks_number, 1, 1);

    foreach my $i (0..9) (my $i = 0; $i < 10; $i++)
    {
        my $sample_image = Imager->new;
        $sample_image->read(file => "Patterns/$i/$i\_0.png")
            or die $sample_image->errstr;

        my $threshold = calculate_threshold("Patterns/$i/$i\_0.png");
        my @pattern = get_magic_sticks_pattern ($sample_image, $threshold, @sticks_list);
        print "$i pattern:";
        print join("", @pattern);
        print "----";

        $net->iterations(1000);
        $net->learn_rate(.1);
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

        my @sticks_list = MagicStick::generate_magic_sticks_list ($image->getwidth(), $image->getheight(), $sticks_number);
        my $threshold = calculate_threshold("./Preprocessed images/$filename\_$i.png");
        my @image_pattern = get_magic_sticks_pattern ($image, $threshold, @sticks_list);
        print "$filename\_$i pattern:";
        print join("", @image_pattern);
        print "----";

        my $net = train(@sticks_list);
        print Dumper $net ;
        print Dumper $net->infer([@image_pattern]);
        my $winner = $net->winner([@image_pattern]);
        print "Winner: $winner\n";
    }
}
