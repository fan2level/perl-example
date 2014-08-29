#!/usr/bin/perl -w

use strict;
use Tkx;
use encoding 'cp949';		# for Korean, Windows

my $list_items = "{list1} {list2} {ÇÑ±Û} ";

my $wMain = Tkx::widget->new(".");
$wMain->g_wm_title("listbox widget");

my $frm = $wMain->new_ttk__frame(-padding=>"5 5 5 5");
my $wgListbox = $frm->new_tk__listbox(-height=>30,
				      -listvariable=>\$list_items
				      );

my $wSub = $wMain->new_toplevel;
$wSub->g_wm_title("debug window");
my $wgText = $wSub->new_tk__text(-width=>80, -height=>24,
				 -state=>"disabled",
				 -wrap=>"none",
				 );
$wgText->g_bind();

$wMain->g_bind("<Key-Escape>", sub{$wMain->g_destroy();});
$wgListbox->g_bind("<<ListboxSelect>>", sub{debugTo("tt");});

$frm->g_grid();
$wgListbox->g_grid(-column=>0, -row=>0);

$wgListbox->selection_set(0) if ($wgListbox->size > 0);

Tkx::MainLoop();

sub debugTo{
  my ($msg) = @_;
  my $numlines = $wgText->index("end - 1 line");
  $wgText->configure(-state=>"normal");
  # if ($numlines==24) {
  #   $wgText->delete("1.0", "2.0");
  # }

  if ($wgText->index("end-1c") != "1.0") {
    $wgText->insert_end("\n");
  }
  $wgText->insert_end($msg);
  $wgText->configure(-state=>"disabled");
}
