#!/usr/bin/perl -w

$DEBUG = 1;
$SID = param('test_link') || "N19663559";
$TOPIC_DIR = param('test_dir') || "topic";
$INDEX_DIR = param('test_index_dir') || "index";
$COMMENT_DIR = param('test_comment_dir') || "comments";
$USER_DIR = param('test_user_dir') || "user";
$HOME_DIR = &home_dir;
$STORE = "$HOME_DIR/.simplestore";
$ENV{'PATH'} = "$HOME_DIR/bin:$ENV{'PATH'}";
$IMAGE_TAG = "___IMAGE___";
$DEVELOPMENT = "http://localhost";
$STAGING = "http://linserv1.cims.nyu.edu:15826";
$PRODUCTION = "http://cs.nyu.edu/~rk1023";
$HOST = $DEVELOPMENT if $DEBUG eq 1;
$HOST = $STAGING if $DEBUG eq 2;
$HOST = $PRODUCTION if $DEBUG eq 0;
$CGI_URL = "$HOST/cgi-bin/unixtool";
$CGI_URL = "$HOST/cgi-bin" if $DEBUG eq 1;
$PUBLIC_DIR = "$HOST/";
$PUBLIC_DIR = "$HOST/public" if $DEBUG eq 1;
return 1;
