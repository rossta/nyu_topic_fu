#!/usr/bin/perl -w

require "globals.pl";
require "file_helper.pl";
require "html_helper.pl";

use POSIX qw(strftime);

sub revision_for {
  my $topic = shift @_;
  my $revision = shift @_;
  my $dir = "$STORE/$TOPIC_DIR/$topic/$revision";
}
sub most_recent_file_for {
  my $topic_dir = shift @_;
  my $dir = "$STORE/$TOPIC_DIR/$topic_dir";
  return unless -d $dir;
  opendir( TOPIC_DIR, $dir )
    or die "Error: cannot open $dir: $!\n";

  my $current_file;
  while ( my $f = readdir(TOPIC_DIR) ) {
    next unless -f "$dir/$f";
    if ( !defined $current_file || $f > $current_file) {
      $current_file = $f;
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
  while ( my $f = readdir(ALL_TOPICS) ) {
    next if($f eq ".");
    next if($f eq "..");
    $current_file = &most_recent_file_for($f);
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
  while ( my $f = readdir(REVISIONS) ) {
    my $filename = "$dir/$f";
    next unless -f $filename;
    push(@topic_list, $filename);
  }
  warn "revisions : @topic_list" if $DEBUG;
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
          -script=>[{-type=>'text/javascript', -src=>"$PUBLIC_DIR/javascript/jquery.min.js"},
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
    &sidebar_topics("Recent Revisions", &previous_revisions(param('topic')))
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
  warn "formatting: $_" if $DEBUG;
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
  warn "formatting: $_" if $DEBUG;
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
  warn "dir: $SID/$TOPIC_DIR" if $DEBUG;
  @topics = `ls $SID/$TOPIC_DIR`;
  foreach(@topics) {
    chomp($_);
    my $href = &view_path($_);
    $html =~ s/$_/<a href="$href">$_<\/a>/gm;
  }
  warn "html: $html" if $DEBUG;
  return $html;
}

sub file_data {
  $_ = shift @_;
  %file = {};
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

#Routes
sub view_path {
  my $file = shift @_;
  my $timestamp = shift @_;
  my $url = "$HOME_URL?action=view&topic=$file";
  $url = $url . "&revision=$timestamp" if $timestamp;
  return $url;
}
sub edit_path {
  my $file = shift @_;
  return "$HOME_URL?action=edit&topic=$file";
}
