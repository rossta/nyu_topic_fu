#!/usr/bin/perl -w

$DEBUG = 1;
$SID = param('test_link') || "N19663559";
$TOPIC_DIR = param('test_dir') || "topic";
$INDEX_DIR = param('test_index_dir') || "index";
$COMMENT_DIR = param('test_comment_dir') || "comments";
$USER_DIR = param('test_user_dir') || "user";
$PUBLIC_DIR = "/public";
$HOME_DIR = &home_dir;
$STORE = "$HOME_DIR/.simplestore";
$ENV{'PATH'} = "$HOME_DIR/bin:$ENV{'PATH'}";
$IMAGE_TAG = "___IMAGE___";

