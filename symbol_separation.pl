#!/usr/bin/perl

use strict;
use Imager;
use Data::Dumper;
use Graphics::Magick::ColorHistogram 'histogram';

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
            #print $pixels[$y][$x];
	    }
    }

    my $threshold = calculate_threshold("Preprocessed images/$_[0]");
    my @blanks;
    for my $x (0 .. $image->getwidth() - 1)
    {
        my $y = 0;
        if ($pixels[$y][$x] > $threshold)
        {
            for $y (1 .. $image->getheight() - 1)
            {
                if ($pixels[$y][$x] <= $threshold)
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
    #print @blanks;

    print "Image $filename is separated into symbols:";

    my $letter_counter = 1;
    for (my $left = 0; $left < $#blanks; $left++)
    {
        if ($blanks[$left] == 0)
        {
            for my $right ($left .. $#blanks - 1)
            {
                if ($blanks[$right] == 1)
                {
                    my $copy = $image->copy();
                    my $letter = $copy->crop(left => $left, right => $right - 1);
                    $letter->write(file => "Preprocessed images/$filename\_$letter_counter.png", type=>"png")
                        or die "Cannot write the image\n", $letter->errstr;
                    print "\t$filename\_$letter_counter.png";
                    $letter_counter += 1;
                    $left = $right;
                    last;
                }
            }
        }
    }
}

sub calculate_threshold
{
    my $histogram = histogram("$_[0]", 1);
    my @sorted = sort { $$histogram{$b} <=> $$histogram{$a} } keys $histogram;
    #print Dumper($histogram);

    my $symbol_colour_hex = $sorted[0];
    my @symbol_colour_rgb = map $_ , unpack 'C*', pack 'H*', $symbol_colour_hex;
    my $threshold = 0.299 * $symbol_colour_rgb[0] + 0.587 * $symbol_colour_rgb[1] + 0.114 * $symbol_colour_rgb[2];

    #print $threshold;
    $threshold;
}
