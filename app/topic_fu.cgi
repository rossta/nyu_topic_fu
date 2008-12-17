#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;
# URL: http://cs.nyu.edu/~rk1023/cgi-bin/unixtool/topic_fu

require "helper.pl";
require "app_helper.pl";

use CGI qw(-debug :standard);

my $user = cookie('user');
my $email = cookie('email');
if(defined $user and verify($user, $email)) {
  $user_cookie = cookie(-name => 'user', -value => $user);
  $email_cookie = cookie(-name => 'email', -value => $email);
  if (param('new_user')) {
   $FLASH = "Welcome to Topic Fu, $user!"; 
  } else {
   $FLASH = "Welcome back, $user!"; 
  }
} else {
  print redirect(-uri => &login_path);
}
my $file;
my $query = CGI::->new();
my $action = &get_action;
my $topic = &get_topic_and_validate;
my $page = uc $action;
warn "sending to $page" if $DEBUG;
&warn_params($query);
$page = &page_redirect($page);
warn "directing to $page" if $DEBUG;

print header(-type => "text/html", -cookie => [$user_cookie, $email_cookie]);
&page_start;
&page_title($page, $topic);

&show_flash;
# Page Body
if($page eq 'HOME') {
  &topic_form;
} elsif ($page eq 'VIEW') {
  &show_view;
  &view_nav;
  &revision_select_form;
  &comment_form;
  &show_comments;
  &back_button;
} elsif ($page eq 'EDIT') {
  &edit_form;
  &back_button;
} elsif ($page eq 'PREVIEW') {
  &show_preview;
  &preview_form;
  &back_button('edit', "<< Cancel and go back");
} elsif ($page eq 'COMPARE') {
  &show_comparison;
  &back_button('view', "<< Back to view");
}
print "<div style='clear:left'></div>";
print "</div>";

&footer;
print end_html;

sub page_redirect {
  my $p = $_[0];
  if($FLASH || $p eq 'HOME') { return 'HOME'; }
  if($p eq 'VIEW') {
    $p = &view_redirect;
  } elsif ($p eq 'EDIT') {
    $file = &most_recent_file_for($topic);
    if ( -e $file && -f $file) {
      &open_file($file);
    }
  } elsif ($p eq 'CREATE') {
    my $data = param('content');
    my $topic_dir = "$TOPIC_DIR/$topic";
    my $file_key = &simplestore_data_to($topic_dir, $data);
        
    my $index_key = "$SID/$INDEX_DIR/$topic";
    my $index_cmd = "simpleindex $file_key | simplestore write $index_key";
    warn "index command: $index_cmd" if $DEBUG;
    `$index_cmd`;
    
    if ( -e "$file_key") {
      $FLASH = "Topic '$topic' saved successfully!"
    } else {
      $FLASH = "Error: '$topic' file not saved.";
      return 'PREVIEW';
    }
    $topic = "Choose a topic";
    return 'HOME';
  } elsif ($p eq 'COMMENT') {
    $p = &view_redirect;
    my $comment = param('comment');
    if ($comment) {
      my $comment_dir = "$COMMENT_DIR/$topic/$email";
      my $file_key = &simplestore_data_to($comment_dir, $comment);
      if ( -e "$file_key") {
        $FLASH = "Your comment has been added"
      } else {
        $FLASH = "Sorry, your comment could not be saved.";
      }
    } else {
      $FLASH = "Gotta type your comment to add your comment!";
    }
  # }   elsif ($p eq 'DELETE') {
  #   $p = &view_redirect;
  #   
  #   if (&current_user(param('email'))) {
  #     my $file_to_delete = param('entry');
  #     if ( -e $file_to_delete ) {
  #       my $delete_cmd = "simplestore delete \"$file_to_delete\"";
  #       warn "delete command: $delete_cmd" if $DEBUG;
  #       `$delete_cmd`;
  #       if (! -e $file_to_delete ) {
  #         $FLASH = "Your comment has been deleted";
  #       } else {
  #         $FLASH = "No luck, your comment wasn't deleted";
  #       }
  #       my $flash_cookie = cookie(-name => 'flash', -value => $FLASH);
  #       print redirect(-uri => &view_path, -cookie => $flash_cookie);
  #     }
  #   }
  #   my $entry = param('entry');
  } elsif ($p eq 'COMPARE') {
    $topic = 'Compare'
  }
  return $p;
}

