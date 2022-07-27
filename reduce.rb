=begin
P:
input: array, (initial_value) block
output: block return value

DA:
if the array is 1 element, return that element
if initial_value is initialized
  set accumulator to `initial_value`
  set index to 1st element
else
  set accumulator to first element
  set index to 2nd element

until index > length of `array`
  yield to the block passing `accumulator`, assign the return value to `accumulator`
  increment 1 to index

return accumulator
=end

def reduce(array, initial_value = :not_initialized)
  return array[0] if array.length < 2

  acc = nil
  index = nil

  if initial_value == :not_initialized
    acc = array[0]
    index = 1
  else
    acc = initial_value
    index = 0
  end

  while index < array.length
    acc = yield(acc, array[index])
    index += 1
  end

  acc
end

#using `omitted` flag
def reduce(array, accum = omitted = true)
  accum = omitted ? array[0] : accum
  counter = omitted ? 1 : 0

  while counter < array.size
      accum = yield(accum, array[counter])
      counter += 1
  end

  accum
end

array = [1, 2, 3, 4, 5]


p reduce(array, 1) { |acc, num| acc + num }                    # => 15
p reduce(array, 10) { |acc, num| acc + num }                # => 25
# p reduce(array) { |acc, num| acc + num if num.odd? }        # => NoMethodError: undefined method `+' for nil:NilClass
p reduce(['a', 'b', 'c']) { |acc, value| acc += value }     # => 'abc'
p reduce([[1, 2], ['a', 'b']]) { |acc, value| acc + value } # => [1, 2, 'a', 'b']