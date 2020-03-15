# frozen_string_literal: true

module Tablesmith
  # This adjustment to `DelegateClass(Array)` is necessary to allow calling puts
  # on a `Tablesmith::Table` and still get the table output, rather than the
  # default puts output of the underlying `Array`.
  #
  # Explaining why requires breaking some things down.
  #
  # The implementation of `Kernel::puts` has special code for an `Array`. The
  # code inside `rb_io_puts` (in io.c) first checks to see if the object passed
  # to it is a `String`. If not, it then calls `io_puts_ary`, which in turn
  # calls `rb_check_array_type`. If `rb_check_array_type` confirms the passed
  # object is an `Array`, then `io_puts_ary` loops over the elements of the
  # `Array` and passes it to `rb_io_puts`. If the `Array` check fails in the
  # original `rb_io_puts`, `rb_obj_as_string` is used.
  #
  # Early versions of `Tablesmith::Table` subclassed `Array`, but even after
  # changing `Tablesmith::Table` to use any of the `Delegator` options, the code
  # in `rb_check_array_type` still detected `Tablesmith::Table` as an `Array`.
  # How does it do this?
  #
  # `rb_check_array_type` calls:
  #
  #   `return rb_check_convert_type_with_id(ary, T_ARRAY, "Array", idTo_ary);`
  #
  # If a straight up type check fails, then it attempts to convert the object to
  # an `Array` via the `to_ary` method.
  #
  # And wha-lah. We simply need to undefine the `to_ary` method added to
  # `Tablesmith::Table` by `DelegateClass(Array)` and `rb_io_puts` will no
  # longer output `Table` as an `Array` and will use its `to_s` method, the same
  # as `print`.
  def self.delegated_array_class
    DelegateClass(Array).tap do |klass|
      klass.undef_method(:to_ary)
    end
  end
end
