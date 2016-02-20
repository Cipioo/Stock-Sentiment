# get_input class reads in a file and converts it into searchable links
# it then runs check_sentiment for every stock listed in the search file
require_relative 'check_sentiment'
require 'thread'

class Get_Input
  def initialize(filename)
    @thefile=filename
    @outfile = "output.txt"
    @beginstring = "http://www.google.com/search?q="
    @endstring = "&hl=en&tbm=nws"
    File.open(@outfile, 'w'){}
    
  end
  
  private
    def filetoarray (filename)
      thearray = []
      File.open(filename, 'r') do |token|
        while line = token.gets
          thearray.push(line.delete("\n"))
        end
      end
      return thearray
    end
    def writeout(ticker, sentiment)
      File.open(@outfile, 'a') do |f|
       f << "#{ticker} #{sentiment}\n"
      end
    end
    
    def getticker(link)
      link.slice! "http://www.google.com/search?q="
      link.slice! "&hl=en&tbm=nws"
      return link
    end
    
  public
    #Creates a thread for each link
    def calling(thelist)
      threads = []
      mutex = Mutex.new
      #for each link in the array create a Thread
      thelist.each do |link| 
        threads << Thread.new(link) { |mylink|
          theweb = Check_Sentiment.new(mylink)
          #For each link call getsentiment
          sentiment = theweb.getsentiment
          #This is here so that each thread does not overwrite each other while writing out the results to a file.
          mutex.synchronize do
            writeout(getticker(mylink), sentiment)
          end
        }
        
      end
      threads.each { |aThread|  aThread.join }
    end
    #Conversion Grabs the Text File and converts each ticker into an Array of links
    def conversion
      temparray = []
      thearray = filetoarray(@thefile)
      #This Loop Creates an array of links to search for each ticker
      thearray.each do |link|
        #beginning web address
        temp = @beginstring.dup
        #the Ticker
        temp << link
        #ending web address
        temp << @endstring.dup
        #stores it into an array of links
        temparray << temp
      end
      calling(temparray)
    end
end
