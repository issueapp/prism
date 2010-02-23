require 'open-uri'
require 'nokogiri'

module HMachine
  VERSION = "0.0.1"
  PRODID = "-//markwunsch.com//hMachine #{VERSION}//EN"

  # Convenience method for HMachine::Microformat.find method
  def self.find(document, format=nil)
    HMachine::Microformat.find(document, format)
  end
  
  # Get a string of html or a url and convert it to a Nokogiri Document
  def self.get(html)
    return html if html.is_a?(Nokogiri::XML::Node)
    begin
      url = URI.parse(html)
      doc = url.is_a?(URI::HTTP) ? get_url(url.normalize.to_s) : get_document(html)
    rescue URI::InvalidURIError
      doc = get_document(html)
    end
    doc
  end
  
  # Open a URL and convert the contents to a Nokogiri Document
  def self.get_url(url)
    uri = URI.parse(url)
    doc = ''
    uri.open do |web|
      web.each_line {|line| doc += line }
    end
    get_document(doc, url)
  end
  
  # Convert HTML to a Nokogiri Document
  def self.get_document(html, url=nil)
    html.is_a?(Nokogiri::XML::Node) ? html : Nokogiri::HTML.parse(html, url)
  end
  
  def self.normalize(name)
    name.to_s.strip.downcase.intern
  end
  
  # Map a key to an element or design pattern
  def self.map(key)
    case normalize(key)
      when :value_class, :valueclass, :abbr, :uri, :url, :typevalue
        HMachine::Pattern.map(key)
      when :hcard, :geo, :rellicense, :reltag, :votelinks, :xfn, :xmdp, :xoxo, :adr
        HMachine::Microformat.map(key)
      when :base
        HMachine::POSH::Base
      else
        raise "#{key} is not a recognized parser."
    end
  end
  
  # Get/Set a function that defines how to find an element in a node.
  # The Search function should return a Nokogiri::XML::NodeSet.
  # eg. <tt>search {|node| node.css(element) }  
  def search(&block)
    @search = block if block_given?
    @search || lambda {|node| node }
  end
  
  # Search for the element in a document 
  def find_in(document)
    search.call(document)
  end
  
  # Is the element found in node?
  def found_in?(node)
    find_in(node).eql?(node) || !find_in(node).empty?
  end
  
  # Get/Set a function that tests to make sure a given node is
  # the element we want. Should return truthy.
  # Default just tests to see if the node passed is a child of its parent node.
  def validate(&block)
    @validate = block if block_given?
    @validate || lambda { |node| find_in(node.parent).children.include?(node) }
  end
  
  # Is this a valid node?
  def valid?(node)
    validate.call(node)
  end
  
  # Define the pattern used to extract contents from node
  # Can be a symbols that match to an Element parser, or a block
  def extract(pattern = nil, &block)
    if block_given?
      @extract = block 
    else
      @extract = HMachine.map(pattern).extract if pattern
    end
    @extract || lambda{|node| node.content.strip }
  end
  
  # Extract the content from the node
  def extract_from(node)
    extract.call(node)
  end
  
  # Parse the document, finding every instance of the desired element, and extract their contents
  def parse(document)
    if found_in?(document)
      contents = find_in(document).collect do |element|
        extract_from(element)
      end
      (contents.length == 1) ? contents.first : contents
    end
  end
  
  # Parse the document, extracting the content for the first instance of the element
  def parse_first(document)
    if found_in?(document)
      elements = find_in(document)
      first_element = elements.respond_to?(:first) ? elements.first : elements 
      extract_from(first_element)
    end
  end 
  
end

require 'hmachine/pattern'
require 'hmachine/posh'
require 'hmachine/microformat'