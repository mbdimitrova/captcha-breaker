#!/usr/bin/perl

use strict;
use Imager;
use Data::Dumper;

$\ = "\n";

sub separate_symbols
{

#reading the image
    my $image = Imager->new;
    $image->read(file => "Preprocessed images/$_[0]")
	    or die $image->errstr;
    my $filename = $_[0];
    $filename =~ s{.*/}{};
    $filename =~ s{\.[^.]+$}{};

#getting pixel information
    my @pixels;
    for my $y (0 .. $image->getheight() - 1)
    {
        my @red_channel, my @green_channel, my @blue_channel;

        $image->getsamples(x => 0, y => $y, channels => [0], target => \@red_channel);
        $image->getsamples(x => 0, y => $y, channels => [1], target => \@green_channel);
        $image->getsamples(x => 0, y => $y, channels => [2], target => \@blue_channel);

        for my $x (0 .. $image->getwidth() - 1)
        {
            $pixels[$y][$x] = 0.299 * $red_channel[$x] + 0.587 * $green_channel[$x] + 0.114 * $blue_channel[$x];
	    }
    }

    my @blanks, my $threshold = 200; #TODO calculate threshold value
    for my $x (0 .. $image->getwidth() - 1)
    {
        my $y = 0;
        if ($pixels[$y][$x] > $threshold)
        {
            for $y (1 .. $image->getheight() - 1)
            {
                if ($pixels[$y][$x] < $threshold)
	        	{
                    $blanks[$x] = 0;
                    last;
                }
		        $blanks[$x] = 1;
            }
        }
        else
        {
            $blanks[$x] = 0;
        }
    }
    print @blanks;

    my $letter_counter = 1;
    for (my $left = 0; $left < $#blanks; $left++)
    {
        if ($blanks[$left] == 0)
        {
            for my $right ($left .. $#blanks - 1)
            {
                if ($blanks[$right] == 1)
                {
                    print "left = $left, right = $right";
                    my $copy = $image->copy();
                    my $letter = $copy->crop(left => $left, right => $right - 1);
                    $letter->write(file => "Letters/$filename\_$letter_counter.png", type=>"png")
                        or die "Cannot write the image\n", $letter->errstr;
                    $letter_counter++;
                    $left = $right;
                    last;
                }
            }
        }
    }
}
