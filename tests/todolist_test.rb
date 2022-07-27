require "simplecov"
SimpleCov.start

require 'minitest/autorun'
require_relative '../todolist'

require "minitest/reporters"
Minitest::Reporters.use!

class TodoListTest < MiniTest::Test
  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  def test_to_a
    assert_equal(@todos, @list.to_a)
  end

  def test_size
    assert_equal(3, @list.size)
  end

  def test_first
    assert_equal(@todo1, @list.first)
  end

  def test_last
    assert_equal(@todo3, @list.last)
  end

  def test_shift
    list = @list
    assert_equal(@todo1, @list.shift)
    assert_same(list, @list)
    assert_equal([@todo2, @todo3], @list.to_a)
  end

  def test_pop
    list = @list
    assert_equal(@todo3, @list.pop)
    assert_same(list, @list)
    assert_equal([@todo1, @todo2], @list.to_a)
  end

  def test_done_question
    assert_equal(false, @list.done?)
  end

  def test_add_raise_error
    assert_raises(TypeError) { @list.add(3) }
    assert_raises(TypeError) { @list.add('a') }
  end

  def test_shovel
    new_todo = Todo.new('test')
    @list << new_todo
    @todos << new_todo
    assert_equal(@todos , @list.to_a)
  end

  def test_add
    new_todo = Todo.new('test')
    @list.add(new_todo)
    @todos.push(new_todo)
    assert_equal(@todos , @list.to_a)
  end

  def test_item_at_raise_error
    assert_raises(IndexError) { @list.item_at(@list.size) }
    assert_raises(IndexError) { @list.item_at(-@list.size - 1) }
  end

  def test_item_at
    assert_equal(@todo1, @list.item_at(0))
    assert_equal(@list.item_at(0), @list.item_at(-@list.size))
    assert_equal(@todo3, @list.item_at(-1))
    assert_equal(@list.item_at(-1), @list.item_at(@list.size - 1))
  end

  def test_mark_done_at_raise_error
    assert_raises(IndexError) { @list.mark_done_at(@list.size) }
    assert_raises(IndexError) { @list.mark_done_at(-@list.size - 1) }
  end

  def test_mark_done_at
    @list.mark_done_at(0)
    assert_equal(true, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end

  def test_mark_undone_at_raise_error
    assert_raises(IndexError) { @list.mark_undone_at(@list.size) }
    assert_raises(IndexError) { @list.mark_undone_at(-@list.size - 1) }

  end

  def test_mark_undone_at
    @todo1.done!
    @todo2.done!
    @todo3.done!
    @list.mark_undone_at(1)
    assert_equal(true, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(true, @todo3.done?)
  end

  def test_done_bang
    @list.done!
    assert_equal(true, @todo1.done?)
    assert_equal(true, @todo2.done?)
    assert_equal(true, @todo3.done?)
    assert_equal(true, @list.done?)
  end

  def test_remove_at_raise_error
    assert_raises(IndexError) { @list.remove_at(@list.size) }
    assert_raises(IndexError) { @list.remove_at(-@list.size - 1) }
  end

  def test_remove_at
    @list.remove_at(2)
    assert_equal([@todo1, @todo2], @list.to_a)
  end

  def test_to_s
    output = <<~OUTPUT.chomp#.gsub(/^\s+/, "") if `~` was replaced by `-`
      ---- Today's Todos ----
      [ ] Buy milk
      [ ] Clean room
      [ ] Go to gym
    OUTPUT

    assert_equal(output, @list.to_s)
  end

  def test_to_s_2
    output = <<~OUTPUT.chomp
      ---- Today's Todos ----
      [#{Todo::DONE_MARKER}] Buy milk
      [ ] Clean room
      [ ] Go to gym
    OUTPUT

    @list.mark_done_at(0)
    assert_equal(output, @list.to_s)
  end

  def test_to_s_3
    output = <<~OUTPUT.chomp
      ---- Today's Todos ----
      [#{Todo::DONE_MARKER}] Buy milk
      [#{Todo::DONE_MARKER}] Clean room
      [#{Todo::DONE_MARKER}] Go to gym
    OUTPUT

    @list.done!
    assert_equal(output, @list.to_s)
  end

  def test_each
    index = 0
    @list.each do |todo|
      assert_equal(@todos[index], todo)
      index += 1
    end
  end

  def test_each_returns_original_list
    assert_equal(@list, @list.each {})
  end

  def test_select
    expected_return = TodoList.new(@list.title)

    select_return = @list.select {|todo| todo.done?}
    assert_equal(expected_return.to_s, select_return.to_s)

    @todo2.done!
    expected_return << @todo2
    select_return = @list.select {|todo| todo.done?}
    assert_equal(expected_return.to_s, select_return.to_s)
  end

  def test_find_by_title
    assert_equal(nil, @list.find_by_title("Not in the todo list"))

    returned_todo = @list.find_by_title("Go to gym")
    assert_equal(@todo3, returned_todo)
  end

  def test_all_done
    expected_return = TodoList.new("Today's Todos")
    assert_equal(expected_return.to_s, @list.all_done.to_s)

    @todo3.done!
    expected_return << @todo3
    assert_equal(expected_return.to_s, @list.all_done.to_s)
  end

  def test_all_not_done
    assert_equal(@list.to_s, @list.all_not_done.to_s)
    @todo1.done!
    expected_return = TodoList.new("Today's Todos")
    expected_return << @todo2 << @todo3
    assert_equal(expected_return.to_s, @list.all_not_done.to_s)
  end

  def test_mark_done
    @list.mark_done("clean Room")
    assert_equal(false, @todo2.done?)
    @list.mark_done("Clean room")
    assert_equal(true, @todo2.done?)
  end

  def test_mark_all_done
    @list.mark_all_done
    @todos.each {|todo| assert_equal(true, todo.done?)}
  end

  def test_mark_all_undone
    @todos.each {|todo| todo.done!}
    @list.mark_all_undone
    @todos.each {|todo| assert_equal(false, todo.done?)}
  end

  def test_new_todolist_empty
    assert_equal(0, TodoList.new('empty_list').size)
  end
end

class TodoTest < MiniTest::Test
  def setup
    @todo = Todo.new("Buy milk")
  end

  def test_todo_copy
    copy_todo = @todo.copy
    refute_same(@todo, copy_todo)
  end
end
