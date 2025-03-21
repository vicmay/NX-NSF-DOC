# NX Methods Cheatsheet

## Basic Method Declaration

```tcl
# Basic method declaration
:method name {args} {body}                     # Default protection is public
:public method name {args} {body}              # Explicitly public
:protected method name {args} {body}           # Protected from external calls
:private method name {args} {body}             # Only accessible within class

# Object-specific methods
:object method name {args} {body}              # Default protection is public
:public object method name {args} {body}       # Explicitly public
:protected object method name {args} {body}    # Protected from external calls
:private object method name {args} {body}      # Only accessible within object

# Method with non-positional arguments
:method foo {-x:required -y:required} {
    # Access via $x and $y
    return [list x $x y $y [current args]]
}
# Call with: obj foo -x 13 -y 14
# or:        obj foo -y 14 -x 13

# Enum method (with spaces in name)
:method "info filter guard" {filter} {
    return [current object]-[current method]
}
# Call with: obj info filter guard filtername
```

## Method Name Validity

- Empty string (`""`) is invalid as a method name
- Names cannot contain Tcl whitespace characters:
  - Space (`" "`)
  - Tab (`\t`)
  - Newline (`\n`)
  - Vertical Tab (`\v`)
  - Form Feed (`\f`)
  - Carriage Return (`\r`)
- Names with spaces must be quoted: `"method name"`
- Names cannot start with a colon: `:method` is invalid
- Special characters in method names:
  - Curly braces can be used: `{{{{a}}}}`
  - Hash is allowed: `#method`
  - List notation affects parsing: `{a b}` is invalid due to space

## Method Call Styles

```tcl
# Basic styles
obj method arg1 arg2              # Standard call
obj "method name" arg1 arg2       # Method name with spaces

# Self-calls from within methods
:method_name arg1 arg2            # Using colon prefix  
[self] method_name arg1 arg2      # Using self command
: method_name arg1 arg2           # Colon with space

# Expansion handling
{*}[list :method arg1 arg2]       # Expands to valid method call
: {*}[list method arg1 arg2]      # Expands after colon
```

## Property Methods

```tcl
# Property declaration
:property name                                 # Default accessor is not public
:property -accessor public name                # Public accessor
:property -accessor protected name             # Protected accessor
:property {name default}                       # With default value
:property -accessor public a:int               # With type constraint

# Object properties
:object property {name default}                # With default value
:object property -accessor public {name ""}    # Public accessor with empty default
:object property -accessor protected name      # Protected accessor

# Property usage
obj name set value                             # Set property value
obj name get                                   # Get property value
obj cget -name                                 # Get via cget
obj configure -name value                      # Configure property
obj cget -name                                 # Get configured value

# Creating property returns handle
set x [:property -accessor public a]           # Store method handle
set X [:object property -accessor public A]    # Store object method handle

# Type constraints
obj a set "text"                               # Will fail if a:int constraint
```

## Method Delegation

```tcl
# Forward declaration
:forward name %self other_method               # Forward to same object's method
:forward name ::other_object method            # Forward to other object
:public forward name target method             # Public forward
:protected forward name target method          # Protected forward

# Object forwards
:object forward name %self other_method        # Forward on object
:public object forward name target method      # Public object forward
:protected object forward name target method   # Protected object forward

# Alias declaration
:alias name [C info method registrationhandle method_name]  # Alias to method handle
:public alias name targetMethod                             # Public alias
:protected alias name targetMethod                          # Protected alias

# Object aliases
:object alias name [:info object method registrationhandle method_name]  # Object alias to handle
:public object alias name targetMethod                                   # Public object alias
:protected object alias name targetMethod                                # Protected object alias

# NSF method provision
nsf::method::provide set {::nsf::method::alias set -frame object ::set}
:require public method set                                  # Add as requirement
```

## Method Inspection

```tcl
# Method protection
C info method callprotection plain_method        # Returns "public" or "protected" 
C info object method callprotection object_method

# Registration handles
C info method registrationhandle method_name     # Get method registration handle
C info object method registrationhandle method_name

# Get method lists
obj info methods                                 # List all methods
obj info methods -path                           # Include full path for methods with spaces
obj info object methods                          # List object methods
obj info object methods -path                    # Include full path
obj info methods -callprotection all             # List all methods regardless of protection
obj ::nsf::methods::class::info::methods -callprotection all -path  # Low-level inspection

# Check method properties
C info method debug method_name                  # Is method in debug mode?
C info method deprecated method_name             # Is method deprecated?
C info object method debug method_name           # For object methods
C info object method deprecated method_name      # For object methods

# Method property inspection using nsf::method::property
nsf::method::property C foo debug                # Check debug property
nsf::method::property C bar deprecated           # Check deprecated
nsf::method::property C -per-object ofoo debug   # For object methods
```

