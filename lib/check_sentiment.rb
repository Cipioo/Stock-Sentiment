# check_sentiment takes a web link and returns the sentiment of the link.
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require_relative 'word_processing'

class Check_Sentiment
  def initialize(web)
    @web = web
  end
  private
  #turns a file into an array
    def filetoarray (filename)
      thearray = []
      File.open(filename, 'r') do |token|
        while line = token.gets
          thearray.push(line.delete("\n"))
        end
      end
      return thearray
    end

  public
  
    def getsentiment
      #Gets the link and calls process_page on the link
      process = Word_Processing.new(@web)
      process.process_page

      #declares the positive and negative words in arrays to compare against.
      negative = filetoarray("Negative.txt")
      positive = filetoarray("Positive.txt")


      #initialize variables to 0
      good = 0
      bad = 0
      countthreads = 0

      #This loops over all the links on the page and checks the sentiment of each page
      process.get_google_links.each do |link|
        #Checks if each page is positive or negative
            process = Word_Processing.new(link)
            process.process_page
            temp =  process.page_sentiment(positive, negative)
            #Sets the sentiment for this page as positive/negative.
            if temp < 0
              bad +=1
            elsif temp > 0
              good +=1
            end
          countthreads+=1
      end

      #returns number of positive documents / negative documents
      if(good == 0 and bad == 0)
        return -1 #Only Neutral stock analysis
      elsif bad == 0
        return 1
      elsif good == 0
        return 0
      else
        return good.to_f/bad
      end
    end
end