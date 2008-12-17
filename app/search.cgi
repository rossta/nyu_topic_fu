#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;

require "helper.pl";
require "app_helper.pl";

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
my %files = &search_index_files_for(@terms);
search_results_html(%files);

print end_html;

sub search_results_html {
  %matching_files = @_;
  print "<ol id='search_results_list'>";
  foreach $value (sort {$matching_files{$b} <=> $matching_files{$a} } keys %matching_files) {
    my %file_data = &file_data(&most_recent_file_for($value));
    print "<li>";
    print a({-href=>$file_data{'href'},-class =>'topic_title'}, $file_data{'name'});
    print span(" - Match score: $matching_files{$value}");
    print "</li>";
  }
  print "</ol>";
}

sub search_index_files_for {
  my @terms = @_;
  my $dir = "$STORE/$INDEX_DIR";
  my %matching_files;
  opendir( INDEX_DIR, $dir )
    or die "Error: cannot open $dir: $!\n";
  while( my $name = readdir(INDEX_DIR)) {
    next if($name =~ /^\./);
    my $filename = "$dir/$name";
    next unless -f $filename and -r $filename;
    open (FILE, $filename)
      or die "Error: cannot open $filename: $!\n";
    my @line_matches;
    my $score = 0;
    my $multiplier = 1;
    debug("searching $name for: @terms");
    foreach $term (@terms) {
      chomp($term);
      debug("search term: $term");
      if ($name =~ /$term/) {
        $multiplier = $multiplier + $multiplier;
        $score = $score + 1;
      }
      push(@line_matches, grep { /$term/g } <FILE>);
      if(@line_matches) {
        debug("match for $term in $name: @line_matches");
        foreach (@line_matches) {
          s/^([^, ]*),.*/$1/;
          $score = $score + $_;
        }
      }
    }
    close FILE;
    $score *= $multiplier if $score;
    if($score > 0) {
      $matching_files{$name} = $score;
    }
  }
  return %matching_files;
}

sub page_header {
  print h2({-class => "page_title"}, "Search Results");
}
