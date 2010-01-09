require File.join(File.dirname(__FILE__), '..', 'test_helper')

class HCardTest < Test::Unit::TestCase
  setup do
    @html = get_fixture('hcard/commercenet.html')
    @node = Nokogiri::HTML.parse(@html).css(HMachine::Microformat::HCard::ROOT_SELECTOR)[0]
    @hcard = HMachine::Microformat::HCard.new(@node)
  end
  
  describe 'Constants' do
      test "hCard's root class" do
        assert @hcard.class::ROOT_CLASS == 'vcard', "Root class is #{@hcard.class::ROOT_CLASS}"
      end
  
      test "hCard's root selector" do
        assert @hcard.class::ROOT_SELECTOR == '.vcard', "Root selector is #{@hcard.class::ROOT_SELECTOR}"
      end
    end
    
    describe "Inheritance" do
      test "hCard's wiki url" do
        assert @hcard.class.wiki_url == "http://microformats.org/wiki/hcard"
      end
      
      test "hCard's validation" do
        assert @hcard.class.validate(@node)
      end
    end
    
    test "rejects invalid nodes" do
      assert_raise RuntimeError do 
        HMachine::Microformat::HCard.new(Nokogiri::HTML.parse(@html)) 
      end
    end
    
    test 'retains original node' do
      assert @hcard.node == @node
    end
  
  
  

end