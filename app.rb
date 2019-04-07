require './models/conversion'
require './models/conversion_detail'

get '/' do
  "Shopee!"
end

# User wants to add an exchange rate to the list
### This will add new exchange rate to the list
### Params:
###  - from (String): Currency to convert from
###  - to (String): Currency to convert to
post '/new_conversion' do
  from = params[:from]
  to = params[:to]
  @conversion = Conversion.create(from: from, to: to)
  {
    "status": "Success"
  }.to_json
end

# User wants to input daily exchange rate data
### This will add new rate to the exchange
### Params:
###  - from (String): Currency to convert from
###  - to (String): Currency to convert to
###  - date (String): Selected date
###  - rate (float): Rate of the conversion
post '/new_rate' do
  from = params[:from]
  to = params[:to]
  @conversion = Conversion.find_by(from: from, to: to)
  @conversion = Conversion.create(from: from, to: to) if @conversion.nil?
  @detail = ConversionDetail.new
  @detail.date = params[:date]
  @detail.rate = params[:rate]
  @conversion.conversion_details << @detail
  @detail.save
  {
    "status": "Success"
  }.to_json
end

# User has a list of exchange rates to be tracked
### This will give the summary of currencies on the selected date
### Params:
###  - date (String): Selected date
post '/exchange_rates' do
  date = params[:date].to_date
  payload = []
  conversions = Conversion.all
  conversions.each do |conversion|
    rates = ConversionDetail.where(conversion: conversion, date: (date-6.days).to_s..date.to_s)
    if rates.length < 7
      rate = "insufficient data"
      avg = ""
    else
      rate = rates[0].rate
      avg = count_avg(rates)

    end
    result = {
      "from": conversion.from,
      "to": conversion.to,
      "rate": rate,
      "avg": avg  
    }
    payload.push(result)
  end
  payload.to_json
end

# User wants to see the exchange rate trend from the most recent 7 data points
### This will give the rate trend from the last 7 days, along with the average and variance
### Params:
###  - from (String): Currency to convert from
###  - to (String): Currency to convert to
post '/daily_rate' do
  date = Date.today
  from = params[:from]
  to = params[:to]
  avg, max, min = 0, 0, 0
  list = {}
  conversion = Conversion.find_by(from: from, to: to)
  rates = ConversionDetail.where(conversion: conversion, date: (date-6.days).to_s..date.to_s)
  rates.each do |rate|
    price_rate = rate.rate
    min = price_rate if min == 0
    list[rate.date] = price_rate
    if price_rate > max
      max = price_rate
    elsif price_rate < min
      min = price_rate
    end
  end
  {
    "avg": count_avg(rates),
    "variance": (max - min).round(3),
    "rates_list": list 
  }.to_json
end

# User wants to remove an exchange rate from the list
### Used to remove an exchange rate
### Params:
###  - from (String): Currency to convert from
###  - to (String): Currency to convert to
post '/delete_rate' do
  from = params[:from]
  to = params[:to]
  @conversion = Conversion.find_by(from: from, to: to)
  @conversion.destroy
  {
    "status": "Success"
  }.to_json
end

# Helper method to count the average rates
def count_avg(rates)
  sum = 0
  rates.each do |rate|
    sum += rate.rate
  end
  avg = (sum / 7).round(3)
end
