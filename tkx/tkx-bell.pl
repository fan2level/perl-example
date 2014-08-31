#!/usr/bin/perl -w

use strict;
use Tkx;

my $wMain = Tkx::widget->new(".");
my $wgButton = $wMain->new_tk__button(-text=>"bell");

$wMain->g_bind("<Key-Escape>", sub{$wMain->g_destroy});
$wMain->g_bind("<Key-a>", sub{Tkx::bell(-displayof=>$wMain)});

$wgButton->configure(-command=>[\&bell, $wMain]);

$wgButton->g_grid;
Tkx::bell(-displayof=>$wMain);

Tkx::MainLoop();

sub bell{
  Tkx::bell(-displayof=>$wMain);
}