sub view_redirect {
  if(param('revision')) {
    $file = &revision_for($topic, param('revision')); 
  } else {
    $file = &most_recent_file_for($topic); 
  }
  warn "filename: $file" if $DEBUG;
  if ( -e $file && -f $file) {
    &open_file($file);
  } else { 
    $FLASH = "Error: topic does not exist"; 
    $topic = "Choose a topic";
    return 'HOME' 
  }
  return 'VIEW';
}
sub edit_form {
  my $content;
  while (<CONTENT>) {
    $content = $content.$_;
  }
  close(CONTENT);
  param('action','preview');
  print start_form,
    p({-class => "topic" },
      textarea({-style => "font-size:85%", -name => 'content', -rows => 15, -columns => 50, -default => $content }),
      hidden(-id=>'action_tag',-name=>'action'),
      hidden(-id=>'topic_tag', -name=>'topic', -default=>[param('topic')]),
      "<hr />",
      div({-class => "submit"},
        submit("Preview"),
      ),
    ),
  end_form;
}
sub topic_form {
  param('action','view');
  print start_form,
    div({-class => "instructions"}, "Enter a topic ",
      span({-class => "action"},
        radio_group(-name=>'action',-values=>['view','edit'],-default=>'view'),
      ),
    ),
    p({-class => "topic" },
      label("Topic:"),
      textfield({-style => "font-size:100%", -name => 'topic', -value => param('topic')}),
      span({-class => "submit"},
        submit("Go"),
      ),
    ),
    end_form;
}

sub preview_form {
  param('action','create');
  print start_form,
    hidden(-id=>'action_tag',-name=>'action'),
    hidden(-id=>'topic_tag', -name=>'topic', -default=>[param('topic')]),
    hidden(-id=>'content_tag', -name=>'content', -default=>[param('content')]),
    "<hr />",
    div({-class => "submit"},
      submit("Save"),
    ),
  end_form;
}

sub back_button {
  my $back_to = $_[0] || 'home';
  my $text = $_[1] || "<< Home";
  param('action',$back_to);
  
  print start_form,
    hidden(-name=>'action'),
    hidden(-name=>'topic', -default=>[param('topic')]),
    hidden(-name=>'content', -default=>[param('content')]),
    span({-class => "back"},
      submit($text),
    ),
  end_form;
}
sub show_preview {
  printf div({-class => "content" }, &html_format(param('content')));
}

sub show_view {
  my $text = "";
  while(<CONTENT>) {
    $text = $text . $_;
  }
  close (CONTENT);
  printf div({-class => "content" }, &html_format($text));
}

sub show_comments {
  if (my @comment_files = &comments_on($topic)) {
    @comment_files = &sorted_timestamp_file_list(@comment_files);
    print "<h4 name='comments'>Comments</h4>";
    print "<ul id='comments'>";
    foreach $file (@comment_files) {
      if ( -e $file && -f $file) {
        my $email = $file;
        my $date = $file;
        $date =~ s/.*\/([^\/]*)$/$1/g;
        $date = &time_format($date);
        $email =~ s/.*\/([^\/]*)\/.*$/$1/g;
        &open_file($file, COMMENT);
        my $comment = "";
        while(<COMMENT>) {
          $comment = $comment . $_;
        }
        close COMMENT;
        print "<li class = 'comment'>",
          "<p class='author'><span>".&user_name_for($email)."</span> says </p>",
          &html_format($comment);
        print "<hr />";
        # &delete_button($file, $email) if &current_user($email);
        print "<p class='date'>$date</p>";
        print "</li>";
      }
    }
    print "</ul>";
  } else {
    print p({-class => 'blank_slate'}, "Be the first to post a comment!");
  }
}

