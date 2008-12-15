require 'spec/env'

describe "preview" do
  
  describe "topic links" do
    
    before(:each) do
      params = { "topic" => "science", "content" => "This is the science post.", "action" => "create" }
      response_post("body", params)
    end
    it "should convert a reference to another topic into a link to that topic" do
      params = { "topic" => "politics", "content" => "Politics and science don't always agree.", "action" => "preview" }
      preview_response(params).should =~ /<a.*>science<\/a>/
    end
    it "should convert a reference to another topic into a link to that topic" do
      params = { "topic" => "politics", "content" => "Politics and science don't always agree.", "action" => "preview" }
      preview_response_attribute(params, 'div.content a', 'href').should == "#{PATH}?action=view&topic=science"
    end
    after(:each) do
      clear_test_dir
    end
    
  end
  
  describe "html lists" do
    it "should convert 'here's a list:\r\n[\r\n- item 1\r\n- item 2\r\nrest' to an unordered list'" do
      params = { "topic" => "politics", "content" => "here's a list:\r\n[\r\n- item 1\r\n- item 2\r\n]\r\nrest", "action" => "preview" }
      html = "here's a list:<ul><li>item 1</li><li>item 2</li></ul>rest"
      preview_response(params).should == html
    end

    it "should convert 'here's a list:\r\n- item 1\r\n- last item' to an unordered list where list is at end of post" do
      params = { "topic" => "politics", "content" => "here's a list:\r\n[\r\n- item 1\r\n- last item\r\n]", "action" => "preview" }
      html = "here's a list:<ul><li>item 1</li><li>last item</li></ul>"
      preview_response(params).should == html
    end
    
    it "should convert multiple unordered lists" do
      params = { "topic" => "politics", "content" => "list 1:\r\n[\r\n- item 1\r\n- item 2\r\n]\r\nlist 2:\r\n[\r\n- item 3\r\n- item 4\r\n]\r\n", "action" => "preview" }
      html = "list 1:<ul><li>item 1</li><li>item 2</li></ul>list 2:<ul><li>item 3</li><li>item 4</li></ul>"
      preview_response(params).should == html
    end
    
    it "should convert 'here's a list:\r\n{\r\n1. item a\r\n2. item b\r\nrest' to an ordered list'" do
      params = { "topic" => "politics", "content" => "here's a list:\r\n{\r\n- item a\r\n- item b\r\n}\r\nrest", "action" => "preview" }
      html = "here's a list:<ol><li>item a</li><li>item b</li></ol>rest"
      preview_response(params).should == html
    end
    it "should convert unordered and ordered lists properly" do
      params = { "topic" => "politics", "content" => "Text\r\n{\r\n- item a\r\n- item b\r\n}\r\nText\r\n[\r\n- item c\r\n- item d\r\n]", "action" => "preview" }
      html = "Text<ol><li>item a</li><li>item b</li></ol>Text<ul><li>item c</li><li>item d</li></ul>"
      preview_response(params).should == html
    end
    
  end

  describe "image links" do
    it "should convert an !image link! to an image on view" do
      params = { "topic" => "politics", "content" => "Here is an image ! #{IMAGE_URL} !.", "action" => "preview" }
      preview_response(params).should =~ /<img.*src=\"#{IMAGE_URL}\".*\/>/
    end

    it "should convert an !image link! with underscores to an image on view" do
      image_url = "http://www.bjork.fr/IMG/jpg/_040_828_Bjork_newsweek.jpg"
      params = { "topic" => "politics", "content" => "image ! #{image_url} !.", "action" => "preview" }
      preview_response(params).should == "image <img src=\"#{image_url}\" \/>."
    end
  end
  
  describe "formatting" do
    before(:each) do
      @params = { "topic" => "abc", "content" => "Title\r\n\r\nI should be in a p tag.\r\n", "action" => "preview" }
    end
    
    it "should convert a blank line into a <p> tag" do
      html = "Title<p>I should be in a p tag.</p>"
      preview_response(@params).should == html
    end

    it "should convert a line break into a <br/> tag" do
      @params["content"] = "I should not\r\n have a br tag.\r\n"
      html = "I should not have a br tag."
      preview_response(@params).should == html
    end

    it "should convert first blank line into a <p> tag" do
      @params["content"] = "\r\nI should be in a p tag.\r\n"
      html = "<p>I should be in a p tag.</p>"
      preview_response(@params).should == html
    end

    it "should convert multiple blank lines into a <p> tags" do
      @params["content"] = "Title\r\n\r\nI should be in a p tag.\r\n\r\nI should also be in a p tag\r\n"
      html = "Title<p>I should be in a p tag.</p><p>I should also be in a p tag</p>"
      preview_response(@params).should == html
    end

    it "should convert '---+ Title' to <h1>Title</h1>" do
      @params["content"] = "---+ Title\r\ncontent"
      html = "<h1>Title</h1>content"
      preview_response(@params).should == html
    end
    
    it "should convert '---++ Title' to <h2>Title</h2>" do
      @params["content"] = "---++ Title\r\ncontent"
      html = "<h2>Title</h2>content"
      preview_response(@params).should == html
    end
    
    it "should convert '---+++ Title' to <h3>Title</h3>" do
      @params["content"] = "---+++ Title\r\ncontent"
      html = "<h3>Title</h3>content"
      preview_response(@params).should == html
    end
    
    it "should convert *wow* to <b>wow</b>" do
      @params["content"] = "*wow*"
      html = "<b>wow</b>"
      preview_response(@params).should == html
    end
    
    it "should properly handle multiple bold tags" do
      @params["content"] = "*wow* and *cool*"
      html = "<b>wow</b> and <b>cool</b>"
      preview_response(@params).should == html
    end

    it "should convert _hello_ to <i>hello</i>" do
      @params["content"] = "_hello_"
      html = "<i>hello</i>"
      preview_response(@params).should == html
    end

    it "should properly handle multiple italics tags" do
      @params["content"] = "_wow_ and _cool_"
      html = "<i>wow</i> and <i>cool</i>"
      preview_response(@params).should == html
    end
    
    it "should convert & to &amp;" do
      @params["content"] = "bob&lucy"
      html = "bob&amp;lucy"
      preview_response(@params).should == html
    end
    
    it "should convert < to &lt;" do
      @params["content"] = "x<1;y<2;"
      html = "x&lt;1;y&lt;2;"
      preview_response(@params).should == html
    end
    
    it "should convert > to &gt;" do
      @params["content"] = "x>1;y>2;"
      html = "x&gt;1;y&gt;2;"
      preview_response(@params).should == html
    end
      
    it "should properly translate a full content entry" do
      @params["content"] = "---+ Title\r\n---++ Subtitle\r\n---+++ *Header*\r\n\r\nPara *1*\r\n\r\nPara _2_ & _3_\r\n\r\nx<1 & y >2 then cool.\r\n"
      html = SAMPLE_CONTENT;
      preview_response(@params).should == html
    end
      
  end
  
  describe "response" do
    before(:each) do
      @params = { "topic" => "abc", "content" => "Its easy as 123. Baby you and me.", "action" => "preview" }
    end

    it "should show edit in page header" do
      response_post("#page", @params).should == "PREVIEW"
    end
    
    it "should show topic in title" do
      response_post("h2.page_title", @params).should == "abc"
    end
    
    it "should retrieve an existing topic with view" do
      response_post("div.content", @params).should == "Its easy as 123. Baby you and me."
    end
    
  end
  
  describe "form" do
    before(:each) do
      @params = { "topic" => "abc", "content" => "Its easy as 123.\nBaby you and me.\n", "action" => "preview" }
    end
    
    it "should contain an input tag to create action" do
      response_post_attribute("#action_tag", "value", @params).should == "create"
    end
    
    it "should contain a topic tag with topic value" do
      response_post_attribute("#topic_tag", "value", @params).should == "abc"
    end

    it "should contain a content tag with content value" do
      response_post_attribute("#content_tag", "value", @params).should == "Its easy as 123.\nBaby you and me.\n"
    end

    it "should contain a submit button" do
      response_post_attribute("#main form .submit input", "type", @params).should == "submit"
    end

    it "should contain a submit button with value Save" do
      response_post_attribute("#main form .submit input", "value", @params).should == "Save"
    end

    it "should have option to go back" do
      response_post_attribute("#main form .back input", "value", @params).should == "<< Cancel and go back"
    end
    
    it "should preserve content with back"
    
  end
  
end