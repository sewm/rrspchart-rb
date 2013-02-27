##
# Chart.rb - Create a stacked chart of RRSP values
# Sam MacCutchan
# 2013-02-22
# 
 
require 'sinatra'
require 'haml'
require 'CSV'

data = CSV.read("./data.csv")

first_date = Time.now               # Set the first date to today, likely to be newer than the first date in the data. 
last_date = Time.mktime(1900,1,1)   # Set the last date so early it is not likely to be in the data
prices = Array.new(0)
units = Array.new(0)
values = Array.new(0)

data.each do |d|
  # Read in the date from each data record and convert it into an actual date instead of
  # a string.
  current_date = d[0].split("-")
  current_date = Time.mktime(current_date[0],current_date[1],current_date[2])
  first_date = current_date if current_date < first_date
  last_date = current_date if current_date > last_date
  
  # Pop the values of price, unit and value onto the arrays that store them.
  prices.push(d[1])
  units.push(d[2])
  values.push(d[3])
end

get '/' do
  @first_date = first_date
  @last_date = last_date
  
  @max_price = prices.max
  @min_price = prices.min
  
  @max_units = units.max
  @min_units = units.min
  
  @max_value = values.max
  @min_value = values.min
  
  
  # For populating the form with default values for units.
  @current_units = units[units.length - 1]
  
  # And for the date field. We are almost always entering the previous day's date,
  # or the previous Friday if the current date is Saturday, Sunday or Monday.
  # So let's populate the form with that day to save time.
  @current_time = Time.now
  
  if @current_time.monday?
    @current_time = @current_time - (1440 * 60 * 3) # Subtract three days
  elsif @current_time.sunday?
    @current_time = @current_time - (1440 * 60 * 2) # Subtract two days
  else
    @current_time = @current_time - (1440 * 60) # Subtract one day
  end
  
  @prices = prices
  @units = units
  @values = values
  
  haml :index, :format => :html5
end

post '/daily_update' do
  @date = params[:date]
  @price = params[:price]
  @units = params[:units]
  @value = (@price.to_f * @units.to_f).round(2)
  
  CSV.open("./data.csv", "a") do |csv|
    csv << [@date, @price, @units, @value]
  end
  
  haml :daily_update, :format => :html5
end 