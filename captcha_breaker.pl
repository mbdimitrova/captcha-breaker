#!/usr/bin/perl

use strict;

require "image_preprocessing.pl";
require "symbol_separation.pl";
require "ocr.pl";

$\ = "\n";

my $filename = "1.png";
my $sticks_number = 10;

preprocess($filename);
my $symbols_number = separate_symbols($filename);

