require 'spec/env'

describe "edit" do
  
  before(:each) do
    @params = { "topic" => "Princeton", "action" => "edit" }
    symlink(HOME_DIR, STUDENT_ID)
    simplestore_write("#{TOPIC_KEY}/Princeton/1", "Its where I went to school!")
  end

  describe "response" do
    
    it "should show edit in page header" do
      response_post("#page", @params).should == "EDIT"
    end
    
    it "should set topic name to page title" do
      response_post("h2.page_title", @params).should == "Princeton"
    end
    
    it "should contain a link to go back" do
      response_post_attribute("form .back input", "value", @params).should == "<< Home"
    end
    
    it "should contain most recent existing content if topic already exists" do
      simplestore_write("#{TOPIC_KEY}/Princeton/2", "This is more recent content.")
      params = { "topic" => "Princeton", "action" => "edit" }
      response_post("textarea", params).should == "This is more recent content.\n"
    end
    
  end
  
  describe "form" do
    it "should display a textarea for topic description" do
      response_post_attribute("textarea", "name", @params).should == "content"
    end

    it "should contain an input tag to preview action" do
      response_post_attribute("#action_tag", "value", @params).should == "preview"
    end
    
    it "should contain a topic tag with topic value" do
      response_post_attribute("#topic_tag", "value", @params).should == "Princeton"
    end
    
    it "should be empty if topic does not already exist" do
      @params["topic"] = 'abc'
      response_post("textarea", @params).should == ""
    end
    
    it "should contain a submit button" do
      response_post_attribute("#main form .submit input", "type", @params).should == "submit"
    end

    it "should contain a submit button titled Preview" do
      response_post_attribute("#main form .submit input", "value", @params).should == "Preview"
    end
  end
  
  after(:each) do
    clear_test_dir
    remove_link(STUDENT_ID)
  end
  

end