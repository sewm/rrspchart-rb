##
# Chart.rb - Create a stacked chart of RRSP values
# Sam MacCutchan
# 2013-02-22
# 
 
require 'sinatra'
require 'haml'
require 'CSV'

data = CSV.read("./data.csv")

first_date = Time.now
last_date = Time.mktime(1900,1,1)
prices = Array.new(0)
units = Array.new(0)
values = Array.new(0)

data.each do |d|
  current_date = d[0].split("-")
  current_date = Time.mktime(current_date[0],current_date[1],current_date[2])
  first_date = current_date if current_date < first_date
  last_date = current_date if current_date > last_date
  
  prices.push(d[1])
  units.push(d[2])
  values.push(d[3])
end

get '/' do
  @first_date = first_date
  @last_date = last_date
  @max_price = prices.max
  @max_units = units.max
  @max_value = values.max
  
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