require './models/conversion'
require './models/conversion_detail'

get '/' do
  "Shopee!"
end

post '/new_conversion' do
  from = params[:from]
  to = params[:to]
  @conversion = Conversion.create(from: from, to: to)
  {
    "status": "Success"
  }.to_json
end

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

post '/delete_rate' do
  from = params[:from]
  to = params[:to]
  @conversion = Conversion.find_by(from: from, to: to)
  @conversion.destroy
  {
    "status": "Success"
  }.to_json
end

def count_avg(rates)
  sum = 0
  rates.each do |rate|
    sum += rate.rate
  end
  avg = (sum / 7).round(3)
end
