require 'spec/env'

describe "homepage" do
  
  describe "recently edited topics" do
    before(:each) do
      6.times do |i|
        params = { "topic" => "topic_#{i}", "content" => "This is topic number #{i}.", "action" => "create" }
        response_post("body", params)
      end
    end
        
    it "should have a sections for recent topics" do
      response("#sidebar_topics h4").should == "Recent Updates"
    end
    it "should show last 5 edited topics" do
      pending
      response("#sidebar_topics ul li:nth-child(1) .topic_title a").should == "topic_6"
    end
    
    after(:each) do
      clear_test_dir
    end
  end
  
  describe "response" do
    it "should contain a app title" do
      response("h1 a").should == "topic_fu".upcase
    end
    
    it "should contain a page title" do
      response("h2.page_title").should == "Choose a topic"
    end
    
    it "should be titled Choose a topic on topic entry error" do
      params = { "topic" => "!@#* error *", "action" => "view" }
      response("h2.page_title").should == "Choose a topic"
    end
    
    it "should contain instructions" do
      response("div.instructions").should =~ /Enter a topic/
    end
  end

  describe "form" do
    it "should have a text input for topic" do
      response_attribute("form .topic input", "type").should == "text"
      response_attribute("form .topic input", "name").should == "topic"
    end

    it "should contain a radio button option to view" do
      response_attribute("form .action input:first", "type").should == "radio"
      response_attribute("form .action input:first", "value").should == "view"
    end
    
    it "should contain an option to edit topic" do
      response_attribute("form .action input:last", "type").should == "radio"
      response_attribute("form .action input:last", "value").should == "edit"
    end

    it "should contain a submit button" do
      response_attribute("form .submit input", "type").should == "submit"
      response_attribute("form .submit input", "value").should == "Go"
    end
  end
  
  describe "topic names" do
    before(:each) do
      symlink(HOME_DIR, STUDENT_ID)
    end

    it "should be valid if containing letters" do
      simplestore_write("#{TOPIC_KEY}/abc/1", "yo")
      params = { "topic" => "abc", "action" => "view" }
      response_post("h2.page_title", params).should == "abc"
    end
    
    it "should be valid if containing numbers" do
      simplestore_write("#{TOPIC_KEY}/123/1", "yo")
      params = { "topic" => "123", "action" => "view" }
      response_post("h2.page_title", params).should == "123"
    end
    it "should be valid if containing letters and numbers" do
      simplestore_write("#{TOPIC_KEY}/abc123/1", "yo")
      params = { "topic" => "abc123", "action" => "view" }
      response_post("h2.page_title", params).should == "abc123"
    end

    it "should be invalid if containing non-alphanumeric chars" do
      params = { "topic" => "_@#/?,.", "action" => "view" }
      response_post(".flash", params).should == "Error: topic contains invalid chars"
    end

    it "should be invalid if blank" do
      params = { "topic" => "", "action" => "edit" }
      response_post(".flash", params).should == "Error: topic cannot be blank!"
    end
    
    it "should repopulate topic if invalid" do
      params = { "topic" => "_@#/?,.", "action" => "view" }
      response_post_attribute("form .topic input", "value", params).should == "_@#/?,."
    end
    
    after(:each) do
      clear_test_dir
      remove_link(STUDENT_ID)
    end
    
  end
  
  after(:each) do
    clear_test_dir
  end
end