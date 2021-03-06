#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;
# URL: http://cs.nyu.edu/~rk1023/cgi-bin/unixtool/topic_fu
require "helper.pl";

use CGI qw(-debug :standard);

my ($user_cookie, $email_cookie);
&logout_user;

my $user = param('user');
my $email = param('email');

my $login_param = "?returning=1";
my $action = param('action') || "new_session";

if($action eq 'signup') {
  my $user_result;
  if(&validate_email($email)) {
    $user_result = &create_user($email, $user);
    if ( -e "$user_result") {
      $login_param = "?new_user=1";
      &redirect_home;
    } else {
      $FLASH = "$user_result";
    }
  } else {
    $FLASH = "C'mon. Please enter a valid email address";
  }
} elsif ($action eq 'login') {
  if(defined $user) {
    if(verify($user, $email)) {
      &redirect_home;
    } else {
      $FLASH = "Invalid login. Try again";
    }
  } 
}


print header(-type => "text/html");

my $query = CGI::->new();
&warn_params($query);
my $topic;
if (param('signup') or $action eq 'signup') {
  $topic = "Sign up";
  param('action','signup');
} else {
  $topic = "Log in";
  param('action','login');
}

my $page = uc $topic;

&page_start;
&page_title($page, $topic);
&show_flash;

print start_form,
hidden(-name=>'action'),
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
print "<div style='clear:left'></div>";
print "</div>";

&footer;

print end_html;

sub app_sidebar {
  &welcome_html;
  print "<div id='teasers'>";
  &sidebar_topics("Now on Topic Fu", &recent_topics(5)); 
  print "</div>";
}

sub welcome_html {
  if (param('signup')) {
    print "<div id='welcome' class='go_box sidebar'>",
      h4("Already registered?"),
      a({-href => &login_path, -class => 'welcome_link' }, "Log in to Topic Fu"),
      "</div>";
  } else {
    print "<div id='welcome' class='go_box sidebar'>",
      h4("Need to signup?"),
      a({-href => &signup_path, -class => 'welcome_link' }, "Register for Topic Fu"),
      "</div>";
  }
}

sub user_status {
  # no op
}

sub page_header {
  my $page_title = shift @_;
  my $page_topic = shift @_;
  print h2({-class => "page_title"}, $page_topic);
}

sub logout_user {
  if(param('logout')) {
    $user_cookie = cookie(-name => 'user', -value => "");
    $email_cookie = cookie(-name => 'email', -value => "");
    print redirect(-uri => &login_path."?refresh=1", -cookie => [$user_cookie, $email_cookie]);
  } elsif(param('refresh')) {
    param('refresh', 0);
    $FLASH = 'You have successfully logged out.';
  }
}

sub validate_email {
  my $email_attempt = shift @_;
  if ($email_attempt =~ /^[A-Za-z0-9._%+-]+@[A-Za-z0-9._]+\.[A-Za-z]{2,4}$/) {
    return 1;
  } else {
    return 0;
  }
}

sub create_user {
  my $email = shift @_;
  my $name = shift @_;
  my $file_key = "$SID/$USER_DIR/$email";
  
  return "An account for that email has already been taken" if ( -e $file_key );

  my $store_cmd = "simplestore write \"$file_key\" \"$name\"";
  warn "store command: $store_cmd" if $DEBUG;
  `$store_cmd`;
  
  return $file_key;
}

sub redirect_home {
  $user_cookie = cookie(-name => 'user', -value => $user);
  $email_cookie = cookie(-name => 'email', -value => $email);
  print redirect(-uri => &fu_path.$login_param, -cookie => [$user_cookie, $email_cookie]);
}