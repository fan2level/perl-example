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

my $subw = $mw->new_toplevel;
my $logw = $subw->new_tk__text(-state=>"disabled",
			       -width=>80,
			       -height=>24,
			       -wrap=>"none");

$entry->g_grid(-column=>0, -row=>0, -sticky=>"we");
$label->g_grid(-column=>0, -row=>1, -sticky=>"w");
$logw->g_grid;

$mw->g_bind("<Key-Escape>", sub{$mw->g_destroy});
$entry->g_bind("<Key-Return>", sub{&writelog($input);
				   $entry->delete(0,"end");
				   $result=$input;
				 });
$entry->g_focus;


Tkx::MainLoop();

sub valid{
  $result = $input;
  return 1;
}

sub writelog{
  my ($msg) = @_;
  my $numlines = $logw->index("end - 1 line");
  $logw->configure(-state=>"normal");
  if($numlines==24){$logw->delete("1.0", "2.0")};
  if($logw->index("end-1c") != "1.0"){$logw->insert_end("\n");}
  $logw->insert_end($msg);
  $logw->configure(-state=>"disabled");
}
