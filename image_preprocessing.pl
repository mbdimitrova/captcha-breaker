#!/usr/bin/perl

use strict;
use Imager;

$\ ="\n";

sub preprocess
{
    my $image = Imager->new;
    $image->read(file => $_[0])
	    or die $image->errstr;

    Imager::i_contrast($image, 3);
    $image->filter(type => "autolevels")
        or die $image->errstr;
    $image = $image->convert(preset => "gray")
        or die $image->errstr;

    $image->write(file => "new.png", type=>"png")
	    or die "Cannot write the image\n", $image->errstr;
}
