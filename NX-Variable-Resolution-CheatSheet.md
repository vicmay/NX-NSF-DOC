# NX Variable Resolution Cheatsheet

## Introduction

This cheatsheet documents variable resolution mechanisms in NX, based on tests from `varresolution.test`. NX provides a flexible object-oriented framework with various variable scoping and resolution rules.

## Basic Concepts

### Variable Types in NX

- **Instance Variables**: Variables belonging to an object
- **Global Variables**: Variables in the global namespace
- **Local Variables**: Variables within method/proc scope
- **Namespace Variables**: Variables in object namespaces

### Variable Notation

- `:varname` - Colon prefix for instance variables
- `::varname` - Global variables
- `[current]::varname` - Fully qualified namespace variable
- `[self]::varname` - Alternative for current object's namespace variables

## Method Aliases for Variable Operations

NX provides method aliases for common Tcl commands:

```tcl
::nsf::method::alias ::nx::Object objeval -frame object ::eval
::nsf::method::alias ::nx::Object array -frame object ::array
::nsf::method::alias ::nx::Object lappend -frame object ::lappend
::nsf::method::alias ::nx::Object incr -frame object ::incr
::nsf::method::alias ::nx::Object set -frame object ::set
::nsf::method::alias ::nx::Object unset -frame object ::unset
```

These aliases provide variable operations in the object's context.

## Object Namespaces

Objects can have associated namespaces:

```tcl
nx::Object create o
o require namespace  # Create a namespace for the object
```

- `o info has namespace` returns 1 if namespace is required, 0 if namespace exists but wasn't required
- Namespaces allow mixing Tcl namespace and NX object interfaces
- When namespace is not explicitly required but exists, different behavior might occur

### Per-Object Namespace Access

```tcl
# Direct namespace access
namespace eval ::o {set x 3}

# Object variable access (same variable)
::o set x
```

## Variable Access Methods

### Setting Variables

```tcl
# Setting instance variables
o set x 1          # Set instance variable 'x'
set :x 1           # Within method/object context
set [current]::X 4 # Fully qualified namespace variable
```

### Reading Variables

```tcl
# Reading instance variables
o set x            # Read instance variable 'x'
${:x}              # Within method/object context
$::varname         # Global variable access
```

### Checking Variable Existence

```tcl
o eval {info exists :x}         # Check if instance variable exists
::nx::var exists o x            # Alternative API
::nsf::var::exists [current] x  # Check from within method
```

### Variable Import

```tcl
::nsf::var::import o2 i   # Import variable 'i' from object o2
```

Restrictions:
- Cannot import variables with namespace separators/colon prefixes: `::nsf::var::import [current] :a` will fail
- Cannot import array elements directly: `::nsf::var::import [current] a(:b)` will fail
- Can use alias for array elements: `::nsf::var::import [current] {a(:b) ab}` works

## Array Operations

```tcl
# Array operations
o array exists a             # Check if array exists
o array set a {1 2 3 4}      # Set array values
o array get a                # Get all array values
o array get a 1              # Get specific array element
o array names a              # Get array keys
o array size a               # Get array size
o set a(1) 7                 # Set array element
o set :a(:b) 1               # Set array with key containing colons
o set :a(::c) 1              # Set array with global namespace in key
```

## Evaluation Contexts

NX provides several evaluation contexts with different variable resolution behaviors:

### eval

Standard evaluation with instance variable access:
```tcl
o eval {set :x 1}  # Evaluate in object context
```

### objeval (Object-scoped eval)

All variables become instance variables:
```tcl
o objeval {
  set aaa 1        # Creates instance variable 'aaa'
  set :a 1         # Creates instance variable 'a'
  global g         # Access global variable
  :require namespace # Can require namespace within objscoped frame
}
```

### softeval (Method-scoped eval)

Only variables with colon prefixes become instance variables:
```tcl
o softeval {
  set bbb 1        # Local variable, not an instance variable
  set :b 1         # Creates instance variable 'b'
}
```

### plain eval (No resolver)

