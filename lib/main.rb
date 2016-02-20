# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'get_input'
puts "Processing..."
stocklist="thestock.txt"
input=Get_Input.new(stocklist)
input.conversion
puts "Complete"