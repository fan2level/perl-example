#!/usr/bin/perl -w

use strict;
use Tkx;
use encoding 'cp949';		# for Korean, Windows

my $list_items = "{list1} {list2} {ÇÑ±Û} {abc}"; # '-listvariable' format

my $wMain = Tkx::widget->new(".");
$wMain->g_wm_title("listbox widget");

my $frm = $wMain->new_ttk__frame(-padding=>"5 5 5 5");
my $wgListbox = $frm->new_tk__listbox(
				      -height=>10,
				      -listvariable=>\$list_items
				      );
my $wgEntry = $frm->new_tk__entry(-width=>40,
				  -text=>"input",
				  -validate=>"key",
				  -validatecommand=>[\&command_validate,
						     Tkx::Ev('%P')],
				  );
my $wgButton = $frm->new_tk__button(-width=>40,
				    -text=>"to Perl list",
				    -command=>\&command_button,
				    );
my $wgButton1= $frm->new_tk__button(-width=>40,
				    -text=>"to Tk list",
				    -command=>\&command_button1,
				   );
my $wgButton2= $frm->new_tk__button(-width=>40,
				    -text=>"commands",
				    -command=>\&command_common,
				    );

my $wSub = $wMain->new_toplevel;
$wSub->g_wm_title("debug window");
my $wgText = $wSub->new_tk__text(-width=>160, -height=>24,
				 -state=>"disabled",
				 -wrap=>"none",
				 );
$wgText->g_grid();

$wMain->g_bind("<Key-Escape>", sub{$wMain->g_destroy();});
$wgListbox->g_bind("<<ListboxSelect>>", \&when_selected);

$frm->g_grid();
$wgListbox->g_grid(-column=>0, -row=>0, -rowspan=>4);
$wgListbox->selection_set(0) if ($wgListbox->size > 0);
$wgEntry->g_grid(-column=>1, -row=>0);
$wgButton->g_grid(-column=>1, -row=>1);
$wgButton1->g_grid(-column=>1, -row=>2);
$wgButton2->g_grid(-column=>1, -row=>3);

$wgEntry->g_focus();

Tkx::MainLoop();

sub when_selected{
  my $index = $wgListbox->curselection();
  my $value = $wgListbox->get($index);

  debugTo("$index => $value");
}

sub command_common{
  my $items = $wgListbox->get(0, "end");
  debugTo("command->get(\"end\")  ".$items);

  my $index = $wgListbox->index(0);
  debugTo("command->index(0)  ". $index);
  $index = $wgListbox->index("end");
  debugTo("command->index(\"end\")  ".$index);
}

sub command_button{
  # to Perl list
  # this code doesn't work in case of items which is "{1} {2} {33 33 33}" 
  my $items = $wgListbox->get(0, "end");
  my $tk_list='';
  my $perl_list='';

  $tk_list = $tk_list.Tkx::list($_.' ').' ' foreach(split(/\s+/, $items));
  $perl_list = $perl_list.' '.$_ foreach (Tkx::SplitList($tk_list));
  debugTo($tk_list.' => '.$perl_list);
}

sub command_button1{
  # to Tk list
  # this code doesn't work in case of items which is "{1} {2} {33 33 33}" 
  my $items = $wgListbox->get(0, "end");
  my $tk_lists='';

  foreach (split(/\s/, $items)){
     # Tkx::list($_.' ' <== why???
      $tk_lists = $tk_lists . Tkx::list($_.' ') . ' ';
  }
  debugTo($items.' => '.$tk_lists);
}

sub command_validate{
  my $P = shift;

  debugTo("input => $P");
  return 1;
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
