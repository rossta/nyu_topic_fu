require 'net/http'
require 'uri'
require 'hpricot'

module Response
  BASE_URL = "http://localhost/cgi-bin/"
  PATH = "topic_fu"
  
  def doc(method = :get, params = {})
    path = PATH
    path = params.delete("path") if params["path"]
    if method == :post
      Hpricot(post_form("#{BASE_URL}#{path}", params))
    else
      Hpricot(get("#{BASE_URL}#{path}", params))
    end
  end
  
  def response_get(element, params = {})
    (doc(:get, merge_test(params))/element).inner_html
  end
  
  def response(element)
    (doc(:post, merge_test({}))/element).inner_html
  end
  
  def response_attribute(element, attribute)
    (doc(:post, merge_test({}))/element).first[attribute.to_sym]
  end
  
  def response_post(element, params = {})
    (doc(:post, merge_test(params))/element).inner_html
  end

  def response_post_attribute(element, attribute, params = {})
    (doc(:post, merge_test(params))/element).first[attribute.to_sym]
  end
  
  def preview_response(params, locator = "div.content")
    response_post(locator, params).chomp
  end
  
  def search_response(element, params = {})
    response_get(element, params.merge(:path => 'topic_search'))
  end

  def preview_response_attribute(params, locator, attribute)
    response_post_attribute(locator, attribute, params).chomp
  end

protected
  def merge_test(params)
    params.merge("test_link"=>STUDENT_ID, "test_dir" => "test_topic")
  end

  def parse(url)
    URI.parse(url)
  end
  
  def get(url, params = {})
    unless params.empty?
      url += "?"
      params.each { |k,v| url += "#{k}=#{CGI::escape(v)}&" }
    end
    Net::HTTP.get(parse(url))
  end
  
  def post_form(url, params = {})
    Net::HTTP.post_form(parse(url), params).body
  end
  
end
