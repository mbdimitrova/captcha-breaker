#!/usr/bin/perl

use strict;
use Imager;
use Data::Dumper;

$\ ="\n";

sub separate_symbols
{

#reading the image
    my $image = Imager->new;
    $image->read(file => $_[0])
	    or die $image->errstr;

#getting pixel information
    my @pixels;
    for my $y (0 .. $image->getheight()-1)
    {
        my @red_channel, my @green_channel, my @blue_channel;

        $image->getsamples(x => 0, y => $y, channels => [0], target => \@red_channel);
        $image->getsamples(x => 0, y => $y, channels => [1], target => \@green_channel);
        $image->getsamples(x => 0, y => $y, channels => [2], target => \@blue_channel);

        for my $x (0 .. $image->getwidth()-1)
        {
            $pixels[$y][$x] = 0.299 * $red_channel[$x] + 0.587 * $green_channel[$x] + 0.114 * $blue_channel[$x];
            print $pixels[$y][$x];
	    }
    }

    my @blanks, my $threshold = 200; #TODO calculate threshold value
    for my $x (0 .. $image->getwidth()-1)
    {
        my $y = 0;
        if ($pixels[$y][$x] > $threshold)
        {
            for $y (1 .. $image->getheight()-1)
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
}