## Method Deletion

```tcl
# Delete class methods
C delete method method_name                      # Delete class method
C delete property property_name                  # Delete property
::nsf::method::delete C foo                      # Low-level method deletion

# Delete object methods
obj delete object method method_name             # Delete object-specific method
obj delete object property property_name         # Delete object property
::nsf::method::delete C -per-object bar          # Low-level object method deletion

# Errors for non-existent methods
C delete method non_existent                     # Returns error message
obj delete object method non_existent            # Returns error message

# Deletion of ensemble methods
obj delete object method "info foo"              # Delete first-level ensemble
obj delete object method "info bar foo"          # Delete second-level ensemble
```

## Method Modifiers

```tcl
# Method modifiers
:public method -debug foo {args} {body}          # Set debug mode
:public method -deprecated bar {args} {body}     # Mark as deprecated

# Object method modifiers
:public object method -debug ofoo {args} {body}  # Set debug mode
:public object method -deprecated obar {args} {body} # Mark as deprecated

# Check method properties after setting
nsf::method::property C foo debug                # Returns 1 if debug is set
C info method debug foo                          # Returns 1 if debug is set

# Multiple modifiers can be combined
:public method -debug -deprecated foo {args} {body}
```

## The `current` Command

```tcl
current method           # Current method name
current args             # Current method arguments
current object           # Current object
current class            # Current class
current callinglevel     # Current calling level (e.g., "#0" for top level)
current callingobject    # Calling object
current callingmethod    # Calling method
current calledproc       # Called procedure name
current calledmethod     # Called method name
current nextmethod       # Next method in the chain (for mixins/filters)

# Examples
:method example {} {
    return "[current method] called on [current object] from [current callingmethod]"
}

# Checking for method calls
if {[current calledmethod] eq "foo"} {
    # Handle special case for foo
}
```

## Control Flow

```tcl
# Delegation to next method
next                     # Call next method with same args
next arg1 arg2           # Call next method with different args

# Basic next pattern for mixins
:method foo {args} {
    # Do something before
    set result [next]    # Call next method in chain
    # Do something after
    return $result
}

# Context management
:uplevel script                  # Evaluates script in caller's context
:uplevel level script            # Evaluates at specified level
:uplevel #0 script              # Evaluate at global level
:uplevel 1 script               # Evaluate at caller's level
:upvar var localvar             # Reference caller's variable
:upvar #0 var localvar          # Reference global variable

# Upvar example
:method lstat {path var} {
    :upvar $var arrayVar         # Reference caller's array
    file lstat $path arrayVar    # Fill caller's array
}

# Uplevel error handling
set rc [catch {:uplevel $script} result]
return -code $rc $result
```

## Filters and Mixins

```tcl
# Filters
C filters add filterMethod                   # Add filter method
C filters delete filterMethod                # Remove filter method
C filters guard filterMethod condition       # Add guard condition
obj object filters set intercept             # Set filter on object

# Filter method implementation
:method filterMethod {args} {
    # Pre-processing
    set result [next]                        # Execute filtered method
    # Post-processing
    return $result
}

# Mixins
C mixins set M                               # Set class mixin
C mixins set {{M -guard {1 == 1}}}           # Set with guard condition
C object mixins set M                        # Set object mixin
C mixins add M                               # Add class mixin
C object mixins add M                        # Add object mixin
C mixins clear                               # Clear all class mixins
C object mixins clear                        # Clear all object mixins

# Mixin access
C mixins get                                  # Get class mixins
C object mixins get                           # Get object mixins
C info mixins                                 # Get class mixins
C info object mixins                          # Get object mixins

# Mixin guards
C mixins guard M {1 == 1}                     # Set guard condition
C object mixins guard M {1 == 1}              # Set object guard condition
C mixins guard M ""                           # Clear guard
C info mixins -guard                          # Get guard info
C info object mixins -guard                   # Get object guard info

# Mixin via object-parameter
nx::Class create C -mixin M1 -object-mixins M2
C configure -mixin M1                         # Set via configure
C cget -mixin                                 # Get via cget
```

