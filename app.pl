#!/usr/bin/perl -w

use strict;
use Stock;
use encoding 'cp949';

# # my %stock_code_list = Stock::fetch_stock_code_list("KOSPI");
# # Stock::set_stock_code_list(\%stock_code_list);

# my %stock_code_list = ();
# %stock_code_list = Stock::fetch_stock_code_list("KOSDAQ");
# Stock::set_stock_code_list(\%stock_code_list);

# my %code = Stock::get_stock_code_list;
# my %data;
# foreach (sort {$a cmp $b} keys %code){
#   %data = Stock::fetch_data($_, "2014.08.01", "2014.08.26");
#   Stock::set_data($_,\%data);
# }

my %data = Stock::fetch_data("183190");
print "$_ $data{$_}\n" foreach (sort {$a cmp $b} keys %data);
