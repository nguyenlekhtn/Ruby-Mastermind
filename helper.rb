class Hash
  def intersection(other)
    each_with_object({}) do |(k, v), a|
      a[k] = [v, other[k]].min if other.key? k
    end
  end
end

module Enumerable
  def count_by(&block)
    list = group_by(&block).map { |key, items| [key, items.count] }.sort_by(&:last)
    list.to_h
  end
end

def count_matched_pos(a_arr, b_arr)
  a_arr.select.with_index { |_value, index| a_arr[index] == b_arr[index] }.length
end

def count_matched_value(a_arr, b_arr)
  counted_a = a_arr.count_by { |v| v }
  counted_b = b_arr.count_by { |v| v }
  counted_a.intersection(counted_b).values.sum
end

def count_matched_value_only(a_arr, b_arr)
  count_matched_value(a_arr, b_arr) - count_matched_pos(a_arr, b_arr)
end

# create array of array from [start, ...] to [end, ...]
def possible_choices(min, max, size)
  arr = []
  alpha = Array.new(size) { min }.join.to_i
  omega = Array.new(size) { max }.join.to_i
  alpha.upto(omega) do |i|
    arr << i.to_s
  end
  arr.map(&:chars)
end

def compare_with(a_rr, b_arr)
  count_match_exactly = count_matched_pos(a_rr, b_arr)
  count_wrong_pos = count_matched_value_only(a_rr, b_arr)
  { count_match_exactly: count_match_exactly, count_wrong_pos: count_wrong_pos }
end

def match_compare?(a_arr, b_arr, comparasion)
  compare_with(a_arr, b_arr) => {count_match_exactly:, count_wrong_pos:}
  count_match_exactly == comparasion[0] && count_wrong_pos == comparasion[1]
end