No automatic instance variable creation:
```tcl
o softeval2 {
  set zzz 1        # Local variable
  set :z 1         # Not an instance variable
}
```

## Method Dispatch and Variable Resolution

### Dot Notation for Method Calls

```tcl
:methodName arg    # Call a method on the current object
```

### Method Frame Context

Method calls maintain the object context for variable resolution:
```tcl
o method foo {} {
  set :x 1         # Creates instance variable x
  :bar             # Calls method 'bar' with the same object context
}
```

### Object Methods vs. Class Methods

Both classes and objects maintain separate variable tables:

```tcl
nx::Class create C {:property {x 1}}
C create c1

# Class methods can set/access instance variables
C method foo {x} {set :y 2; return ${:x},${:y}}

# Class instance variables persist across instances
c1 foo 1      # returns "1,2"
```

## Variable Persistence and Caching

```tcl
# Variable caching between method calls
nx::Object create o
o object method foo {x} {set :y 2; return ${:x},${:y}}
o object method bar {} {return ${:x},${:y}}
o set x 1
o foo 1        # "1,2" - creates var y and fetches var x
o bar          # "1,2" - fetches two instance variables

# Recreating objects resets variables
nx::Object create o
o set x 1
o bar          # Error - compiled var y should not exist
```

## Variable Resolution in Special Contexts

### uplevel

Variable resolution works across uplevel calls:
```tcl
# Variable resolution works with uplevel
uplevel ${:cmd}    # Command with instance variables resolves in caller's context
uplevel 2 ${:cmd}  # Works across multiple levels
```

### apply

Variable resolution works with lambda functions:
```tcl
::apply [list {} {:set a} [self]]  # Resolves to instance variable 'a'
```

### Mixins and next

Instance variables resolve correctly after next calls:
```tcl
:public method mixin_method {} {
  next
  :instvar package_id  # Works correctly after next
}
```

### vwait for Event Loop

```tcl
# Handle vwait with instance variables
:public object method vwait {varName} {
  if {[regexp {:[^:]*} $varName]} {
    error "invalid varName '$varName'; only plain or fully qualified variable names allowed"
  }
  if {[string match ::* $varName]} {
    ::vwait $varName
  } else {
    ::vwait :$varName
  }
}

# Using vwait with instance variables
vwait :x          # Wait for instance variable to change
:vwait x          # Using method wrapper
```

## Compiled vs Interpreted Code

NX supports both compiled and interpreted execution with some behavioral differences:

### Compiled Code

- Creates link variables for colon-prefixed variables
- More efficient for repeated access
- Link variables are visible through `info vars :*`
- Creates a sorted lookup cache for performance

```tcl
# Compile-time var resolver side effects
# At compile time, the resolver looks up (and creates) object variables
# for colon-prefixed vars: ":u" -> "u", ":v" -> "v"
# The compiler emits colon-prefixed *link* variables into the compiled local array
```

### Interpreted Code

- Resolves variables on demand
- No link variables created
- Behavior differs slightly from compiled code
- May handle some edge cases differently

```tcl
# Non-compiled execution has different resolution behavior
? [list o eval $script]     # Interpreted execution
? {o baz}                   # Compiled execution
```

### Cache Management

```tcl
# Cache must be refreshed when method definitions change
# Adding a variable at the first position might break resolution if cache isn't updated
p public object method baz {} {
    set :a 123        # Adding new variable
    set :z 30         # Existing variable
    # ...
}
```

## Warnings and Limitations

1. Mixing `variable` command with colon-prefixed variables can lead to unexpected behavior
2. `namespace which -variable :X` behaves differently than expected
3. Colon-prefixed variables with `upvar` require careful handling
4. Variable resolution caches must be refreshed when method definitions change
5. Differences between compiled and non-compiled execution can cause subtle bugs

### Scoping Issues

