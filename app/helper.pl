#!/usr/bin/perl -w

require "globals.pl";
# require "file_helper.pl";
# require "html_helper.pl";

use POSIX qw(strftime);

sub revision_for {
  my $topic = shift @_;
  my $revision = shift @_;
  my $dir = "$STORE/$TOPIC_DIR/$topic/$revision";
}
sub most_recent_file_for {
  my $topic = shift @_;
  my $dir = "$STORE/$TOPIC_DIR/$topic";
  return unless -d $dir;
  opendir( TOPIC_DIR, $dir )
    or die "Error: cannot open $dir: $!\n";

  my $current_file;
  while ( my $name = readdir(TOPIC_DIR) ) {
    next if($name =~ /^\./);
    my $filename = "$dir/$name";
    next unless -f $filename and -r $filename;
    if ( !defined $current_file || $name > $current_file) {
      $current_file = $name;
    }
  }
  return "$dir/$current_file";
}

sub most_recent_files_for_all_topics {
  my @topic_list = ();
  my $dir = "$STORE/$TOPIC_DIR";
  opendir( ALL_TOPICS, $dir )
    or die "Error: cannot open $dir: $!\n";

  my $current_file = "";
  while ( my $name = readdir(ALL_TOPICS) ) {
    next if($name =~ /^\./);
    $current_file = &most_recent_file_for($name);
    push(@topic_list, $current_file);
  }
  return @topic_list;
}
sub revisions_for_topic {
  my @topic_list = ();
  my $topic_dir = shift @_;
  my $dir = "$STORE/$TOPIC_DIR/$topic_dir";
  my $most_recent = most_recent_file_for($topic_dir);
  return unless -d $dir;
  opendir( REVISIONS, $dir )
    or die "Error: cannot open $dir: $!\n";
  while ( my $name = readdir(REVISIONS) ) {
    next if($name =~ /^\./);
    my $filename = "$dir/$name";
    next unless -f $filename and -r $filename;
    next if $filename eq $most_recent;
    push(@topic_list, $filename);
  }
  return @topic_list;
}


sub search_html {
  print "<div id='search_form'>";
  print start_form(-method=>"GET", -action=>'topic_search'),
    h4("Search"),
    textfield({-style => "font-size:75%", -class=> 'text',-name => 'term', -value => param('term')}),
    span({-class => "submit"},
      submit("Go"),
    ),
  end_form;
  print "</div>";
}

sub page_start {
  print start_html( -title    => "Unix Tools: Final Assignment, Topic Fu", 
          -style     => {-src => "$PUBLIC_DIR/stylesheets/topic_fu.css"},
          -script=>[{-type=>'text/javascript', -src=>"$PUBLIC_DIR/javascript/jquery-1.2.6.js"},
                    {-type=>'text/javascript', -src=>"$PUBLIC_DIR/javascript/topic_fu.js"}],
          -text     => "#666",
        );
}
sub page_title {
  my $page_title = shift @_;
  my $page_topic = shift @_;
  my ($crumb);
  unless ($page_title eq 'HOME') { $crumb = ": <span id='page'>$page_title</span>"; }
  print div({-id => "wrapper"});
  &search_html;
  if($page_title eq 'VIEW') {
    &sidebar_topics("Previous  Revisions", &previous_revisions(param('topic')))
  } else {
    &sidebar_topics("Recent Updates", &recent_topics(5)); 
  }
  
  print div({-id => "main"});
  print h1(a({-href=>$HOME_URL}, "TOPIC_FU"), $crumb);
  if ($page_title eq 'HOME') {
    print h2({-class => "page_title"}, "Choose a topic");
  } elsif ($page_title eq 'SEARCH') {
    print h2({-class => "page_title"}, "Search Results");
  } else {
    print h2({-class => "page_title"}, $page_topic);
    if($page_title eq 'VIEW') {
      my $revision;
      if(param('revision')) {
        $revision = &time_format("%l:%M:%S %p %b %d, %Y", param('revision'));
      }else{
        $revision = "Latest";
      }
      print h3({-class => "version"}, "Version: $revision");
    }
  }
  
  print "<hr/>";
}
sub footer {
    # foreach $key (sort keys(%ENV)) {
    #       warn "$key = $ENV{$key}";
    #    }
}
sub get_topic_and_validate {
  if(param('action')) {
    if(param('topic')) {
      ($FLASH = error_on_topic_text(param('topic'))) || return param('topic');
    } else {
      $FLASH = "Error: topic cannot be blank!";
      warn "validation error: topic left blank";
    }
  }
  return "Choose a topic";
}
sub error_on_topic_text {
  foreach (@_) {
    if(/[^A-Za-z0-9]+/) {
      warn "Error: topic contains invalid chars";
      return "Error: topic contains invalid chars"; 
    }
  }
}