# sub delete_button {
#   my $entry = shift @_;
#   my $author_email = shift @_;
#   param('action', 'delete');
#   param('entry', $entry);
#   param('email', $author_email);
#   print start_form,
#     hidden(-name=>'action'),
#     hidden(-name=>'topic', -default => $topic),
#     hidden(-name=>'entry'),
#     hidden(-name=>'email'),
#     "<button class='delete'>Delete this comment</button>",
#   end_form;
# }
sub comments_on {
  my $topic = shift @_;
  my @comment_file_list;
  my $comment_dir = "$SID/$COMMENT_DIR/$topic";
  return unless -e $comment_dir and -d $comment_dir;
  opendir( COMMENT_DIR, $comment_dir )
    or die "Error: cannot open $comment_dir: $!\n";
  while( my $author = readdir(COMMENT_DIR)) {
    next if($author =~ /^\./);
    my $author_dir = "$comment_dir/$author";
    next unless -d $author_dir and -r $author_dir;
    opendir( AUTHOR_DIR, $author_dir ) 
      or die "Error: cannot open $author_dir: $!\n";
    while ( my $comment = readdir(AUTHOR_DIR)) {
      next if($comment =~ /^\./);
      my $comment_file = "$author_dir/$comment";
      next unless -f $comment_file and -r $comment_file;
      push (@comment_file_list, $comment_file);
    }
    close AUTHOR_DIR;
  }
  close COMMENT_DIR;
  return @comment_file_list;
  
}

sub comment_form {
  param('action', 'comment');
  print "<div id='comment_form'>";
  print start_form,
    hidden(-name=>'action'),
    hidden(-name=>'topic', -default=>[param('topic')]),
    hidden(-name => 'name', -default => [cookie('user')]),
    hidden(-name => 'email', -default => [cookie('email')]),
    "<table><tr><td>",
    label("Comment"),
    "</td>",
    "<td>".
    textarea({-name => 'comment', -rows => 5, -columns => 56 }),
    "</td></tr><tr><td>&nbsp;</td><td>",
    span({-class => "comment"}, submit("Add"),),
    "</td></tr>",
    "</table>",
  end_form;
  print "</div>";
}

sub back_link {
  my $text = $_[0] || "Cancel and go back";
  my $href = $_[1] || &fu_path;
  print a({-href=>$href, -class=>'back'}, $text);
}

sub view_nav {
  print "<hr />";
  print "<div class='view_nav'>";
  if(param('revision')) {
    print a({-href => &view_path($topic), -class => 'nav_link'}, "Back to latest");
  } else {
    print a({-href => &edit_path($topic), -class => 'nav_link'}, "Edit topic");
    print a({-href => '#', -class => 'nav_link add_comment'}, "Add comment");
    print a({-href => '#', -class => 'nav_link compare'}, "Compare");
  }
  print "</div>";
}

sub revision_select_form {
  param('action', 'compare');
  print "<div id='revision_select_form'>";
  print start_form,
    hidden(-name=>'action'),
    hidden(-name=>'revision'),
    hidden(-name=>'topic', -default=>[param('topic')]);
    
    my @values = revisions_for_topic(param('topic'));
    my %labels;
    foreach $value (@values) {
      $value =~ s/.*\/([0-9]*)$/$1/g;
      debug("value $value");
      $labels{$value} = &time_format($value);
    }
    print label({-for => 'revision_2'}, "Revisions");
    print popup_menu(-name => 'revision_2', -values => \@values, -labels => \%labels);
    print span({-class => "compare"}, submit("Go")), 
    end_form;
  print "</div>";
}

sub show_comparison {
  my $compare_topic = param('topic');
  my($file_1, $file_2);
  if(param('revision')) {
    $file_1 = &revision_for($compare_topic, param('revision')); 
  } else {
    $file_1 = &most_recent_file_for($compare_topic); 
  }
  $file_2 = &revision_for($compare_topic, param('revision_2'));
  my @diff = `diff \"$file_1\" \"$file_2\"`;
  if(@diff) {
    print "<p>",
      join("<br/>", @diff),
      "</p>";
  } else {
    print "<p>The two files are identical.</p>";
  }
}

sub page_header {
  my $page_title = shift @_;
  my $page_topic = shift @_;
  
  if ($page_title eq 'HOME') {
    print h2({-class => "page_title"}, "Choose a topic");
  } else {
    print h2({-class => "page_title"}, $page_topic);
    if($page_title eq 'VIEW') {
      my $revision;
      if(param('revision')) {
        $revision = &time_format(param('revision'), "%l:%M:%S %p %b %d, %Y");
      }else{
        $revision = "Latest";
      }
      print h3({-class => "version"}, "Version: $revision");
    }
  }
}