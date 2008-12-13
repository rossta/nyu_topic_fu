Story: Assignment 4 - MyTopic
  
  As an NYU student
  I want to view and edit topics online
  So that I can share information with other students
  
  Overview:
    Perl cgi script called topic_fu to allow a user to view, edit, and store text documents 
  
  Project
    should generate all content and actions from cgi script
    should not contain static HTML documents
    should use simplestore command to create, read, update, delete contents, etc
    script should be executable
    script should be accessible as http://cs.nyu.edu/~username/cgi-bin/unixtool/topic_fu
    should restrict access to NYU with: ~/public/cgi-bin/unixtool/.htaccess (perms 604) 
      deny from all\nallow from .nyu.edu\nAuthType Basic\nAuthName "NYU Only"
  
  Homepage
    should contain form elements for a user to choose to view a topic
    should contain form elements for a user to choose to edit a topic
    should contain form elements for a user to enter the topic name
    
  Topic Names
    should contain only alphabets and digits
    should generate a HTML error msg if user enters an invalid topic name
    should create a new topic by editing a non-existent topic
    should generate an error if user attempts to view an non-existent topic
    
  Edit Page
    should have a textarea for editing topic contents
    should use CRLF for line break in textarea (i.e., \r\n)
    should be empty if topic does not already exist
    should contain most recent existing content if topic already exists
    should provide a button to preview
  
  Preview Page
    should show HTML formatted view of content
    should provide a save button for saving
    should save with original formatting rules (not HTML)
    should redirect to the home page after successful save
  
  View Page
    should show HTML formatted view of content
    should generate HTML directly from contents of last version of topic
    should not contain a save button
  
  Formatting
    Blank line creates a new paragraph
                                    <p></p>
    Line starting with three dashes (---) followed by one to three plus (+) followed by a space creates a heading with the rest of the line.  The heading level is defined by the number of +.
    	---+ This is the title        <h1>This is test title</h1>
      ---+++ subtitle               <h3>subtitle</h3>      	
    Bold texts are enclosed with a pair of asterisks (*)
    	*wow*                         <b>wow</b>
    Italic texts are enclosed with a pair of underscores (_)
    	_hello_                     	<i>hello</i>
    The symbols &, <, and > should be replaced by their HTML counterparts
      x<1 & y>0                     x&lt;1 &amp; y&gt;0
      
  Versions
    should store topic using key SID/topic/topicname/time
    SID is N19663559
    Time is the number of non-leap seconds since the epoch when the document is saved: Perl function time()
    should store topic contents as key value
    should save all versions of topic as separate keys
    all keys should differ by last component