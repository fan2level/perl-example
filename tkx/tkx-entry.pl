#!/usr/bin/perl -w
# ref : http://www.perlmonks.org/?node_id=881505

use strict;
use Tkx;

my $input;
my $result;

my $wMain = Tkx::widget->new(".");
$wMain->g_wm_title("entry widget");
my $wgFrame = $wMain->new_tk__frame();
my $wgEntry = $wgFrame->new_tk__entry(-width=>80,
				      -textvariable=>\$input,
				      -validate=>"key", # "none" "key" "focus" "focusin" "focusout" "all"
				      -validatecommand=>[\&command_validate, Tkx::Ev('%P')],
				      -invalidcommand=>\&command_invalid,
				   );
my $wgLabel= $wgFrame->new_tk__label(-textvariable=>\$result);

my $wSub = $wMain->new_toplevel;
$wSub->g_wm_title("debug window");
my $wgText = $wSub->new_tk__text(-state=>"disabled",
				 -width=>80,
				 -height=>24,
				 -wrap=>"none");

$wgFrame->g_grid;
$wgEntry->g_grid(-column=>0, -row=>0, -sticky=>"we");
$wgLabel->g_grid(-column=>0, -row=>1, -sticky=>"w");
$wgText->g_grid();

$wMain->g_bind("<Key-Escape>", sub{$wMain->g_destroy});
$wgEntry->g_bind("<Key-Return>", sub{&debugTo($input);
				     $wgEntry->delete(0,"end");
				     $result=$input;
				   });
$wgEntry->g_focus();


Tkx::MainLoop();

sub command_validate{
  $result = shift @_;
  return 1;
}

sub command_invalid{
  # call when command_validate() returns 0
  debugTo("invalid command ...\n");
}

sub debugTo{
  my ($msg) = @_;
  my $numlines = $wgText->index("end - 1 line");
  $wgText->configure(-state=>"normal");
  if ($numlines==24) {
    $wgText->delete("1.0", "2.0");
  }

  if ($wgText->index("end-1c") != "1.0") {
    $wgText->insert_end("\n");
  }
  $wgText->insert_end($msg);
  $wgText->configure(-state=>"disabled");
}
