#!/usr/bin/perl
##
#
# $Author: alex $
# $Revision: 1.2 $
# $Log: test.pl,v $
# Revision 1.2  1999/02/04 11:25:46  alex
# First stable version
#
# Revision 1.1  1999/01/24 13:40:27  alex
# Initial revision
#
##

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN {$! = 1;print "1..2\n";}
END {print "not ok 1\n" unless $loaded;}

use Tk;
use Tk::Text::SuperText;

$loaded = 1;

print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $wm=MainWindow->new();

my $text=$wm->Scrolled('SuperText','-scrollbars' => 'se','-wrap' => 'none',
  '-borderwidth' => 0,'-width' => 80,'-height' => 40,'-indentmode' => 'auto');

$text->pack('-fill' => 'both','-expand' => 'true');
$text->focus;

$text->bind('Tk::Text::SuperText','<<PrintCouples>>',\&print_couples);
$text->eventAdd('<<PrintCouples>>','<Control-p>','<Control-Key-1>');

MainLoop;

print "ok 2\n";

sub print_couples
{
	my $w = shift;
	
	my $s=$w->cget('-matchingcouples');
	print (defined $s ? $s :'undef');
	print "\n";
}

