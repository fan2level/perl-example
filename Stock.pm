package Stock;

use 5.010000;
use strict;
use warnings;
use LWP::Simple;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Stock ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

my $data_directory = "./stock";
my $file_stock_code= "stock.list";

# Preloaded methods go here.

sub version{
  return "$VERSION\n";
}

sub get_stock_code_list{
  # return unless(-d $data_directory);
  # return unless(-e "$data_directory/$file_stock_code");

  my %stock_code_data;

  unless(open STOCK_CODE, "<$data_directory/$file_stock_code"){
    mkdir $data_directory unless(-d $data_directory);
    unless(open STOCK_CODE, ">$data_directory/$file_stock_code"){
      print "fail: fail to creat $file_stock_code\n";
      return;
    }
    close STOCK_CODE;
    print "create $file_stock_code\n";
    return;
  }

  binmode(STOCK_CODE, ':encoding(cp949)'); # important !!!
  while(defined(my $line = <STOCK_CODE>)){
    next if $line =~ m/^\s$/;	# blank line
    next if $line =~ m/^\s*#.*$/; # comment line by '#'

    $line =~ m/^s*(?<stock_code>[0-9]{6})\s+(?<stock_name>.+)\s(?<stock_kind>.+)/;

    next if(defined($stock_code_data{$+{stock_code}})); # duplicate todo : alert, delete

    $stock_code_data{$+{stock_code}} = "$+{stock_name} $+{stock_kind}";
  }
  close STOCK_CODE;

  return %stock_code_data;
}

sub set_stock_code_list{
  my $stock_code_data_ref = shift;
  my %stock_code_data     = get_stock_code_list();

  return unless(defined($stock_code_data_ref));
  # return unless(%stock_code_data);

  $stock_code_data{$_} = $stock_code_data_ref->{$_} foreach (keys %$stock_code_data_ref);

  unless(open STOCK_CODE_LIST, ">$data_directory/$file_stock_code"){
    print "fail: fail to create $file_stock_code\n";
    return;
  }
  binmode(STOCK_CODE_LIST, ':encoding(cp949)'); # important !!!
  print STOCK_CODE_LIST "$_ $stock_code_data{$_}\n" foreach (sort {$a cmp $b} keys %stock_code_data);
  close STOCK_CODE_LIST;
}

sub fetch_stock_code_list{
  my %stock_kind = (
		    KOSPI => 0,
		    KOSDAQ=> 1,
		    );

  my ($stock_kind) = @_;	# "KOSPI" or "KOSDAQ"
  my %stock_code_data;
  my $page = 1;
  my $url;
  my $url_format = "http://finance.naver.com/sise/sise_market_sum.nhn?sosok=%d&page=%d";
  my $content;

  return unless(defined($stock_kind));
  return unless(defined($stock_kind{$stock_kind}));

  while(1){
    $url = sprintf $url_format, $stock_kind{$stock_kind}, $page;
    $content = get $url;
    unless($content){
      print "fail: $url\n";
      last;
    }

    $page++;
    foreach my $line (split(/\n/, $content)) {
      next if $line =~ m/^\s*$/;
      if ($line =~ m#\s*<td><a href="/item/main.nhn\?code=(?<stock_code>\d+)" class="tltle">(?<stock_name>.+)</a></td>#) {
	last unless(defined($+{stock_code}));
	last if(defined($stock_code_data{$+{stock_code}}));
	$stock_code_data{$+{stock_code}} = "$+{stock_name} $stock_kind";
      }
    }

    last if($page > 26);
  }

  return %stock_code_data;
}

sub get_data{
  my ($code, $date_begin, $date_end) = @_;
  my %stock_code_data = get_stock_code_list();
  my %stock_data;
  my $stock_directory;

  return unless(defined($code));
  return unless(%stock_code_data);
  return unless(defined($stock_code_data{$code}));

  if(grep(/.*KOSPI.*/,split(/\s+/, $stock_code_data{$code}))){
    $stock_directory = "$data_directory/KOSPI";
  }elsif(grep(/.*KOSDAQ.*/,split(/\s+/, $stock_code_data{$code}))){
    $stock_directory = "$data_directory/KOSDAQ";
  }else{
    print "fail: what kind of stock is $code?\n";
    return;
  }

  unless(open STOCK_DATA, "<$stock_directory/$code"){
    print "fail: fail to open $code\n";
    return;
  }
  while(defined(my $line = <STOCK_DATA>)){
    $line =~ m/(\S+)\s+(.*)/;
    last unless(defined($1) or defined($2));

    next if(defined($date_begin) and $1 le $date_begin);
    next if(defined($date_end) and $1 gt $date_end);

    $stock_data{$1} = $2;
  }
  close STOCK_DATA;

  return %stock_data;
}