sub get_action {
  if(param('action')) {
    return param('action');
  } else {
    return 'home';
  }
}
sub home_dir {
  return "/Users/ross" if $DEBUG;
  return "/home/rk1023";
}

sub html_format {
  $_ = shift @_;
  my %escape = ('&' => '&amp;', '<' => '&lt;', '>' => '&gt;');
  my $replace = join '', keys %escape;
  s/([$replace])/$escape{$1}/g;
  s/^\r[\n]?$/<p>/gm;
  s/^---\+ ([^\r\n]*)/<h1>$1<\/h1>/gm;
  s/^---\+\+ ([^\r\n]*)/<h2>$1<\/h2>/gm;
  s/^---\+\+\+ ([^\r\n]*)/<h3>$1<\/h3>/gm;
  s/\*([^\*]*)\*/<b>$1<\/b>/gm;
  s/_([^_]*)_/<i>$1<\/i>/gm;
  s/\!([^\!]*)\!/<img src="$1" \/>/gm;
  $_ = &bulleted_lists($_);
  s/[\r\n]*//gm;
  $_ = &link_topics($_);
  return $_;
}
sub bulleted_lists {
  my $html = shift @_;
  $html =~ s/\r\n- ([^\r\n]*)/<li>$1<\/li>/g;
  $html =~ s/(<li>.*<\/li>)[^<]?/<ul>$1<\/ul>/g;
  $html =~ s/\r\n[0-9]+\. ([^\r\n]*)/<li>$1<\/li>/g;
  $html =~ s/([^>])(<li>.*<\/li>)[^<]?/$1<ol>$2<\/ol>/g;
  return $html;
}
sub link_topics {
  my $html = shift @_;
  @topics = `ls $SID/$TOPIC_DIR`;
  foreach(@topics) {
    chomp($_);
    my $href = &view_path($_);
    $html =~ s/$_/<a href="$href">$_<\/a>/gm;
  }
  return $html;
}

sub file_data {
  $_ = shift @_;
  my %file;
  my @filename = split(/\//, $_);
  $file{'timestamp'} = pop(@filename);
  $file{'name'} = pop(@filename);
  $file{'href'} = &view_path($file{'name'}, $file{'timestamp'});
  return %file;
}

sub sorted_topic_list {
  return sort{
    @list_a = split(/\//, $a);
    @list_b = split(/\//, $b);
    my $time_a = pop(@list_a);
    my $time_b = pop(@list_b);
    return $time_b <=> $time_a;
  } @_;
}

sub time_format {
  my $format = shift @_;
  my $time = shift @_;
  return strftime($format, localtime($time));
}

sub warn_params {
  my $query = shift @_;
  %params = $query->Vars;
  my $text = "params: { ";
  while ( my($key, $value) = each %params) {
    $text = $text . $key . " => " . "$value" . ", ";
    $text =~ s/\n//g;
  }
  $text = $text . "}";
  warn $text;
}

sub sidebar_topics {
  my $text = shift @_;
  @recent = @_;
  print div({-id => "sidebar_topics"},
    h4($text),
    ul("@recent"),
  );
}

sub recent_topics {
  $_ = shift @_;
  my @topic_list = &most_recent_files_for_all_topics;
  my @sorted_topic_list = &sorted_topic_list(@topic_list);
  return &topic_list_items_for(@sorted_topic_list);
}

sub previous_revisions {
  $_ = shift @_;
  my @topic_list = &revisions_for_topic($_);
  my @sorted_topic_list = &sorted_topic_list(@topic_list);
  &topic_list_items_for(@sorted_topic_list)
}
sub topic_list_items_for {
  my @topic_list_items = ();
  my $count = 1;
  foreach $topic_file (@_) {
    last if $count > 5;
    my %file_data = &file_data($topic_file);
    push(@topic_list_items, li({-class => "topic_$count"}, 
      a({-href=>$file_data{'href'},-class =>'topic_title'}, $file_data{'name'}),
      "<br />",
      span(
          &time_format("%l:%M:%S %p %b %d, %Y", $file_data{'timestamp'})
        )
      )
    );
    $count = $count + 1;
  }
  return @topic_list_items;
}

#Routes
sub view_path {
  my $file = shift @_;
  my $timestamp = shift @_;
  my $url = "$HOME_URL?action=view&topic=$file";
  if (param('action') and (param('action') eq 'edit' or param('action') eq 'view')) {
    $url = $url . "&revision=$timestamp" if $timestamp;
  }
  return $url;
}
sub edit_path {
  my $file = shift @_;
  return "$HOME_URL?action=edit&topic=$file";
}

sub debug {
  warn "@_" if $DEBUG;
}