## Namespaces and Scopes

```tcl
# Top-level namespace methods
nx::Object create o1 {
    :public object method foo {} {
        return [namespace current]-[namespace which info]
    }
}
# Returns: ::-::info

# Namespaced object methods
namespace eval ::ns {
    nx::Object create o1 {
        :public object method foo {} {
            return [namespace current]-[namespace which info]
        }
    }
}
# ns::o1 foo returns: ::ns-::info

# Nested object methods
nx::Object create o
nx::Object create o::o1 {
    :public object method foo {} {
        return [namespace current]-[namespace which info]
    }
}
# o::o1 foo returns: ::o-::info
```

## Object and Class Management

```tcl
# Create instances
C create name                                # Create instance
C create name { code-block }                 # Create with initialization code
C create name -property value                # Create with property values

# Basic object operations
obj destroy                                  # Destroy object
nsf::object::exists obj                      # Check if object exists

# Copy objects/classes
obj copy target                              # Basic copy
obj COPY target                              # Deep serialization-based copy
C copy D                                     # Copy a class

# Serialization (requires nx::serializer)
package require nx::serializer
set serialized [obj serialize]               # Get object serialization
set classCode [C serialize]                  # Get class serialization
eval $serialized                             # Recreate from serialization

# Custom COPY method
nx::Object public method COPY {target} {
    set code [::Serializer deepSerialize -objmap [list [self] $target] [self]]
    eval $code
    return $target
}
```

## Special Method Handling

```tcl
# Unknown method handler
:object method unknown {method args} {
    # Handle unknown method calls
    # method contains the called method name
    # args contains the arguments
    return "unknown-$method"
}

# Method handling with special characters
:{*}[list method arg1 arg2]                  # Expands to valid method call

# Method dispatching without current object
::obj::method                                # Direct call (can fail)
::nsf::dispatch obj method                   # Force dispatch to protected method

# Call object command via eval
obj eval {
    :public object method foo {...}          # Define method in eval context
    :foo                                     # Call within eval
}
```

## XOTcl Compatibility

```tcl
# XOTcl class and object creation
package require XOTcl 2.0                    # Load XOTcl package
xotcl::Class create C
xotcl::Object create o

# XOTcl method definition
C proc classMethod {args} {
    # Class method (proc)
    return "class method"
}
C instproc instanceMethod {args} {
    # Instance method (instproc)
    return "instance method"
}

# XOTcl unknown handler
C proc unknown args {
    my incr [self proc]
    next
}

# XOTcl assertion
Edge instproc bar {} {
    my set xxx
} {} {{1 == 0}}                             # Post-condition
nsf::method::assertion obj check all        # Enable assertion checking
```

## Advanced Method Techniques

```tcl
# Method property with default
:property {b b1}                            # Property b with default b1
:object property {B B2}                     # Object property with default B2

# Method debugging
nsf::method::property C foo debug 1         # Set debug flag

# Type constraints on method parameters
:method methodName {arg:type} {
    # Type-checked parameter
}

# Ensemble methods (multi-level)
:method "outer inner" {args} {
    # Called as: obj outer inner args...
}
:method "outer inner deep" {args} {
    # Called as: obj outer inner deep args...
}

# Interceptor transparency
:method intercept args {
    # Do pre-processing
    set result [next]                      # Call intercepted method
    # Do post-processing
    return $result
}
obj filters set intercept                  # Set as filter
```

## Dispatch Rules and Error Handling

```tcl
# Protected method calls
:method protected_method {}               # Define protected method
catch {obj protected_method}              # Fails with error code 1
::nsf::dispatch obj protected_method      # Works for protected methods

# Method errors
obj non_existent_method                   # Returns "unable to dispatch method" error

# Method argument validation 
:method foo {-arg:required} {
    # Requires -arg parameter
}
# Call without required arg fails

# Call context errors
::obj::method                             # Called outside context: "no current object" error

# Invariants
:public method foo {args} {
    # Method body
} {{1 == 1}}                             # Invariant (always true)
```

## Testing Methods

```tcl
# Testing with nx::test
nx::test case case-name {
    ? {expression} expected-result        # Test expression against result
    ? {obj method} "expected result"      # Test method call result
    ? {catch {expression}} 1              # Test that expression raises error
}

# Testing object creation
? {nsf::object::exists obj} 1             # Check that object exists

# Configure test
nx::test configure -count 10              # Run test 10 times
``` 