sub set_data{
  my ($code, $data_ref) = @_;
  my %stock_code_data = get_stock_code_list();
  my %stock_data;
  my $stock_kind;
  my $stock_directory;

  return unless(defined($code) or defined($data_ref));
  return unless(%stock_code_data);
  return unless(defined($stock_code_data{$code}));

  if(grep(/.*KOSPI.*/,split(/\s+/, $stock_code_data{$code}))){
    $stock_directory = "$data_directory/KOSPI";
  }elsif(grep(/.*KOSDAQ.*/,split(/\s+/, $stock_code_data{$code}))){
    $stock_directory = "$data_directory/KOSDAQ";
  }else{
    print "$code error\n";
    return;
  }
  mkdir $stock_directory unless(-d $stock_directory);

  %stock_data = get_data($code);

  foreach (keys %$data_ref){
    if (defined($stock_data{$_})){
      # print "warn: duplicate $_ \n"; many log
      next;
    }
    $stock_data{$_} = $data_ref->{$_};
  }

  unless(open STOCK_DATA, ">$stock_directory/$code"){
    print "fail: fail to create $code\n";
    return;
  }
  print STOCK_DATA "$_ $stock_data{$_}\n" foreach (sort {$b cmp $a} keys %stock_data);
  close STOCK_DATA;
}

sub fetch_data{
  my ($stock_code, $page, $page_end) = @_;
  $page = 1 unless(defined($page));
  my $page_valid;
  my $content;
  my $date;
  my %data;
  my $closing_price;
  my $trading_volume;
  my $exchange_amount_of_agency;
  my $exchange_amount_of_foreign;
  my $shares_of_foreign;
  my $rates_of_foreign;

  my $url_format = "http://finance.naver.com/item/frgn.nhn?code=%s&page=%d";
  my $url;

  while (1) {
    last if (defined($page_end) and $page > $page_end);

    $url = sprintf $url_format, $stock_code, $page;
    $content = get $url;
    unless($content){
      print "fail: $url\n";
      next;
    }
    $page++;

    $page_valid = undef;
    while ($content =~ m/.*<tr onMouseOver="mouseOver\(this\)" onMouseOut="mouseOut\(this\)">.*/g) {
      $content =~ m#.*<span.*>\s*(\d{4}\.\d{2}\.\d{2})\s*</span>.*#gc; # 날짜
      $date = $1;
      last if (!defined($date));
      last if (defined($data{$date}));

      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#g; # 종가
      $closing_price = $1;
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 전일비
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 등락률
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 거래량
      $trading_volume = $1;
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 기관 순매매량
      $exchange_amount_of_agency = $1;
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 외인 순매매량
      $exchange_amount_of_foreign =$1;
      $content =~ m#.*<span.*>\s*([+-.,%0-9]+)\s*</span>.*#gc; # 외인 보유주수
      $shares_of_foreign = $1;
      $content =~ m#.*<span.*>\s*([+-.,0-9]+)%\s*</span>.*#gc; # 외인 보유율
      $rates_of_foreign = $1;

      $closing_price =~ s/,//g;
      $trading_volume=~ s/,//g;
      $exchange_amount_of_agency=~ s/,//g;
      $exchange_amount_of_foreign=~ s/,//g;
      $shares_of_foreign=~ s/,//g;
      $rates_of_foreign=~ s/,//g;

      $data{$date} = "$closing_price $trading_volume $exchange_amount_of_agency $exchange_amount_of_foreign $shares_of_foreign $rates_of_foreign";
      $page_valid = 1;
    }

    last if(!defined($page_valid));
  }

  return %data;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Stock - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Stock;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Stock, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
