#!/usr/bin/perl -w

require "globals.pl";

use POSIX qw(strftime);

sub revision_for {
  my $topic = shift @_;
  my $revision = shift @_;
  return "$STORE/$TOPIC_DIR/$topic/$revision";
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
  my @topic_list;
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
  my @topic_list;
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
  
  &app_sidebar($page_title);
  
  print div({-id => "main"});
  
  &user_status;
  
  print h1(a({-href=>&fu_path}, "TOPIC_FU"), $crumb);

  &page_header($page_title, $page_topic);
  
  print "<hr/>";
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

  @lines = split(/\r\n/, $_);
  @image_list = &grep_for_images(@lines);
  
  foreach(@lines) {
    s/^---\+ (.*)$/<h1>$1<\/h1>/gm;
    s/^---\+\+ (.*)$/<h2>$1<\/h2>/gm;
    s/^---\+\+\+ (.*)$/<h3>$1<\/h3>/gm;
    s/\*([^\*]*)\*/<b>$1<\/b>/gm;
    s/_([^_]*)_/<i>$1<\/i>/gm;
    s/\! (.*) \!/$IMAGE_TAG/gm;
    s/^- (.*)$/<li>$1<\/li>/gm;
    s/^\[$/<ul>/gm;
    s/^\]$/<\/ul>/gm;
    s/^\{$/<ol>/gm;
    s/^\}$/<\/ol>/gm;
    s/^- (.*)$/<li>$1<\/li>/gm;
    s/^$/<p>/gm;
  }
  
  @lines = &link_topics(@lines);
  foreach (@lines) {
    if(/___IMAGE___/) {
      my $image_src = shift @image_list;
      s/___IMAGE___/<img src='$image_src' \/>/i; 
    }
  }
  return join("", @lines);
}

sub grep_for_images {
  my @images = grep { /\!.*\!/ } @_;
  foreach (@images) {
    s/(.*)\! (.*) \!(.*)/$2/;
  }
  return @images;
}

sub link_topics {
  my @lines = @_;
  my @topics = `ls $SID/$TOPIC_DIR`;
  foreach $topic (@topics) {
    chomp($topic);
    foreach $line (@lines) {
      my $href = &view_path($topic);
      $line =~ s/($topic)/<a href="$href">$1<\/a>/gm;
    }
  }
  return @lines;
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

sub sorted_timestamp_file_list {
  return sort{
    @list_a = split(/\//, $a);
    @list_b = split(/\//, $b);
    my $time_a = pop(@list_a);
    my $time_b = pop(@list_b);
    return $time_b <=> $time_a;
  } @_;
}

sub time_format {
  my $time = shift @_;
  my $format = shift @_ || "%l:%M:%S %p, %b %d, %Y";
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
  print div({-id => "sidebar_topics", -class => 'activity_box sidebar'},
    h4($text),
    ul("@recent"),
  );
}

sub recent_topics {
  $_ = shift @_;
  my @topic_list = &most_recent_files_for_all_topics;
  my @sorted_topic_list = &sorted_timestamp_file_list(@topic_list);
  return &topic_list_items_for(@sorted_topic_list);
}

sub previous_revisions {
  $_ = shift @_;
  my @topic_list = &revisions_for_topic($_);
  my @sorted_topic_list = &sorted_timestamp_file_list(@topic_list);
  &topic_list_items_for(@sorted_topic_list)
}
sub topic_list_items_for {
  my @topic_list_items;
  my $count = 1;
  foreach $topic_file (@_) {
    last if $count > 5;
    my %file_data = &file_data($topic_file);
    my $comments = &comment_description($file_data{'name'}, $file_data{'href'});
    push(@topic_list_items, li({-class => "topic_$count"}, 
      a({-href=>$file_data{'href'},-class =>'topic_title'}, $file_data{'name'}),
      $comments,
      "<br />",
      span(&time_format($file_data{'timestamp'}))
      )
    );
    $count = $count + 1;
  }
  return @topic_list_items;
}

sub comment_description {
  my $topic = shift @_;
  my $href = shift @_;
  return "" if (param('action') and param('action') eq 'view');
  
  my $comment_count = &number_of_comments_for($topic);
  return "" if($comment_count eq 0);
  
  $text = "comments"; 
  $text = "comment" if $comment_count eq 1;
  if ($href) {
    $href = $href . "#comments";
  } else {
    $href = "#";
  }
  return "<a class='count' href='$href'>$comment_count $text</a>";
}

sub number_of_comments_for {
  my $topic = shift @_;
  my $count = 0;
  my $comment_dir = "$SID/$COMMENT_DIR/$topic";
  return 0 unless -e $comment_dir and -d $comment_dir;
  opendir( COMMENT_DIR, $comment_dir )
    or die "Error: cannot open $comment_dir: $!\n";
  while( my $author = readdir(COMMENT_DIR)) {
    next if($author =~ /^\./);
    my $author_dir = "$comment_dir/$author";
    $count += `ls -A "$author_dir" | wc -l`;
  }
  close COMMENT_DIR;
  return $count;
}

sub simplestore_data_to {
  my $dir = shift @_;
  my $data = shift @_;

  my $time = time;
  my $file_key = "$SID/$dir/$time";
  my $store_cmd = "simplestore write \"$file_key\" \"$data\"";
  warn "store command: $store_cmd" if $DEBUG;
  `$store_cmd`;
  return $file_key;
}

sub open_file {
  my $file = shift @_;
  my $file_handle = shift @_ || CONTENT;
  open( $file_handle, $file )
    or die "Error: cannot open $file: $!\n";
}

sub show_flash {
  my $flash = $FLASH;
  if($flash) {
    print p({-class => "flash"},$flash);
  }
}

#Routes
sub fu_path {
  return &cgi_path."/topic_fu.cgi";
}
sub cgi_path {
  return $CGI_URL;
}
sub login_path {
  return &cgi_path."/topic_login.cgi";
}
sub logout_path {
  return &login_path . "?logout=1";
}
sub signup_path {
  return &login_path."?signup=1";
}
sub view_path {
  my $file = shift @_;
  my $timestamp = shift @_;
  my $url = &fu_path."?action=view&topic=$file";
  if (param('action') and (param('action') eq 'edit' or param('action') eq 'view')) {
    $url = $url . "&revision=$timestamp" if $timestamp;
  }
  return $url;
}
sub edit_path {
  my $file = shift @_;
  return &fu_path."?action=edit&topic=$file";
}

sub debug {
  warn "@_" if $DEBUG;
}

sub verify {
  my ($user, $email) = @_;
  return $user eq &user_name_for($email);
}

sub user_name_for {
  my $email = shift @_;
  my $file_key = "$SID/$USER_DIR/$email";
  if(-e $file_key and -r $file_key) {
    &open_file($file_key, USER_FILE);
    while(<USER_FILE>) {
      chomp;
      return $_;
    }
  }
  return "Anonymous";
}

sub current_user {
  my $email = shift @_;
  return (&user_name_for($email) eq cookie('user'));
}

sub footer {
  print div({-id => 'footer'},
    a({-href=> "#"}, "user guide"),
    " | ",
    a({-href=> "#"}, "developer guide"),
    " | ",
    a({-href=> &view_path('ross')}, "the author"),
  );
}
