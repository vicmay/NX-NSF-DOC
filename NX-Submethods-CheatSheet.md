# NX Submethods Cheatsheet

## Overview

Submethods in NX (Next Scripting Framework) are hierarchical method structures that allow creating command ensembles with multiple levels of dispatch. This document covers the key concepts, syntax, and behaviors of submethods based on the test cases.

## Basic Syntax

### Defining Submethods

```tcl
# Define a submethod with space-separated path components
:object method "string length" x {return [current method]}
:object method "foo a x" {} {return [current method]}

# For class methods
:method "bar m1" {a:integer -flag} {;}
:method "baz a m1" {x:integer -y:boolean} {return m1}
```

### Calling Submethods

```tcl
# Standard submethod call
obj foo a x

# Using colon notation for object-local calls
obj eval { :foo a x }

# Calling with colon prefix (alternative syntax)
obj eval { : foo a x }

# Local call with -local flag (for private methods)
obj eval { : -local foo a x }
```

## Error Handling and Discovery

### Error Messages

When a submethod cannot be found, NX provides helpful error messages:

```
unable to dispatch sub-method "z" of ::obj foo a; valid are: foo a defaultmethod, foo a subcmdName, foo a unknown, foo a x, foo a y
```

### Listing Available Submethods

Calling a partial path returns a list of valid submethods:

```tcl
# Returns: "valid submethods of ::obj string: info length tolower"
obj string

# Use lsort to get an alphabetical list of available submethods
lsort [obj info has]
```

## Introspection in Submethods

### Current Context

```tcl
# Get the current method name
[current method]

# Get the current class
[current class]

# Get the full method path
[current methodpath]

# Get current method arguments
[current args]

# Get the current object
[self]
```

### Calling Context

```tcl
# Get the calling class
[current callingclass]

# Get the calling object
[current callingobject]

# Get the calling method
[current callingmethod]
```

### Next Methods

```tcl
# Get the next method in the chain
[current nextmethod]

# Check if current call is from next
[current isnextcall]

# Get the method that was called
[current calledmethod]

# Get the class of the called method
[current calledclass]
```

## Using `next` with Submethods

```tcl
# Basic next usage in a submethod
:method "foo a" {x} {
  # Do something
  nx::next
}

# Passing arguments to next
:method "foo a" {} {next 42}

# Collecting results from next
set result [next]

# Appending next results to your own
return [list "My result" {*}[next]]
```

### Leaf Next

A "leaf next" is a next call at the end of the method resolution chain:

```tcl
:public object method "FOO bar" {} {
  incr :x; next;  # a "leaf next" - won't trigger unknown handling
}
```

### Next with Ensemble Methods

When using next with ensemble methods, the next call is passed to the appropriate level in the hierarchy:

```tcl
# In a mixin class
:method "foo a" {x} {
  nx::next  # Calls the "foo a" method in the next class
}

# With different ensemble depths
:method "l1 l2" {args} {
  nx::next  # Can connect to methods with different ensemble depths
}
```

## Method Protection and Visibility

```tcl
# Public submethod
:public method "foo a" {} {return something}

# Private submethod
:private method "bar x" {} {return something}

# Protected submethod
:protected method "baz y" {} {return something}

# Local calls to private methods
:public method some_method {} {: -local private_method}
```

### Private Helper Methods

Private submethods can be used as helper methods that are only accessible from within the object:

```tcl
:public object method foo {} {: -local bar 1}  # Calls private bar method
:private object method "bar 1" {} {: -local baz 1}  # Calls private baz method
:private object method "baz 1" {} {return "result"}
```

## Variable Access in Ensemble Methods

### Using upvar

```tcl
# Regular upvar - doesn't work across ensemble boundaries
:method "bar0 x" {varname} {
  upvar $varname v
  return [info exists v]  # Returns 0
}

# NX-specific upvar - works across ensemble boundaries
:method "bar1 x" {varname} {
  :upvar $varname v  # Note the colon prefix
  return [info exists v]  # Returns 1
}
```

## Method Forwarding with Submethods

```tcl
# Forward to a command with submethods
:public object forward link1 {%[self]::child}

# Forward to a child object
:public object forward link2 :child

# Method-based forwarding
:public object method link3 args {[self]::child {*}$args}

# Alias forwarding
:public object alias link4 [self]::child

# Direct object forwarding
:public object forward link5 [self]::child
```

## Object Properties Affecting Submethod Behavior

### keepcallerself

Controls whether `[self]` refers to the caller or the called object in forwarded calls.

```tcl
# Set keepcallerself
::nsf::object::property ::some_obj keepcallerself true

# When true: the self in called methods is the caller
# When false: the self in called methods is the invoked object
```

### perobjectdispatch

Controls whether instance methods are accessible via object-specific forwarding.

