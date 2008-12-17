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
  print p("Hello, " . cookie('user')) unless param('new_user');
  print a({-href => &logout_path}, "Log out");
  print "</div>";
}

sub search_html {
  print "<div id='search_form' class='go_box sidebar'>";
  print start_form(-method=>"GET", -action=>'topic_search'),
    h4("Search"),
    textfield({-style => "font-size:75%", -class=> 'text',-name => 'term', -value => param('term')}),
    span({-class => "submit"},
      submit("Go"),
    ),
  end_form;
  print "</div>";
}
