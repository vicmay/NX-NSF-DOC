# NX Parameters Cheatsheet

## Table of Contents
- [Basic Parameter Types](#basic-parameter-types)
- [Type Converters](#type-converters)
- [Parameter Multiplicity](#parameter-multiplicity)
- [Method Parameters](#method-parameters)
- [Object Parameters](#object-parameters)
- [Properties](#properties)
- [Parameter Checking](#parameter-checking)
- [User-Defined Type Converters](#user-defined-type-converters)
- [SubstDefault Parameter Option](#substdefault-parameter-option)
- [Slot Objects](#slot-objects)
- [Parameter Options Reference](#parameter-options-reference)
- [Parameter Aliasing and Forwarding](#parameter-aliasing-and-forwarding)
- [Incremental Properties](#incremental-properties)
- [Trace Functionality](#trace-functionality)
- [NSF Procedures](#nsf-procedures)
- [Parameter Caching](#parameter-caching)
- [Advanced Examples](#advanced-examples)

## Basic Parameter Types

| Type | Description | Example |
|------|-------------|---------|
| `integer` or `int` | Integer values | `x:integer` |
| `int32` | 32-bit integer | `x:int32` |
| `wideinteger` | 64-bit integer | `x:wideinteger` |
| `double` | Floating point number | `x:double` |
| `boolean` | Boolean values (0/1, true/false, etc.) | `x:boolean` |
| `string` | String values | `x:string` |
| `upper` | Uppercase string | `x:upper` |
| `lower` | Lowercase string | `x:lower` |
| `switch` | Switch parameter (no value needed) | `-x:switch` |
| `object` | Object reference | `x:object` |
| `class` | Class reference | `x:class` |
| `metaclass` | Metaclass reference | `x:metaclass` |
| `baseclass` | Base class reference | `x:baseclass` |
| `any` | Any type (no type checking) | `x:any` |

## Type Converters

Type converters validate parameter values and optionally transform them:

```tcl
::nx::methodParameterSlot object method type=sex {name value} {
    switch -glob $value {
        m* {return m}
        f* {return f}
        default {error "expected sex but got $value"}
    }
}

# Using the converter
C public method foo {s:sex} {return $s}
```

## Parameter Multiplicity

Define parameters that accept multiple values:

| Multiplicity | Description | Example |
|--------------|-------------|---------|
| `0..1` | Optional, at most one value | `x:integer,0..1` |
| `0..n` or `0..*` | Optional, any number of values | `x:integer,0..n` |
| `1..n` or `1..*` | Required, at least one value | `x:integer,1..n` |
| `m..n` | Specific range (m to n values) | `x:integer,2..5` |

```tcl
# Examples
D public method foo {m:integer,0..n} {return $m}
Foo property ints:integer,1..*
```

## Method Parameters

### Positional Parameters

```tcl
D public method foo {a b {c 1}} {
    # a - required
    # b - required
    # c - optional with default value 1
}
```

### Non-positional Parameters

```tcl
D public method foo {-x:integer -y:switch {-z 1}} {
    # -x - optional with type checking
    # -y - switch parameter
    # -z - optional with default value 1
}
```

### Required Parameters

```tcl
D public method foo {a:required b:integer,required} {
    # Both parameters are required
}
```

### Optional Parameters

```tcl
D public method foo {a:optional b:optional c} {
    # a,b are optional positional parameters, c is required
}
```

### Parameter with Default and Type

```tcl
D public method foo {-x {-y:integer 10}} {
    # -x without type or default
    # -y with integer type and default 10
}
```

## Object Parameters

Object parameters are defined via properties and used during object creation/configuration:

```tcl
nx::Class create C {
    :property a
    :property {b:boolean true}
    :property c:required
}

# Create object with parameters
C create c1 -a "value" -b false -c "required value"

# Configure existing object
c1 configure -a "new value"
```

## Properties

### Basic Property Definition

```tcl
nx::Class create C {
    :property a                 # No default value
    :property {b 1}             # With default value
    :property c:boolean         # With type checking
    :property {d:integer 100}   # With type checking and default
    :property e:required        # Required property
}
```

### Accessor Methods

```tcl
nx::Class create C {
    :property -accessor public a    # Creates getter/setter: 'a get', 'a set value'
    :property -accessor none b      # No accessors
}
```

### Object-level Properties

```tcl
nx::Object create o {
    :object property a             # Per-object property
    :object property {b:integer 1} # With type and default value
}
```

### Class-level Variables vs Properties

```tcl
nx::Class create C {
    :variable v "value"        # Simple variable, no object parameter
    :property p "value"        # Creates object parameter and variable
}
```

## Parameter Checking

### Enabling/Disabling Checking

```tcl
nsf::configure checkarguments on   # Enable parameter checking (default)
nsf::configure checkarguments off  # Disable parameter checking
```

### Method-specific Checking

```tcl
nx::Class create C {
    :public method m1 {-x:integer} {}                # Normal checking
    :public method m2 {-x:integer} -checkalways {}   # Always check, even when globally disabled
}
```

## User-Defined Type Converters

### For Method Parameters

```tcl
::nx::methodParameterSlot object method type=range {name value arg} {
    lassign [split $arg -] min max
    if {$value < $min || $value > $max} {
        error "value '$value' of parameter $name not between $min and $max"
    }
    return $value
}

# Usage
D public method foo {a:range,arg=1-10} {return $a}
```

### For Object Parameters

```tcl
::nx::ObjectParameterSlot method type=range {name value arg} {
    lassign [split $arg -] min max
    if {$value < $min || $value > $max} {
        error "value '$value' of parameter $name not between $min and $max"
    }
    return $value
}

# Usage
nx::Class create C {
    :property value:range,arg=0-100
}
```

### Slot-specific Type Checkers

```tcl
nx::Class create Person {
    :property -accessor public sex:sex,convert {
        :object method type=sex {name value} {
            switch -glob $value {
                m* {return m}
                f* {return f}
                default {error "expected sex but got $value"}
            }
        }
    }
}
```

## SubstDefault Parameter Option

The `substdefault` option substitutes Tcl commands in the default value:

```tcl
nx::Class create C {
    :property {name:substdefault "[namespace tail [::nsf::self]]"}
    :public method foo {{-s:substdefault "[current]"}} {return $s}
}

# When used, [current] will be substituted with the current object
```

## Slot Objects

Slots are objects that store metadata about properties:

```tcl
nx::Class create C {
    :property -accessor public count {
        :object method value=set {obj property value} {
            # Custom setter
            nsf::var::set $obj $property [expr {$value + 1}]
        }
    }
}
```

### Using Traces

```tcl
nx::Class create C {
    :property -accessor public -trace set count {
        :object method value=set {obj property value} {
            nsf::var::set -notrace $obj $property [expr {$value + 1}]
        }
    }
}
```

### Trace Types

| Trace Type | Description |
|------------|-------------|
| `default` | Triggered when default value is used |
| `get` | Triggered on variable reading |
| `set` | Triggered on variable writing |

## Parameter Options Reference

| Option | Description | Example |
|--------|-------------|---------|
| `required` | Parameter is required | `x:required` |
| `optional` | Parameter is optional | `x:optional` |
| `substdefault` | Substitute Tcl code in default | `x:substdefault` |
| `noconfig` | Don't expose as object parameter | `x:noconfig` |
| `convert` | Apply converter to value | `x:integer,convert` |
| `noarg` | Parameter takes no argument | `-x:switch` |
| `slot=object` | Use specified slot object | `x:integer,slot=::mySlot` |
| `arg=value` | Pass arg to type checker | `x:range,arg=1-10` |

## Parameter Aliasing and Forwarding

```tcl
nx::Class create C {
    :property {x:alias}                              # Parameter will call method x
    :property {{F:forward,method=%self foo %1 a b}}  # Parameter forwards to foo method
}
```

## Incremental Properties

```tcl
nx::Class create C {
    :property -incremental ints:integer,1..*  # Create a multi-valued property with methods:
                                             # ints add, ints delete, ints set, etc.
}

# Usage
C create o1 -ints {1 2 3}
o1 ints add 4        # Add a value
o1 ints delete 2     # Remove a value
o1 ints set {5 6 7}  # Replace all values
```

## Trace Functionality

```tcl
nx::Class create C {
    :property -accessor public -trace default a {
        :public object method value=default {obj var} { return 4 }
    }
    
    :property -accessor public -trace get b {
        :public object method value=get {obj property} { return 44 }
    }
    
    :property -accessor public -trace set c {
        :public object method value=set {obj property value} { 
            ::nsf::var::set $obj $property 999 
        }
    }
}
```

## NSF Procedures

```tcl
# Define NSF procedure with parameter checking
nsf::proc p1 {-x:integer} { return $x }

# With checkalways option (check even when globally disabled)
nsf::proc -checkalways p2 {-x:integer} { return $x }

# Parse arguments with NSF
nsf::parseargs {a:int b:string} {1 "hello"}
```

## Parameter Caching

```tcl
# Invalidate class parameter cache
::nsf::parameter::cache::classinvalidate C

# Check object parameter
c1 eval :__object_configureparameter
```

## Advanced Examples

### Value Checking Control Flow

```tcl
# Check value with nsf::is
if {[::nsf::is object,type=::C $obj]} {
    # Object is of type C
}

# Check multiple values
if {[::nsf::is -complain integer,1..* [list 1 2 3]]} {
    # All values are integers
}
```

### Method Returns Type

```tcl
nx::Class create C {
    :public method foo {x:integer} -returns integer {
        return [expr {$x + 1}]
    }
}
```

### Custom MetaSlot

```tcl
::nx::MetaSlot create ::nsv::TraceVariableSlot -superclass ::nx::VariableSlot {
    :property {trace {get set}}
    :public method value=set {obj varName value} {
        # Custom value setter
        next
    }
}

# Using custom MetaSlot
nx::Class create C {
    :property -class ::nsv::TraceVariableSlot x
}
``` 