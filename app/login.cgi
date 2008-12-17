#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;
# URL: http://cs.nyu.edu/~rk1023/cgi-bin/unixtool/topic_fu
require "helper.pl";

use CGI qw(-debug :standard);

my ($user_cookie, $email_cookie);
if(param('logout')) {
  $user_cookie = cookie(-name => 'user', -value => "");
  $email_cookie = cookie(-name => 'email', -value => "");
  print redirect(-uri => "$base_url/cgi-bin/topic_login?refresh=1", -cookie => [$user_cookie, $email_cookie]);
} elsif(param('refresh')) {
  param('refresh', 0);
  $FLASH = 'You have successfully logged out.';
}
my $base_url = url(-base => 1);
my $user = param('user');
my $email = param('email');

if(defined $user) {
  if(verify($user, $email)) {
    $user_cookie = cookie(-name => 'user', -value => $user);
    $email_cookie = cookie(-name => 'email', -value => $email);
    print redirect(-uri => "$base_url/cgi-bin/topic_fu", -cookie => [$user_cookie, $email_cookie]);
  } else {
    $FLASH = "Invalid login. Try again";
  }
} 

print header(-type => "text/html");

my $query = CGI::->new();
&warn_params($query);
my $topic = "Log in";
my $page = uc $topic;
&page_start;
&page_title($page, $topic);
&show_flash;
param('action','login');
print start_form,
table({-class => "login" },
  Tr(
    td("Name:"),
    td(textfield({-style => "font-size:100%", -name => 'user', -value => param('user')})),
    ),
  Tr(
    td("Email:"),
    td(textfield({-style => "font-size:100%", -name => 'email', -value => param('email')})),
    ),
  Tr(
    td("&nbsp;"),
    td(span({-class => "submit"},submit("Go"))),
    )),
end_form;
print end_html;

sub app_sidebar {
  &signup_html;
}

sub signup_html {
  print "hello";
}

sub user_status {
  # no op
}

sub page_header {
  my $page_title = shift @_;
  my $page_topic = shift @_;
  print h2({-class => "page_title"}, $page_topic);
}


