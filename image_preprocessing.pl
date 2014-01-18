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

    my $filename = $_[0];
    $filename =~ s{.*/}{};
    $filename =~ s{\.[^.]+$}{};
    $image->write(file => "./Preprocessed images/$filename.png", type=>"png")
	    or die "Cannot write the image\n", $image->errstr;
}
