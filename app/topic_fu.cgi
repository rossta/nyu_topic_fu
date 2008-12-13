#!/usr/bin/perl -w
# Author: Ross Kaffenberger;
# SID: N19663559;
# URL: http://cs.nyu.edu/~rk1023/cgi-bin/unixtool/topic_fu
require "helper.pl";

use CGI qw(-debug :standard);

print header("text/html");

my ($file);
my $query = CGI::->new();
my $action = &get_action;
my $topic = &get_topic_and_validate;
my $page = uc $action;

&page_start;
warn "sending to $page" if $DEBUG;
&warn_params($query);
$page = &page_redirect($page);
warn "directing to $page" if $DEBUG;
&page_title($page, $topic);

&show_flash;
# Page Body
if($page eq 'HOME') {
  &topic_form;
} elsif ($page eq 'VIEW') {
  &show_view;
  print "<hr />";
  print a({-href => &edit_path($topic)}, "Edit");
  &back_button;
} elsif ($page eq 'EDIT') {
  &edit_form;
  &back_button;
} elsif ($page eq 'PREVIEW') {
  &show_preview;
  &preview_form;
  &back_button('edit', "Cancel and go back");
}
print "</div>";

&footer;
print end_html;

sub page_redirect {
  my $p = $_[0];
  if($FLASH || $p eq 'HOME') { return 'HOME'; }
  if($p eq 'VIEW') {
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
  } elsif ($p eq 'EDIT') {
    $file = &most_recent_file_for($topic);
    if ( -e $file && -f $file) {
      &open_file($file);
    }
  } elsif ($p eq 'CREATE') {
    my $data = param('content');
    my $time = time;
    my $file_key = "$SID/$TOPIC_DIR/$topic/$time";
    my $store_cmd = "simplestore write $file_key \"$data\"";
    warn "store command: $store_cmd" if $DEBUG;
    `$store_cmd`;
    
    my $index_key = "$SID/$INDEX_DIR/$topic";
    my $index_cmd = "simpleindex $file_key | simplestore write $index_key";
    warn "index command: $index_cmd" if $DEBUG;
    `$index_cmd`;
    
    if ( -e "$SID/$TOPIC_DIR/$topic/$time") {
      $FLASH = "Topic '$topic' saved successfully!"
    } else {
      $FLASH = "Error: '$topic' file not saved.";
      return 'PREVIEW';
    }
    $topic = "Choose a topic";
    return 'HOME';
  }
  return $p;
}

sub open_file {
  my $file = $_[0];
  warn "opening file: $file";
  open( CONTENT, $file )
    or die "Error: cannot open $file: $!\n";
}


sub edit_form {
  my $content;
  while (<CONTENT>) {
    $content = $content.$_;
  }
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
  my $text = $_[1] || "Back";
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
  printf div({-class => "content" }, &html_format($text));
}

sub show_flash {
  if($FLASH) {
    print p({-class => "flash"},
      $FLASH,
    );
  }
}

sub back_link {
  my $text = $_[0] || "Cancel and go back";
  my $href = $_[1] || $HOME_URL;
  print a({-href=>$href, -class=>'back'}, $text);
}
