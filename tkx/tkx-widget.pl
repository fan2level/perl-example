#!/usr/bin/perl -w

use strict;
use Tkx;

my @standard_options = qw(-class -cursor -takefocus);

my $wMain = Tkx::widget->new(".");
$wMain->g_wm_title("widget");
my $wgLabel = $wMain->new_ttk__label(-text=>"label");
my $wgButton0= $wMain->new_ttk__button(-text=>"label option",
				       -command=>\&command_label,
				      );
my $wgButton1= $wMain->new_ttk__button(-text=>"compatibility option",
				       -command=>\&command_compatibility,
				      );
my $wgButton2= $wMain->new_ttk__button(-text=>"commands",
				       -command=>\&command_commands,
				      );
my $wgButton3= $wMain->new_ttk__button(-text=>"widget state",
				       -command=>\&command_widget_state,
				      );

my $wSub = $wMain->new_toplevel;
$wSub->g_wm_title("debug window");
my $wgText = $wSub->new_tk__text(-width=>160, -height=>24,
				 -state=>"disabled",
				 -wrap=>"none",
				 );
$wgText->g_grid();

$wMain->g_bind("<Key-Escape>", sub{$wMain->g_destroy();});

$wgLabel->g_grid();
$wgButton0->g_grid();
$wgButton1->g_grid();
$wgButton2->g_grid();
$wgButton3->g_grid();

Tkx::MainLoop();

sub command_label{
}

sub command_compatibility{
}

sub command_commands{
}

sub command_widget_state{
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
