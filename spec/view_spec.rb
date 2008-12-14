require 'spec/env'

describe "view" do
  
  describe "validation" do
    
    it "should return an error message with view if it does not exist" do
      params = { "topic" => "Harvard", "action" => "view" }
      response_post(".flash", params).should == "Error: topic does not exist"
    end
    
    it "should send to homepage if topic does not exist" do
      params = { "topic" => "Harvard", "action" => "view" }
      response_post("h2.page_title", params).should == "Choose a topic"
    end
    
    it "should send to homepage if topic does not exist" do
      params = { "topic" => "Harvard", "action" => "view" }
      response_post("div.instructions", params).should =~ /Enter a topic/
    end
    
  end
  
  describe "response" do
    before(:each) do
      symlink(HOME_DIR, STUDENT_ID)
      simplestore_write("#{TOPIC_KEY}/Princeton/1", "Its where I went to school!")
    end

    it "should contain a link to go back" do
      pending
      params = { "topic" => "Princeton", "action" => "view" }
      response_post_attribute(".back input", "value", params).should == "<< Home"
    end
    
    it "should retrieve content for an existing topic" do
      params = { "topic" => "Princeton", "action" => "view" }
      response_post("#page", params).should == "VIEW"
    end
    
    it "should retrieve content for an existing topic" do
      params = { "topic" => "Princeton", "action" => "view" }
      response_post("div.content", params).should == "Its where I went to school!"
    end
    
    it "should retrieve most recent content" do
      simplestore_write("#{TOPIC_KEY}/Princeton/2", "This is more recent content.")
      params = { "topic" => "Princeton", "action" => "view" }
      response_post("div.content", params).should == "This is more recent content."
    end
    
    it "should reset page title if topic does not exist" do
      params = { "topic" => "Harvard", "action" => "view" }
      response_post("h2.page_title", params).should == "Choose a topic"
    end
    
    it "should use special html formatting" do
      params = { "topic" => "abc", "content" => SAMPLE_PREVIEW_ENTRY, "action" => "create" }
      response_post("body", params)

      params["action"] = "view"
      response_post("div.content", params).should_not =~ /---\+ /
      response_post("div.content", params).should_not =~ /---\+\+ /
      response_post("div.content", params).should_not =~ /---\+\+\+ /
    end
    
    after(:each) do
      clear_test_dir
      remove_link(STUDENT_ID)
    end
    
  end
  
end