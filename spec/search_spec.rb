require 'spec/env'
require 'CGI'

describe "search" do
  before(:each) do
    
  end
  
  describe "response" do
    it "should be titled 'Search Results'" do
      response_post("h2.page_title", { "path" => "topic_search", "term" => "hello" }).should == 'Search Results'
    end
    
    it "should work for get method" do
      response_get("h2.page_title", { "path" => "topic_search", "term" => "hello"}).should == 'Search Results'
    end
  end
end