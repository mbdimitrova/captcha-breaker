#!/usr/bin/perl

use strict;
require "image_preprocessing.pl";
require "symbol_separation.pl";
require "magic_match_stick.pl";

$\ = "\n";

my $filename = "1.png";
preprocess($filename);
separate_symbols($filename);

