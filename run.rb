#!/usr/bin/env ruby
require "date"

RANGE = 10 # years

def rate_of(a, b)
  (a * 100.0 / b).round(2)
end

# a*(1+x)**years = b
def roi_of(a, b, years)
  (((b.to_f * 1.0 / a.to_f)**(1.0/years) - 1) * 100).round(2)
end

def avg_of(ar)
  return 0 if ar.count.zero?
  (ar.reduce(:+)/ar.count).round(2)
end

data = File.read(ARGV[0]).force_encoding(Encoding::GB18030).split
data.shift
data = data.map { |l| l.split(",") }

map = {}
data.each do |row|
  date = Date.parse(row[0])
  close_price = row[3]

  map[date] = close_price
end

keys = map.keys
max_date = keys.first
min_date = keys.last

rois = []
cur = min_date
loop do
  tar = cur + RANGE * 365
  break if tar > max_date

  cur_value = map[cur]
  tar_value = map[tar]
  if cur_value && tar_value
    roi = roi_of(cur_value, tar_value, RANGE)
    rois << roi
  end

  cur += 1
end

avg = avg_of(rois)
rois = rois.sort
min = rois.first || 0
max = rois.last || 0
p50 = rois[rois.count/2]

puts "== #{RANGE} years ROI"
puts "avg: #{avg}%, p50: #{p50}%, min: #{min}%, max: #{max}%"

[0, 2, 4, 6, 8, 10].each do |i|
  r = rate_of(rois.find_index { |n| n >= i }, rois.count)
  puts "Over #{i}%: #{(100 - r).round(2)}%"
end
