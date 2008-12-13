SCRIPT = '~/bin/simplestore'
CGI_HOME = '~/Library/WebServer/cgi-bin'
VALID_OPTIONS = %w( write lookup delete increment import export )
STUDENT_ID = "N1234"
HOME_DIR = "~/.simplestore"
TOPIC_DIR = "test_topic"
TEST_DIR = "#{HOME_DIR}/#{TOPIC_DIR}"
TOPIC_KEY = "#{STUDENT_ID}/#{TOPIC_DIR}"
INDEX_DIR = "#{HOME_DIR}/index"

SAMPLE_CONTENT = "<h1>Title</h1><h2>Subtitle</h2><h3><b>Header</b></h3><p>Para <b>1</b></p><p>Para <i>2</i> &amp; <i>3</i></p><p>x&lt;1 &amp; y &gt;2 then cool.</p>"
SAMPLE_PREVIEW_ENTRY = "---+ Title\r\n---++ Subtitle\r\n---+++ *Header*\r\n\r\nPara *1*\r\n\r\nPara _2_ & _3_\r\n\r\nx<1 & y >2 then cool.\r\n"
ERR_LOG = "log/err"
OUT_LOG = "log/out"
PATH = "topic_fu"
URL = "http://localhost/cgi-bin/#{PATH}"

IMAGE_URL="http://cdn.kaltura.com/p/300/thumbnail/entry_id/b6jkbld5mg/width/100/type/1/quality/75"

FIXTURES = "spec/fixtures"
SIMPLE_INPUT = "#{FIXTURES}/simple_input.txt"
SIMPLE_OUTPUT = "#{FIXTURES}/simple_output.txt"

# tail Apace error log 
# tail -f /private/var/log/apache2/error_log

