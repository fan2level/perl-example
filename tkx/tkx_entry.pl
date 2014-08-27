#!/usr/bin/perl -w

use strict;
use Tkx;

my $mw = Tkx::widget->new(".");
my $input;
my $entry = $mw->new_tk__entry(-textvariable=>\$input,
			       -validate=>"key",
			       -validatecommand=>\&valid,
			      );
my $result;
my $label= $mw->new_tk__label(-textvariable=>\$result);

$entry->g_grid(-column=>0, -row=>0, -sticky=>"we");
$label->g_grid(-column=>0, -row=>1, -sticky=>"w");

$mw->g_bind("<Key-Escape>", sub{$mw->g_destroy});
$entry->g_focus;

Tkx::MainLoop();

sub valid{
  $result = $input;
  return 1;
}
