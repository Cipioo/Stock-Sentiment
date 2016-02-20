# The Word_Processing class processes the words on a single web page.

class Word_Processing
  def initialize (web)
    @links = []
    @thewords = Hash.new(0)
    @sentimentDict = Hash.new(0)
    @WEBADDRESS = web
  end
  private
    def make_absolute(href, root)
      return unless href
      URI.parse(root).merge(URI.parse(href)).to_s rescue nil
    end

    def process_links(doc)
      return doc.css("a")
    end

    def frequencies(words)
      Hash[
        words.group_by(&:downcase).map{ |word,instances|
          [word,instances.length]
        }
      ]

    end

    
    def process_words(doc)

      doc.css('script').remove
      begin
        text = doc.at('body').inner_text.scan(/[a-z]+/i)
      rescue 
      else
        temptext = text
        temphash=Hash.new(0)
        temptext.each do |tempword|
          if (!temphash.has_key?(tempword))
            temphash[tempword] = 1
          end
        end
        return frequencies(text)
      end
    end
public
  def process_page
    #puts "Processing page #{@WEBADDRESS}\n"
    begin
      #Opens The WebbAdress
      doc = Nokogiri(open(@WEBADDRESS,:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    rescue => e
      #puts "Error: #{e}"
    else
      links = process_links(doc).map { |link| make_absolute(link['href'], @WEBADDRESS)}.compact
        words = process_words(doc)
      links.each do |thelink|
        if !thelink.include?("@")
          @links.push(thelink) unless @links.include?(thelink)
        end
      end
      theurl = @WEBADDRESS
      theurl=theurl.gsub(":", ".")
      theurl=theurl.gsub("/", ".")
      theurl=theurl.gsub("?", ".")
      theurl=theurl.gsub("*", ".")
      theurl=theurl.gsub("\\", ".")
      theurl=theurl.gsub("<", ".")
      theurl=theurl.gsub(">", ".")
      theurl=theurl.gsub("|", ".")
      theurl=theurl.gsub("\"", ".")
      
      @thewords=@thewords.merge(words){|key, oldval, newval| newval + oldval} rescue nil
    end
    return @thewords
  end
  
  #This gets an array of all the links on the page
  def get_google_links
    linkarray = []
    @links = @links.each do |link|
      if (link.scan("http://").length == 2)
        linkarray.push(link)
      end
    end
    return linkarray
  end
  
  #Takes the list of positive and negative words and compares each word in the Web page. Returns a number that is positive if more positive words, and negative if more negative words.
  def page_sentiment (positive, negative)
    totalwords = 0
    count = 0.0
    sentimentwords = 0.0
    if(@thewords)
      #This is the main loop, if each word is positive or negative in the document adjust variables accordingly.
      @thewords.each do |word|
        totalwords+= 1
        if positive.map(&:downcase).include? word[0].downcase
         # puts word[0]
          count +=word[1]
          sentimentwords +=word[1]
        elsif negative.map(&:downcase).include? word[0].downcase
         # puts word[0]
          count -=word[1]
          sentimentwords +=word[1]
        end
      end
    end
    ratio = count/sentimentwords
    if (ratio > 0.10)
      count = 1
    elsif (ratio < -0.10)
      count = -1
    else
      count = 0
    end
    return count
  end
end