```tcl
# Variable command interacting with colon-prefixed vars
variable :aaa         # Creates a namespace variable WITH colon
set :aaa 2            # Sets/creates an instance variable WITHOUT colon

# This can lead to counterintuitive behaviors where:
# 1. No 'variable ":aaa" already exists' error will occur
# 2. The local link var ":aaa" created by [variable] can't be accessed
```

## Interaction with Tcl Commands

### variable

```tcl
variable :name     # Creates a namespace variable with ':' prefix
                   # NOT an instance variable 'name'

# Issue 1: In non-compiled execution, [variable] sets AVOID_RESOLVERS flags
# In compiled execution, this flag may be missing

# Issue 2: Link variables created by [variable] can be switched to 
# point to different targets
```

### upvar

```tcl
upvar $var :x      # Links to variable named ':x', not instance variable 'x'

# Example of complex upvar usage
:object method bar {var1 var2 var3 var4 var5 var6} {
  upvar $var1 xx $var2 :yy $var3 :zz $var4 q $var5 :el1 $var6 :el2
  # Now xx, :yy, :zz, q, :el1, :el2 are all link variables
}
```

### namespace which

```tcl
namespace which -variable :XXX  # Behavior may be counter-intuitive
# [namespace which -variable :XXX] != [namespace which -variable [namespace current]:::XXX]
```

## Object and Class Property Variables

```tcl
nx::Class create C {:property {x 1}}  # Default property value
C create c1                           # Instance inherits property
c1 info vars                          # Shows "x"

# Properties become instance variables
```

## NSF Variable API

```tcl
# NSF variable interface
::nsf::var::exists object varName  # Check if variable exists
::nsf::var::set object varName value  # Set variable
::nsf::var::get object varName  # Get variable value
::nsf::var::unset object varName  # Unset variable
```

## Namespace Resolution in Objects

```tcl
# Namespace resolver for mixins
namespace eval module {
  nx::Class create C
  nx::Class create M1
  nx::Class create M2

  C mixins set M1
  C mixins add M2
}
# Proper resolution of namespace-qualified class names
```

## Common Patterns and Best Practices

1. Use `o require namespace` when mixing namespace and object interfaces
2. Prefer explicit notation for clarity: `:var` within methods, `o set var` externally
3. Be aware of different behavior in objeval, softeval, and plain eval
4. Use `::nx::var` API for safer external access
5. Be careful with array elements in variable operations
6. Consider cached resolution effects with compiled code
7. Avoid mixing colon-prefixed variable names with `variable` and `upvar` commands
8. Test both compiled and interpreted execution paths
9. Be aware of frame context differences when using `uplevel` and `apply`
10. Avoid namespace variables with same names as instance variables

## Debugging Tips

1. Use `o info vars` to list all instance variables
2. Check variable existence with `o eval {info exists :x}`
3. Test namespaces with `o info has namespace`
4. Understand the differences between compiled and interpreted execution
5. Use `info vars :*` to see compiled link variables
6. Check variable resolution across different evaluation contexts
7. Test variable persistence when recreating objects or methods

## Scope Visibility Table

| Context | set var | set :var | global var | [current]::var |
|---------|---------|----------|------------|----------------|
| initcmd | local   | instance | global     | namespace      |
| objeval | instance| instance | global     | namespace      |
| softeval| local   | instance | global     | namespace      |
| plain eval| local | local    | global     | namespace      |

## Advanced Variable Resolution Rules

1. When a method references a colon-prefixed variable, the variable resolver first checks if it exists in the object's variable table.
2. If not found and the variable is being written to, it's created in the object's variable table.
3. Compiled link variables are created at compile time but only defined at runtime.
4. Variable resolution works differently in compiled vs. interpreted code.
5. Method aliases with `-frame object` affect how variables are resolved within the method.
6. Dot-command resolution (`:method`) maintains the variable context of the caller object.

## Variable Interaction with Control Structures

```tcl
# Variables in conditional expressions
if {[info exists :x]} {set :x 1000}

# Using variables in loops
foreach elem [:array names a] {
  # Process array elements
}

# Variables in lambda expressions with apply
::apply [list {} {x {:set a}} [self]]
``` 