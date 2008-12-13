#!/usr/bin/perl -w

$DEBUG = 1;
$SID = param('test_link') || "N19663559";
$TOPIC_DIR = param('test_dir') || "topic";
$INDEX_DIR = param('test_index_dir') || "index";
$PUBLIC_DIR = "/public";
$HOME_URL = "topic_fu";
$HOME_DIR = &home_dir;
$STORE = "$HOME_DIR/.simplestore";
$ENV{'PATH'} = "$HOME_DIR/bin:$ENV{'PATH'}";

