#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;

require "helper.pl";

use CGI qw(-debug :standard);

print header("text/html");

my $query = CGI::->new();
&warn_params($query);
my $topic = &get_topic_and_validate;
my $page = 'SEARCH';

&page_start;
&page_title($page, $topic);

my $term_param = lc param('term');
my @terms = split(/ /, $term_param);
my @topic_list = &most_recent_files_for_all_topics;

foreach $term (@terms) {
  foreach $file (@topic_list) {
    open( FILE, $file )
      or die "Error: cannot open $file: $!\n";
       
    my @matches = grep { /$term/g } <FILE>;
    my %file_data = &file_data($file);
    if(@matches) {
      print a({-href=>$file_data{'href'},-class =>'topic_title'}, $file_data{'name'});
      print p(&html_format(sprintf("%.100s", "@matches")));
    }
  }
}

print end_html;
