# NX/NSF Introspection Cheatsheet

This cheatsheet covers introspection commands found in the Next Scripting Framework (NSF) as demonstrated in the test file.

## `[current calledclass]`

Returns the class from which a method was called.

### Behavior

- Inside regular object methods: returns an empty string if not called from a class
- Inside class methods: returns an empty string if not called directly from a class
- Inside instance methods: returns the class name (e.g., `::C`) when called from an instance
- Inside filter methods: returns the class name with any formatting applied by the filter
- Inside mixin methods: returns the original class name in a mixin chain

### Examples

```tcl
# In a regular object method
Object create o {
  :public method foo {} {
    return [current calledclass]
  }
}
o foo  # Returns: ""

# In class methods and instance methods
Class create C {
  :public class method bar {} {
    return [current calledclass]
  }
  :public method foo {} {
    return [current calledclass]
  }
}
[C new] foo  # Returns: ::C
C bar        # Returns: ""

# With filters
C eval {
  :public method intercept {} {
    return @[current calledclass]@
  }
  :filter add intercept
}
[C new] foo  # Returns: @::C@

# With mixins
Class create M {
  :public method baz {} {
    return [list [current calledclass] [next]]
  }
}
C mixins add M
[C new] baz  # Returns: {::C ::C}
```

## `[current nextmethod]`

Returns the next method in the call chain.

### Behavior

- Returns the method handle of the next method in the call chain
- When used with `[next]`, can track the entire call path

### Examples

```tcl
# Basic usage
set body {
  return [list [current nextmethod] {*}[next]]
}
Object create o
set mh [o public method foo {} $body]
o foo  # Returns: {{}}

# With filters and mixins
Class create M 
set mh2 [M public method foo {} $body]
M filters add foo
o mixin M
o foo  # Returns: [list $mh2 $mh {}]
``` 