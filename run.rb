#!/usr/bin/env ruby
require "date"

RANGE = 10 # years

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
  puts cur
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
rois = rois.sort
avg = avg_of(rois)
min = rois.first || 0
max = rois.last || 0

puts "#{RANGE} years ROI:"
puts "avg: #{avg}, min: #{min}, max: #{max}"
