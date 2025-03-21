# NX with Tcl 8.6 Features Cheatsheet

## Overview
This cheatsheet covers the features demonstrated in the tcl86.test file, which showcases the integration of Next Scripting Framework (NX) with advanced Tcl 8.6 features such as coroutines, yielding, command resolution, and namespaces.

## Requirements
- Tcl 8.6 or newer
- NX package
- NX test package

## Coroutines and Yield Basics

### Simple Number Generator
```tcl
nx::Object create ::numbers {
  set :delta 2
  :public object method ++ {} {
    yield
    set i 0
    while 1 {
      yield $i
      incr i ${:delta}
    }
  }
}

# Create and use a coroutine
coroutine nextNumber ::numbers ++
nextNumber  # First call returns nothing, initializes coroutine
nextNumber  # Returns 0
nextNumber  # Returns 2, etc.

# Clean up coroutine
rename nextNumber {}
```

## Enumerator Patterns

### Basic Enumerator (Single Class)
```tcl
nx::Class create Enumerator {
  :property members:0..n
  :public method yielder {} {
    yield [info coroutine]
    foreach m ${:members} {
      yield $m
    }
    return -level 2 -code break
  }
  :public method next {} {${:coro}}
  :method init {} {
    :require namespace
    set :coro [coroutine [self]::coro [self] yielder]
  }
}

# Usage:
set e [Enumerator new -members {1 2 3}]
while 1 {
  # Will iterate through members and then break the loop
  puts [$e next]
}
```

### Advanced Enumerator (Yielder & Enumerator)
```tcl
nx::Class create Yielder {
  :property {block ";"}
  :variable continuation ""
  :public alias apply ::apply
  
  :public method yielder {} {
    yield [info coroutine]
    eval ${:block}
    return -level 2 -code break
  }
  
  :public method next {} {${:continuation}}
  
  :public method each {var body} {
    while 1 {
      uplevel [list set $var [:next]]
      uplevel $body
    }
  }
  
  :method init {} {
    :require namespace
    set :continuation [coroutine [self]::coro [self] yielder]
  }
}

nx::Class create Enumerator -superclass Yielder {
  :property members:0..n
  :property {block {
    foreach m ${:members} { yield $m }
  }}
}
```

### Using Enumerator
```tcl
# Using next() method
set e [Enumerator new -members {1 2 3}]
while 1 { incr sum [$e next] }  # Sum will be 6

# Using each() method
set e [Enumerator new -members {a be bu}]
$e each x { append string $x }  # String will contain "abebu"
```

### Extending Enumerator
```tcl
nx::Class create ATeam -superclass Enumerator {
  :public method each {var body} {
    while 1 {
      set value [string totitle [:next]]  # Capitalize first letter
      uplevel [list set $var $value]
      uplevel $body
    }
  }
  
  :public method concat {} {
    set string "-"
    :each x { append string $x- }
    return $string
  }
}

# Usage:
ATeam create a1 -members {alice bob caesar}
a1 concat  # Returns "-Alice-Bob-Caesar-"
```

## Apply Function

### Using Apply with NX Objects
```tcl
# Register apply as an alias
::nx::Object public alias apply ::apply

::nx::Object create o {
  set :delta 100
  
  :public object method map {lambda values} {
    set result {}
    foreach value $values {
      lappend result [:apply $lambda $value]
    }
    return $result
  }
}

# Usage:
o map {x {return [string length $x]:$x}} {a bb ccc}  # Returns "1:a 2:bb 3:ccc"
o map {x {expr {$x * ${:delta}}}} {1 2 3}  # Returns "100 200 300"
```

## Command Resolution and Namespaces

### Command Resolution in NX Context
Command resolution in NX follows a specific pattern, especially with special characters:

```tcl
# Define commands with special characters
proc ::nx::@ {} { return ::nx::@ }
proc ::@ {} { return ::@ }

# Resolution in NX context
nx::Object create ::o {
  :public object method foo {} {
    @  # Resolves against ::nx::@ via interp resolver
  }
}

::o foo  # Returns ::nx::@
```

### Understanding Command Types
```tcl
proc getType {x} {dict get [::nsf::__db_get_obj @] type}

# Types can be empty, cmdName or bytecode depending on context
getType @   # May show "", "cmdName", or "bytecode"

# Command resolution transformation
namespace origin @  # Converts from bytecode to cmdName
```

### Interpreter Aliases
```tcl
proc ::@@ {} {return ::@@}
proc ::nx::@ {} {return ::nx::@}

interp alias {} ::nx::@ {} ::@@

# After aliasing, resolution follows the alias
::nx::@  # Returns ::@@
```

## Testing Framework

### NX Test Case Structure
```tcl
nx::test case case-name {
  # Setup code
  
  # Tests with '?' operator
  ? {expression} expected-result
  
  # Cleanup code
}
```

### Test Assert Operator
The `?` operator evaluates an expression and compares it against the expected result:

```tcl
? {set a 5} 5  # Pass
? {expr {2+2}} 4  # Pass
? {some-command} expected-output  # Pass if output matches
```

## Version-Specific Features

### Conditional Testing
```tcl
# Skip tests if requirement not met
if {![package vsatisfies [package req Tcl] 8.6.7]} {return}

# Version-specific test branches
set tcl87 [package vsatisfies [package req Tcl] 8.7-]
if {!$::tcl87} {
    # Tcl 8.6-specific tests
}
``` 