#!/usr/bin/env ruby
require "date"

# %
def rate_of(a, b)
  (a.to_i * 100.0 / b).round(2)
end

# %
# a*(1+x)**years = b
def roi_of(a, b, years)
  (((b.to_f * 1.0 / a.to_f)**(1.0/years) - 1) * 100).round(2)
end

def avg_of(ar)
  return 0 if ar.count.zero?
  (ar.reduce(:+)/ar.count).round(2)
end

def load_data(file)
  data = File.read(file).force_encoding(Encoding::GB18030).split
  data.shift
  data = data.map { |l| l.split(",") }

  map = data.each_with_object({}) do |row, h|
    date = Date.parse(row[0])
    close_price = row[3]

    h[date] = close_price
  end

  keys = map.keys
  max_date = keys.first
  min_date = keys.last
  years = ((max_date - min_date).to_i / 365.0).round(1)
  rate = roi_of(map[min_date], map[max_date], years)
  puts "Historical ROI:\t#{rate}%\tDate range:\t#{min_date}\t#{max_date}"
  puts

  map
end

def calculate_rois(map, range)
  keys = map.keys
  max_date = keys.first
  min_date = keys.last

  rois = []
  cur = min_date
  loop do
    tar = cur + range * 365
    break if tar > max_date
    cur_value = map[cur]
    tar_value = map[tar]
    if cur_value && tar_value
      roi = roi_of(cur_value, tar_value, range)
      rois << roi
    end

    cur += 1
  end

  rois
end

# ROI = Struct.new(:count, :avg, :p50, :min, :max, :over_0, :over_2, :over_4, :over_6, :over_8, :over_10)
def analyze(rois)
  if rois.empty?
    return [0] + [nil]*10
  end

  rois = rois.sort

  ret = []
  ret << rois.count
  ret << avg_of(rois) # avg
  ret << rois[rois.count/2] # p50
  ret << rois.first || 0 # min
  ret << rois.last || 0 # max

  [0, 2, 4, 6, 8, 10].each do |i|
    r = rate_of(rois.find_index { |n| n >= i }, rois.count)
    ret << (100-r).round(2)
  end
  ret
end

# date => close_price
map = load_data(ARGV[0])

# range => [..]
range_roi = {}
range_roi[:N] = [:data_point, :avg, :p50, :min, :max, :over_0, :over_2, :over_4, :over_6, :over_8, :over_10]
(10..15).step(1).each do |range|
  d = analyze(calculate_rois(map, range))
  range_roi[range] = [d.first] + d[1..-1].map { |i| i.nil? ? i : (i / 100.0).round(4) } # remove %
end

view = [range_roi.keys] + range_roi.values.transpose
view.each do |row|
  puts row.join("\t")
end
