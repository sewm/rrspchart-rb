##
# Chart.rb - Create a stacked chart of RRSP values
# Sam MacCutchan
# 2013-02-22
# 
 
require 'sinatra'
require 'haml'
require 'CSV'

get '/' do
  haml :index, :format => :html5
end

post '/daily_update' do
  @date = params[:date]
  @price = params[:price]
  @units = params[:units]
  @value = (@price.to_f * @units.to_f).round(4)
  
  CSV.open("./data.csv", "a") do |csv|
    csv << [@date, @price, @units, @value]
  end
  
  haml :daily_update, :format => :html5
end 