```tcl
# Set perobjectdispatch
::nsf::object::property ::some_obj perobjectdispatch true

# When true: instance methods are not accessible via object forwarding
# When false: instance methods are accessible via object forwarding
```

### Combined Effects of keepcallerself and perobjectdispatch

Different combinations of these properties create different behaviors:

```tcl
# keepcallerself off, perobjectdispatch off
# - self in called method is the invoked object
# - instance methods are callable
::nsf::object::property ::obj keepcallerself off
::nsf::object::property ::obj perobjectdispatch off

# keepcallerself off, perobjectdispatch on
# - self in called method is the invoked object
# - instance methods are not callable
::nsf::object::property ::obj keepcallerself off
::nsf::object::property ::obj perobjectdispatch on

# keepcallerself on, perobjectdispatch on
# - self in called method is the caller
# - instance methods are not callable
::nsf::object::property ::obj keepcallerself on
::nsf::object::property ::obj perobjectdispatch on

# keepcallerself on, perobjectdispatch off
# - self in called method is the caller
# - instance methods are callable
::nsf::object::property ::obj keepcallerself on
::nsf::object::property ::obj perobjectdispatch off
```

## Ensemble vs Simple Methods

NX prevents overwriting methods with submethods or vice versa:

```tcl
# This works
C public method foo {args} {return foo/1}

# This fails with "refuse to overwrite method foo"
C public method "foo x" {args} {return foo/2}

# This works (different root method name)
C public method "bar x" {args} {return bar/2}

# This fails (tries to overwrite existing submethod)
C public method "bar x y" {args} {return foo/3}
```

## Mixins with Submethods

Mixins can provide or override submethods at any level:

```tcl
# Base class with submethods
nx::Class create BaseClass {
  :method "foo a" {} {return "base"}
}

# Mixin class with submethods
nx::Class create MixinClass {
  :method "foo a" {} {
    return "mixin [next]"  # Calls next method in chain
  }
}

# Apply the mixin
BaseClass mixins set MixinClass

# Result: "mixin base"
```

## Default Methods and Unknown Handling

When a method isn't found, NX provides mechanisms to handle it:

```tcl
# Default method handler
:object method "foo a defaultmethod" {} {
  # Handle unknown subcommands
  return [current method]
}

# Unknown handler
:object method "foo a unknown" args {
  # Handle unknown subcommands with arguments
  return [current method]
}
```

## Symbol Naming Considerations

There are special considerations when using certain names that might conflict with internal command names:

```tcl
# Potential conflict with Tcl commands
:object method "string length" x {return [current method]}
:object method "string info" x {return [current method]}

# Potential conflict with ensemble internals
:object method "foo a subcmdName" {} {return [current method]}
:object method "foo a defaultmethod" {} {return [current method]}
:object method "foo a unknown" args {return [current method]}
```

## Best Practices

1. Use submethods to create logical hierarchies of commands
2. Use the `:` prefix with `-local` for calling private submethods: `: -local private_method`
3. Be aware of `keepcallerself` and `perobjectdispatch` settings when forwarding methods
4. Use `[current methodpath]` to get the full path of the current method
5. Leverage error messages to provide information about available submethods
6. Use `:upvar` instead of `upvar` when accessing variables across ensemble boundaries
7. Consider using private submethods as internal helpers to maintain clean interfaces
8. Be careful with method names that might conflict with Tcl commands or ensemble internals
9. Standardize your ensemble hierarchies for consistency across your codebase

## Common Pitfalls

1. Cannot overwrite a simple method with a submethod (or vice versa)
2. Submethods are sensitive to protection modifiers (public, private, protected)
3. When using `next` in submethods, be aware of the method resolution path
4. Ensure proper handling of arguments when forwarding to submethods
5. Regular `upvar` doesn't work across ensemble boundaries - use `:upvar` instead
6. Method path reporting in error messages may be confusing at first
7. `keepcallerself` without `perobjectdispatch` can lead to unexpected behavior
8. Namespace conflicts between child objects and methods with the same name

## Debugging Submethods

```tcl
# List all available methods
lsort [obj info object methods]

# Check method type
obj info object method type methodname

# Get a method's registration handle
set mh [Class info method registrationhandle methodname]

# Test for method existence
if {[obj info lookup methods pattern] ne ""} {
  # Method exists
}
```

## Advanced Techniques

### Method Path Navigation

```tcl
# Access parent in the method path
:method "parent child" {} {
  # Access the parent level
  [namespace parent [namespace current]]
}

# Dynamic method resolution
:method "foo" args {
  # Dynamically determine and call a submethod
  set submethod [lindex $args 0]
  return [my foo $submethod {*}[lrange $args 1 end]]
}
```

### Callstack Manipulation

```tcl
# Examine the call stack structure
:method debug {} {
  set callstack [info level]
  puts "Call depth: $callstack"
  for {set i 1} {$i <= $callstack} {incr i} {
    puts "Level $i: [info level $i]"
  }
}
``` 