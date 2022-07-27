class Todo
  DONE_MARKER = 'X'
  UNDONE_MARKER = ' '

  attr_accessor :title, :description, :done

  def initialize(title, description='')
    @title = title
    @description = description
    @done = false
  end

  def done!
    self.done = true
  end

  def done?
    done
  end

  def undone!
    self.done = false
  end

  def to_s
    "[#{done? ? DONE_MARKER : UNDONE_MARKER}] #{title}"
  end

  def ==(otherTodo)
    title == otherTodo.title &&
      description == otherTodo.description &&
      done == otherTodo.done
  end

  def copy
    todo_copy = Todo.new(title, description)
    todo_copy.done! if done?

    todo_copy
  end
end

class TodoList
  attr_accessor :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def add(item)
    raise TypeError.new("Can only add Todo objects") unless item.is_a?(Todo)

    @todos.push(item) #or push(item.copy)
    self
  end

  alias_method :<<, :add

  def size
    @todos.size
  end

  def first
    @todos.first
  end

  def last
    @todos.last
  end

  def to_a
    @todos.clone
  end

  def done?
    @todos.all? {|item| item.done?}
  end

  def item_at(index)
    @todos.fetch(index)
  end

  def mark_done_at(index)
    item_at(index).done!
  end

  def mark_undone_at(index)
    item_at(index).undone!
  end

  def done!
    @todos.each(&:done!)
    #LS
    # @todos.each_index do |idx|
    #   mark_done_at(idx)
    # end
  end

  def shift
    @todos.shift
  end

  def pop
    @todos.pop
  end

  def remove_at(index)
    item_at(index)
    @todos.delete_at(index)
    #LS
    # @todos.delete(item_at(idx))
  end


  def to_s
    text =  "---- #{title} ----\n"
    text << @todos.map(&:to_s).join("\n")
    text
  end

  def each
    index = 0
    while index < size
      yield(item_at(index))
      index += 1
    end

    # @todos #step 1 return value
    self

    #LS
    # @todos.each do |todo|
    #   yield(todo)
    # end
  end

  def select
    # selection = [] #step 1
    selection = TodoList.new("#{title}")
    each {|todo| selection << todo if yield(todo)}

    selection
  end

  def find_by_title(str)
    each {|todo| return todo if todo.title == str}
    nil
  end

  def all_done
    select {|todo| todo.done?}
  end

  def all_not_done
    select {|todo| !(todo.done?)}
  end

  def mark_done(str)
    # each { |todo| return todo.done! if str == todo.title }
    #LS
    find_by_title(str) && find_by_title(str).done!
  end

  def mark_all_done
    each {|todo| todo.done!}
  end

  def mark_all_undone
    each {|todo| todo.undone!}
  end
end


# given
todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")
list = TodoList.new("Today's Todos")

puts
puts "---- Adding to the list -----"
# add
p list.add(todo1)                 # adds todo1 to end of list, returns list
p list << (todo2)                 # adds todo2 to end of list, returns list
p list.add(todo3)                 # adds todo3 to end of list, returns list
# p list.add(1)                     # raises TypeError with message "Can only add Todo objects"
# <<
# same behavior as add

puts list.to_s
__END__
puts "TEST base methods"
puts "---- Interrogating the list -----"

# size
p list.size                       # returns 3

# first
p list.first                      # returns todo1, which is the first item in the list

# last
p list.last                       # returns todo3, which is the last item in the list

#to_a
p list.to_a                      # returns an array of all items in the list

#done?
p list.done?                     # returns true if all todos in the list are done, otherwise false

puts
puts "---- Retrieving an item in the list ----"

# item_at
# p list.item_at                    # raises ArgumentError
p list.item_at(1)                 # returns 2nd item in list (zero based index)
# p list.item_at(100)               # raises IndexError

puts
puts "---- Marking items in the list -----"

# mark_done_at
# p list.mark_done_at               # raises ArgumentError
p list.mark_done_at(1)            # marks the 2nd item as done
# p list.mark_done_at(100)          # raises IndexError
puts list
puts

# mark_undone_at
# p list.mark_undone_at             # raises ArgumentError
p list.mark_undone_at(1)          # marks the 2nd item as not done,
# p list.mark_undone_at(100)        # raises IndexError
puts list
puts
# done!
p list.done!                      # marks all items as done
puts list

puts
puts "---- Deleting from the list -----"

# shift
# p list.shift                      # removes and returns the first item in list

# pop
# p list.pop                        # removes and returns the last item in list


# remove_at
# p list.remove_at                  # raises ArgumentError
p list.remove_at(1)               # removes and returns the 2nd item
# p list.remove_at(100)             # raises IndexError

puts
puts "---- Outputting the list -----"

# to_s
puts list                           # returns string representation of the list

# ---- Today's Todos ----
# [ ] Buy milk
# [ ] Clean room
# [ ] Go to gym

# or, if any todos are done

# ---- Today's Todos ----
# [ ] Buy milk
# [X] Clean room
# [ ] Go to gym

puts
puts "TEST each method"
todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")

list = TodoList.new("Today's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

list.each do |todo|
  puts todo                   # calls Todo#to_s
end

puts
puts "TEST select method step 1"

todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")

list = TodoList.new("Today's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

todo1.done!

results = list.select { |todo| todo.done? }    # you need to implement this method

puts results.inspect

puts
puts "TEST TodoList methods"
# find_by_title 	takes a string as argument, and returns the first Todo object that matches the argument. Return nil if no todo is found.
# all_done 	returns new TodoList object containing only the done items
# all_not_done 	returns new TodoList object containing only the not done items
# mark_done 	takes a string as argument, and marks the first Todo object that matches the argument as done.
# mark_all_done 	mark every todo as done
# mark_all_undone 	mark every todo as not done

todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")

list = TodoList.new("Today's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

p list.find_by_title("Today's Todos") # => nil
p list.find_by_title("Buy milk") # => `todo1` object

todo1.done!
todo3.done!
p list.all_done
p list.all_not_done

list.mark_done("Clean room")
puts list
p list.all_done
p list.all_not_done

# list.mark_all_done
# puts list
# puts
# list.mark_all_undone
# puts list
