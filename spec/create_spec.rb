require 'spec/env'

describe "create" do
  
  describe "indexing" do
    before(:each) do
      text = `cat #{SIMPLE_INPUT}`
      @expected_output = `cat #{SIMPLE_OUTPUT}`
      @params = { "topic" => "abc", "content" => text, "action" => "create" }
    end
    
    it "should create search index dir if it does not exist" do
      response_post("body", @params)
      pending
      File.directory?(INDEX_DIR).should be_true
    end

    it "should create topic index file if it does not exist" do
      response_post("body", @params)
      File.exists?("#{INDEX_DIR}/abc")
      `cat #{INDEX_DIR}/abc`.should == @expected_output
    end
    
    it "should update existing topic index file" do
    end
  end
  
  describe "storage" do
    before(:each) do
      symlink(HOME_DIR, STUDENT_ID)
      @params = { "topic" => "abc", "content" => "This is the first topic post.", "action" => "create" }
    end
    
    it "should send to homepage" do
      response_post("h2.page_title", @params).should == "Choose a topic"
      response_post("div.instructions", @params).should =~ /Enter a topic/
    end
    
    it "should render a successful flash if successful" do
      response_post(".flash", @params).should == "Topic 'abc' saved successfully!"
    end
    
    it "should render an error flash if store fails"
        
    it "should create a symlink to .simplestore if it does not exist" do
      pending
      remove_link(STUDENT_ID)
      File.symlink?(STUDENT_ID).should be_false
      response_post(".flash", @params).should =~ /success/
      File.symlink?(STUDENT_ID).should be_true
    end

    it "should store contents with simplestore" do
      response_post("body", @params)
      File.directory?("#{TOPIC_KEY}/abc").should be_true    
    end
        
    after(:each) do
      remove_link(STUDENT_ID)
    end
    
  end
  
  describe "create" do
    before(:each) do
      @params = { "topic" => "abc", "content" => "This is the first topic post.", "action" => "create" }
    end
    
    it "should save contents containing apostrophes" do
      @params["content"] = "It's the first topic post."
      response_post(".flash", @params).should == "Topic 'abc' saved successfully!"

      @params["action"] = "view"
      response_post("div.content", @params).should == "It's the first topic post.\n"
    end
    
    it "should preserve <p> tags in view" do
      params = { "topic" => "abc", "content" => "Title\r\n\r\nI should be in a p tag.\r\n\r\nI should also be in a p tag", "action" => "preview" }
      html = "Title<p>I should be in a p tag.</p><p>I should also be in a p tag\n</p>"
      preview_response(params).should == html
      
      params["action"] = 'create'
      response_post(".flash", params).should =~ /success/
      
      params["action"] = 'view'
      preview_response(params).should == html
    end

  end  
end