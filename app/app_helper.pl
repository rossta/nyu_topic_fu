#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;

require "helper.pl";

sub app_sidebar {
  my $page_title = shift @_;
  &search_html;
  if($page_title eq 'VIEW') {
    &sidebar_topics("Previous  Revisions", &previous_revisions(param('topic')))
  } else {
    &sidebar_topics("Recent Updates", &recent_topics(5)); 
  }
}

sub user_status {
  print "<div id='user_status'>";
  print p("Welcome back, " . cookie('user'));
  print a({-href => &logout_path}, "Log out");
  print "</div>";
}