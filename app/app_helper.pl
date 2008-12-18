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
  &sidebar_users("New Users", &user_html(5));
}

sub user_status {
  print "<div id='user_status'>";
  print p("Hello, " . cookie('user')) unless param('new_user');
  print a({-href => &logout_path}, "Log out");
  print "</div>";
}

sub search_html {
  print "<div id='search_form' class='go_box sidebar'>";
  print start_form(-method=>"GET", -action=>'topic_search.cgi'),
    h4("Search"),
    textfield({-style => "font-size:75%", -class=> 'text',-name => 'term', -value => param('term')}),
    span({-class => "submit"},
      submit("Go"),
    ),
  end_form;
  print "</div>";
}

sub sidebar_users {
  my $text = shift @_;
  @recent = @_;
  print div({-id => "sidebar_users", -class => 'activity_box sidebar'},
    h4($text),
    ul("@recent"),
  );
}

sub user_html {
  $_ = shift @_;
  my @users = &all_users;
  my @user_li_tags;
  %user_hash =  &user_list_items_for(@users);
  foreach $user_key (sort { $b <=> $a } keys %user_hash) {
    push(@user_li_tags, $user_hash{$user_key});
  }
  return @user_li_tags;
}

sub all_users {
  my @user_list;
  my $dir = "$SID/$USER_DIR";
  opendir( ALL_USERS, $dir )
    or die "Error: cannot open $dir: $!\n";

  while ( my $email = readdir(ALL_USERS) ) {
    next if($email =~ /^\./);
    $user_file = "$dir/$email";
    push(@user_list, $user_file);
  }
  
  closedir ALL_USERS;
  return @user_list;
}

sub user_list_items_for {
  my %user_list_items;
  foreach $user_file (@_) {
    my %user = &user_data($user_file);
    my $href = $user{'edit'}||$user{'view'};
    my $user_class = 'profile';
    unless($href) {
      $user_class = 'no_profile';
      $href = "#";
    }
    my $join_date = &time_format($user{'timestamp'}, "%l:%M %p, %b %d, %Y");
    my $user_list_item;
    $user_list_item = li(a({-href => $href, -class=> $user_class},$user{'name'}), span(" - joined at $join_date"));
    $user_list_items{$user{'timestamp'}} = $user_list_item;
  }
  return %user_list_items;
}

sub user_data {
  my $user_file = shift @_;
  my %file;
  &open_file($user_file, USER);
  while(<USER>) {
    chomp;
    $file{'name'} = $_;
  }
  close USER;
  my @filename = split(/\//, $user_file);
  $file{'email'} = pop(@filename);
  
  @stat = stat($user_file);
  $file{'timestamp'} = $stat[9];
  
  my $user_profile_dir = "$SID/$TOPIC_DIR/$file{'name'}";
  if(-e $user_profile_dir) {
    $file{'view'} = &view_path($file{'name'});
  } elsif (&current_user($file{'email'})) {
    $file{'edit'} = &edit_path($file{'name'});
  } else {
    $file{'no_profile'} = 1;
  }
  
  return %file;
}



