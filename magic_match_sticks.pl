#!/usr/bin/perl

use strict;

$\ = "\n";

package MagicStick;
use Imager;
use Class::Struct;
use Data::Dumper;
use Algorithm::Line::Bresenham qw/line/;
use List::Util qw(min max);
use Data::Types qw(:all);
use AI::NeuralNet::Simple;

require "symbol_separation.pl";

struct(
    xa => '$',
    ya => '$',
    xb => '$',
    yb => '$'
);

sub generate_magic_stick
{
    my $image_width  = $_[0];
    my $image_height = $_[1];

    my $stick = new MagicStick;

    my $xa = int(rand($image_width));
    my $ya = int(rand($image_height));
    my $xb = int(rand($image_width));
    my $yb = int(rand($image_height));

    my $dx = $xb - $xa;
    my $dy = $yb - $ya;
    my $length = int(sqrt($dx * $dx + $dy * $dy));

    #if their length is too short, then take another
    my $min_dimention = min($image_height, $image_width);
    if (($length < $min_dimention/10) || ($length > $min_dimention/5))
    {
        &generate_magic_stick;
    }

    $stick->xa($xa);
    $stick->ya($ya);
    $stick->xb($xb);
    $stick->yb($yb);

    $stick;
}

sub generate_magic_sticks_list
{
    my $image_width  = $_[0];
    my $image_height = $_[1];
    my $count = $_[2];

    my @sticks_list;

    for (my $i = 0; $i < $count; $i++)
    {
        my $stick = generate_magic_stick $image_width, $image_height;
        $sticks_list[$i] = $stick;
    }

    @sticks_list;
}

sub pixel_stick_coverage
{
    my $stick = new MagicStick;
    $stick = $_[0];
    my $x = $_[1];
    my $y = $_[2];

    my $xa = $stick->xa;
    my $ya = $stick->ya;
    my $xb = $stick->xb;
    my $yb = $stick->yb;

    my @stick_points = line($xa, $ya => $xb, $yb);
    foreach my $stick_point (@stick_points)
    {
        if ($$stick_point[0] == $x && $$stick_point[1] == $y)
        {
            return 1;
        }
    }
    return 0;
}

sub get_pixel_colour
{
    my $image = $_[0];
    my $x = $_[1];
    my $y = $_[2];

    my $colour = $image->getpixel(x => $x, y => $y, type => '8bit');
    my @rgba = $colour->rgba();
    $colour = 0.299 * $rgba[0] + 0.587 * $rgba[1] + 0.114 * $rgba[2];
}

sub get_magic_sticks_pattern
{
    my ($image, $threshold, @sticks_list) = @_;

    my $width = $image->getwidth();
    my $height = $image->getheight();

    my $number_of_sticks = $#sticks_list + 1;
    my @pattern;

    my $lastx = -1;
    my $lasty = -1;
    my $tmpx = -1;
    my $tmpy = -1;

    for (my $i = 0; $i < $number_of_sticks; $i++)
    {
        $pattern[$i] = 0.0;
    }

    for (my $y = 0; $y < $height; $y++)
    {
        for (my $x = 0; $x < $width; $x++)
        {
            #if ((get_pixel_colour $image, $x, $y) == 0)
            if ((get_pixel_colour $image, $x, $y) < $threshold)
            {
                $tmpx = $x;
                $tmpy = $y;

                if (($tmpx != $lastx) || ($tmpy != $lasty))
                {
                    $lastx = $tmpx;
                    $lasty = $tmpy;

                    for (my $i = 0; $i < $number_of_sticks; $i++)
                    {
                        if ($pattern[$i] == 1.0)
                        {
                            next;
                        }
                        if ((pixel_stick_coverage $sticks_list[$i], $tmpx, $tmpy) == 1)
                        {
                            $pattern[$i] = 1.0;
                        }
                    }
                }
            }
        }
    }
    @pattern;
}

1;

=comment
my $image = Imager->new;
#$image->read(file => "Patterns/0/0_0.png")
$image->read(file => "Preprocessed images/1_0.png")
    or die $image->errstr;

my @sticks_list = generate_magic_sticks_list($image->getwidth(), $image->getheight(), 50);
print Dumper (@sticks_list);

print get_magic_sticks_pattern($image, 200, @sticks_list);
