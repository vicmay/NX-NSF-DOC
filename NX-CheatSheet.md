# NX Cheat Sheet

## Class Definition

### Basic Class Creation
```tcl
nx::Class create ClassName ?-superclass SuperClass? {
    # Class definition
}
```

### Class Options
- `-superclass`: Specify parent class(es)
- `-metaclass`: Specify metaclass
- `-mixin`: Add mixin classes
- `-filter`: Add filter methods
- `-volatile`: Make class non-persistent

## Method Definition

### Method Types
```tcl
:method name {args} {body}                    # Standard method
:public method name {args} {body}            # Public method
:protected method name {args} {body}         # Protected method
:private method name {args} {body}           # Private method
:abstract method name {args}                 # Abstract method
:forward name targetObj targetMethod         # Forward method
:alias name targetMethod                     # Alias method
```

### Method Options
```tcl
:method -returns type                        # Specify return type
:method -deprecated message                  # Mark as deprecated
:method -debug level                         # Set debug level
:method -precondition script                 # Add precondition
:method -postcondition script               # Add postcondition
:method -volatile                           # Non-persistent method
```

### Parameter Types
```tcl
:method name {
    arg1:type                               # Type constraint
    -arg2:type                              # Named parameter
    ?-arg3:type?                            # Optional parameter
    args:type,1..*                          # Variable args with multiplicity
}
```

## Property Definition

### Property Types
```tcl
:property name                              # Simple property
:property {name:type}                       # Typed property
:property {name:type default}               # Property with default
:property {name:type,constraint value}      # Property with constraint
```

### Property Options
```tcl
:property -accessor public|protected|private # Access control
:property -configurable boolean             # Allow configuration
:property -incremental boolean              # Support incremental updates
:property -trace script                     # Add trace
```

## Type System

### Built-in Types
- `integer`: Integer numbers
- `double`: Floating point numbers
- `boolean`: Boolean values
- `string`: String values
- `list`: List values
- `dict`: Dictionary values
- `object`: Object references
- `class`: Class references
- `any`: Any type

### Type Constraints
```tcl
# Basic constraints
type,nonNegative                           # Non-negative values
type,positive                              # Positive values
type,range,min..max                        # Value range
type,enum,{val1 val2 ...}                  # Enumeration
type,regexp,pattern                        # Regular expression match

# Multiplicity constraints
type,0..1                                  # Optional (0 or 1)
type,1..1                                  # Required (exactly 1)
type,0..*                                  # Any number (0 or more)
type,1..*                                  # At least 1
type,n..m                                  # Between n and m
```

## Object System

### Object Creation
```tcl
$class new ?options? ?args?                # Create new object
$class create name ?args?                 # Create named object

# Options:
-childof parent     # Parent object/namespace
-noinit            # Skip initialization
-volatile          # Create volatile object
```

### Object Methods
```tcl
$obj destroy                               # Destroy object
$obj info                                  # Get object info
$obj configure -prop val                   # Configure property
$obj cget -prop                           # Get property value
```

### Introspection Commands
```tcl
$obj info class                           # Get class
$obj info methods ?pattern?               # List methods
$obj info properties ?pattern?            # List properties
$obj info slots ?pattern?                # List slots
$obj info vars ?pattern?                 # List variables
$obj info heritage                       # List superclasses
$obj info mixins                         # List mixins
$obj info filters                        # List filters
```

## Aspect-Oriented Programming

### Filters
```tcl
:filter name                              # Add filter
:filter delete name                       # Remove filter
:public filter name {args} {body}         # Define filter
```

### Mixins
```tcl
:mixin add MixinClass                     # Add mixin
:mixin delete MixinClass                  # Remove mixin
:mixin set {Class1 Class2}                # Set mixins
```

## Error Handling

### Error Commands
```tcl
error message                             # Raise error
throw type message                        # Throw error
return -code error message               # Return error

try {
    # code
} trap type {err opts} {
    # handler
} finally {
    # cleanup
}
```

## Best Practices

### Naming Conventions
- Class names: UpperCamelCase
- Method names: lowerCamelCase
- Property names: lowerCamelCase
- Private members: _prefixWithUnderscore

### Protection Levels
- `public`: External interface
- `protected`: Inheritance interface
- `private`: Internal implementation

### Documentation
```tcl
# Class documentation
nx::Class create ClassName {
    :property {description "Class description"}
    
    # Method documentation
    :public method name {
        arg1:type                         # Arg description
        -arg2:type                        # Named arg description
    } {
        # Implementation
    }
}
```

### Testing
```tcl
package require nx::test

nx::test case TestName {
    :method setup {} {
        # Setup code
    }
    
    :method teardown {} {
        # Cleanup code
    }
    
    :method test-feature {} {
        # Test code
    }
}
```

## Common Patterns

### Singleton
```tcl
nx::Class create Singleton {
    :property instance:object,0..1
    
    :public method new {args} {
        if {![info exists :instance]} {
            set :instance [next {*}$args]
        }
        return ${:instance}
    }
}
```

### Observer
```tcl
nx::Class create Subject {
    :property observers:list
    
    :public method notify {args} {
        foreach observer ${:observers} {
            $observer update {*}$args
        }
    }
}
```

### Factory
```tcl
nx::Class create Factory {
    :public method create {type args} {
        return [${type}Class new {*}$args]
    }
}
```

## Advanced Features

### Ensemble Methods
```tcl
:public ensemble method name {
    submethod1 {args} {body}
    submethod2 {args} {body}
}

# Usage
$obj name submethod1 args
```

### Method Requirements
```tcl
:require {
    {method1 "Error if missing"}
    {method2 "Another required method"}
}
```

### Method Forwarding

#### Basic Forwarding
```tcl
# Forward to a procedure
:public forward methodName targetObject %proc

# Forward to a method
:public forward methodName targetObject %method

# Forward with frame specification
:public forward methodName -frame object someCommand
```

#### Advanced Forwarding Patterns

##### Argument Handling
```tcl
# Forward with fixed arguments
:public forward foo target %proc %self a1 a2    # Adds a1 a2 to every call

# Forward with special placeholders
:public forward foo target %proc %self %%self %%p  # %% escapes % placeholders

# Forward with argument transformation
:public forward addOne expr 1 +                 # Transforms args for expr
```

##### Prefix-Based Forwarding
```tcl
# Forward with prefix handling
:public forward Info -prefix @ InfoObject %1 %self

# Usage examples
obj Info class      # Calls InfoObject @class obj
obj Info mixin      # Calls InfoObject @mixin obj
```

##### Introspection
```tcl
# List all forwarders
obj info methods -type forwarder

# Get forwarder definition
obj info method definition methodName

# Check specific forwarders
obj info methods -type forwarder pattern*    # Pattern matching
```

##### Scoped Forwarding
```tcl
# Forward in object scope
:public forward Incr -frame object incr      # Executes in object's scope

# Property access via forwarding
:property {x 1}
:public forward incrementX -frame object incr x
```

##### Optional Target Commands
```tcl
# Forward without explicit target
:public forward append -frame object         # Uses built-in append

# Forward to namespaced commands
:public forward ::namespace::cmd             # Direct namespace forward
```

### Method Interception
```tcl
# Filter definition
:public filter name {
    # Pre-processing
    set result [next {*}$args]
    # Post-processing
    return $result
}

# Filter application
:filter add name
:filter delete name
:filter set {filter1 filter2}
```

## Object Lifecycle

### Creation
```tcl
$class new ?options? ?args?                # Create new object
$class create name ?args?                 # Create named object
::nsf::object::alloc class ?name?       # Allocate object
```

### Initialization
```tcl
:public method init {} {
    next                                  # Call parent's init
    # Initialization code
}
```

### Destruction
```tcl
:public method destroy {} {
    # Cleanup code
    next                                  # Call parent's destroy
}
```

## Method Resolution

### Method Lookup
```tcl
next                                      # Call next method in chain
self                                     # Reference to current object
my                                      # Call method on self
```

### Method Precedence
1. Per-object Mixins
2. Per-class Mixins
3. Object-specific Methods
4. Intrinsic Class Hierarchy

### Method Introspection
```tcl
$obj info method args methodName         # Get method arguments
$obj info method body methodName         # Get method body
$obj info method definition methodName   # Get full definition
$obj info method exists methodName       # Check if method exists
$obj info method handle methodName       # Get method handle
$obj info method origin methodName       # Get method origin
$obj info method parameters methodName   # Get parameter info
$obj info method syntax methodName       # Get method syntax
$obj info method type methodName         # Get method type
$obj info method submethods methodName   # Get submethods
$obj info method returns methodName      # Get return type
$obj info method callprotection methodName # Get protection level
$obj info method deprecated methodName   # Get deprecation status
$obj info method debug methodName        # Get debug status
```

## Variables and Properties

### Variable Scopes
```tcl
set localVar "value"                      # Method-scoped variable
set :instanceVar "value"                  # Instance variable
set ::globalVar "value"                   # Global variable
```

### Property Features
```tcl
:property name:required                    # Required property
:property {name:type default}             # Typed property with default
:property {name:type,constraint value}    # Property with constraint
:property -accessor public|protected|private # Access control
:property -configurable boolean           # Allow configuration
:property -incremental boolean            # Support incremental updates
:property -trace script                   # Add trace
```

### Property Access
```tcl
$obj cget -propertyname                   # Get property value
$obj configure -propertyname value        # Set property value
```

## Object Variables and Properties

### Object Variable Command
```tcl
$obj object variable ?options? spec ?defaultValue?

# Options:
-accessor value        # Access level (none|public|protected|private)
-class className      # Variable class
-configurable bool   # Make configurable
-incremental        # Enable incremental operations
-initblock script  # Initialization block
-nocomplain       # Don't complain about existing variables
-trace ops       # Trace operations
```

### Object Property Command
```tcl
$obj object property ?options? spec ?initblock?

# Options:
-accessor value        # Access level (public|protected|private)
-class className      # Property class
-configurable bool   # Make configurable (default: true)
-incremental        # Enable incremental operations
-nocomplain       # Don't complain about existing properties
-trace ops       # Trace operations
```

## Configuration and Utilities

### NX Configuration
```tcl
::nx::configure defaultMethodCallProtection ?value?    # Get/set default method protection
::nx::configure defaultAccessor ?value?               # Get/set default accessor

# Default Method Protection
true                    # Methods are protected by default
false                  # Methods are public by default

# Default Accessor Values
public                # Public access
protected           # Protected access
private            # Private access
none              # No accessor
```

### Method Properties
```tcl
::nsf::method::property class method property value     # Set method property
::nsf::method::property class -per-object method prop value  # Set object method property

# Common Properties
call-protected          # Protected method
call-private           # Private method
class-only            # Class-only method
returns              # Return type
```

### Method Assertions
```tcl
::nsf::method::assertion obj check script          # Set check assertion
::nsf::method::assertion obj class-invar script   # Set class invariant
::nsf::method::assertion obj object-invar script # Set object invariant
```

## Variable Access Commands

### Variable Ensemble
```tcl
::nx::var exists obj var          # Check if variable exists
::nx::var get obj var           # Get variable value
::nx::var import obj var       # Import variable
::nx::var set obj var value  # Set variable value
```

### Parameter Syntax
```tcl
# Mixin Operations
add class                # Add mixin class
classes ?pattern?       # List mixin classes
clear                  # Clear all mixins
delete class          # Delete mixin class
get                  # Get mixins
guard class ?expr?  # Set mixin guard
set classes        # Set mixins

# Filter Operations
add filter                # Add filter
clear                   # Clear all filters
delete filter          # Delete filter
get                   # Get filters
guard filter ?expr?  # Set filter guard
methods ?pattern?   # List filter methods
set filters        # Set filters
```

### System Configuration
```tcl
::nx::confdir           # Configuration directory (~/.nx)
::nx::logdir           # Log directory (~/.nx/log)
::nsf::configure debug level  # Set debug level (0-2)
```

### Exported Commands
```tcl
::nx::Object          # Base object class
::nx::Class          # Base class class
::nx::next          # Call next method
::nx::self         # Get current object
::nx::current     # Get current context
```

## Namespace and Object Containment

### Contains Method
```tcl
$obj contains {script}                     # Execute script in object's namespace
:contains {script}                         # Execute script in current object's namespace

# Example:
nx::Object create parent -contains {
    nx::Object create child               # Creates child in parent's namespace
    ? {self}                             # Returns ::parent
    ? {namespace current}                # Returns ::parent
}
```

### Namespace Context
```tcl
self                                      # Get current object
namespace current                         # Get current namespace
namespace path                           # Get/set namespace path

# Example:
nx::Class create MyClass {
    :public method getContext {} {
        return "[self]-[namespace current]"
    }
}
```

### Error Handling in Contains
```tcl
# Error propagation from contains block
catch {
    $obj contains {
        return -code error -errorcode MYERR "Error message"
    }
} msg opts

# Error info preservation
dict get $opts -errorcode               # Get error code
dict get $opts -errorinfo              # Get error stack trace
```

### Object System Restrictions
```tcl
# Cannot mix object systems in class hierarchy
::nx::Class create C1 -superclass ::nx::Object     # Valid
::xotcl::Class create C0 -superclass ::nx::Object  # Invalid - different object systems
```

## Object Destruction and Cleanup

### Destroy Method Patterns
```tcl
# Basic destruction
:method destroy {} {
    # Cleanup code
    next                                  # Call parent's destroy
}

# Blocking destruction (object survives)
:method destroy {} {
    # Cleanup code only
    # Not calling next prevents object deletion
}

# Destruction with verification
:method destroy {} {
    # Pre-destroy checks
    if {[some_condition]} {
        next                             # Allow destruction
    }
    # Object survives if next not called
}
```

### Object Recreation
```tcl
# Recreate object with same name
[:info class] create [self]              # Recreate current object
```

### Command Handling
```tcl
# Rename object command
rename $obj ""                           # Triggers destroy method
rename $obj newname                      # Renames object command

# Object existence check
::nsf::object::exists $obj              # Check if object exists
```

### Cleanup Patterns
```tcl
:method init {} {
    # Initialize cleanup flags/state
}

:method destroy {} {
    # Cleanup resources
    my cleanup_resources
    
    # Notify observers
    my notify_destruction
    
    # Final cleanup
    next
}

# Access during destruction
:method someMethod {} {
    :destroy                            # Start destruction
    # Object still accessible here
    :set x 1                           # Still works
    # Object fully destroyed after method ends
}

### Advanced Argument Positioning
```tcl
# Position-based argument insertion
:public forward endArg list {%@end value}     # Add at end
:public forward firstArg list {%@1 value}     # Add at beginning
:public forward midArg list {%@2 value}       # Add at position 2
:public forward beforeLastArg list {%@-1 value} # Add before last

# Multiple positional arguments
:public forward complexArg list {%@2 two} {%@1 one} {%@0 list}
# Result: list one two ...rest of args...

# Combining with other substitutions
:public forward mixed list {%@end last} %1 %self
# Result: list arg1 objName arg2 arg3 last

# Expression evaluation
:public forward calc expr {%:eval {set :x}} *  # Evaluates x value
```

### Forwarding Best Practices
```tcl
# Namespace-aware forwarding
:public forward ::ns::cmd                     # Forward to namespaced command
:public forward cmd ::ns::target %method      # Forward to namespaced target

# Method prefix handling
:public forward Info -prefix @ InfoObj %1 %self
# Creates methods: Info class, Info mixin, etc.

# Frame control
:public forward increment -frame object incr x # Execute in object scope
:public forward eval -objframe 1 eval         # Execute in object frame
```

### Error Handling in Forwards
```tcl
# Guard conditions
:public forward name target %method -guard {expr}

# Target validation
:public forward cmd target
if {![info exists target]} {
    error "Target not available"
}

# Method existence check
:public forward name target %method
if {![target info methods name]} {
    error "Method not found"
}
```

## Method Definition Patterns

### Method Naming Rules
```tcl
# Valid method names
:method validName {}                  # Simple name
:method valid_name {}                 # With underscore
:method valid123 {}                   # With numbers
:method {#special} {}                 # Special prefix

# Invalid method names
# - Empty names
# - Names with whitespace
# - Names with tabs, newlines, or special chars
# - Names starting with colon in non-global namespace
```

### Method Types and Visibility
```tcl
# Basic method types
:method plain_method {} {
    return [current method]
}

:public method public_method {} {
    return [current method]
}

:protected method protected_method {} {
    return [current method]
}

# Object methods (class-level)
:object method class_method {} {
    return [current method]
}

:public object method public_class_method {} {
    return [current method]
}
```

### Method Registration and Aliases
```tcl
# Method registration handle
set handle [C info method registrationhandle methodName]

# Method aliases
:alias plain_alias $handle
:public alias public_alias $handle
:protected alias protected_alias $handle

# Method forwarding
:forward plain_forward %self otherMethod
:public forward public_forward %self otherMethod
:protected forward protected_forward %self otherMethod
```

### Property Methods
```tcl
# Property with default accessor
:property plain_property

# Property with visibility-controlled accessor
:property -accessor public public_property
:property -accessor protected protected_property

# Custom property methods
:property myProp {
    :public method get {} {
        return ${:myProp}
    }
    :protected method set {value} {
        set :myProp $value
    }
}
```

### Method Introspection
```tcl
# List methods
obj info methods                      # All methods
obj info methods -type method         # Only direct methods
obj info methods -type forward        # Only forwards
obj info methods -type alias          # Only aliases

# Method properties
obj info method definition methodName # Get method definition
obj info method args methodName       # Get method arguments
obj info method body methodName       # Get method body
obj info method protection methodName # Get protection level
```

### Best Practices
```tcl
# Method documentation
:public method documented {arg1 arg2} {
    # Method description
    # @param arg1 Description of arg1
    # @param arg2 Description of arg2
    # @return Description of return value
}

# Method parameter validation
:public method validated {args} {
    if {![llength $args]} {
        error "No arguments provided"
    }
    # Method body
}

# Method error handling
:public method withErrors {} {
    try {
        # Risky operation
    } on error {msg opts} {
        # Error handling
        return -code error $msg
    }
}
```

## Method Protection and Visibility

### Basic Protection Levels
```tcl
# Method visibility levels
:public method publicMethod {} {
    return [current method]
}

:protected method protectedMethod {} {
    return [current method]
}

:private method privateMethod {} {
    return [current method]
}

# Property visibility
:property -accessor public publicProp
:property -accessor protected protectedProp
:property -accessor private privateProp
```

### Call Protection
```tcl
# Set call protection
::nsf::method::property Class methodName call-protected true

# Unset call protection
::nsf::method::property Class methodName call-protected false

# Check protection status
::nsf::method::property Class methodName call-protected

# Protected dispatch
nx::dispatch obj protectedMethod args  # Call protected method
```

### Internal Access
```tcl
# Internal method calls (allowed)
:public method caller {} {
    my protectedMethod              # Access protected method
    my privateMethod                # Access private method
}

# Cross-instance calls
:public method crossCall {otherObj} {
    $otherObj protectedMethod       # Allowed within same class
    $otherObj publicMethod          # Always allowed
}
```

### Filter and Mixin Protection
```tcl
# Protected filters
:method filter args { next }        # Protected filter
:private method filter args { next } # Private filter
obj object filters add filter       # Add filter

# Protected mixins
:protected method mixin {} {
    # Mixin implementation
}
Class create obj {
    :public object mixins add Mixin # Add mixin
}
```

### Best Practices
```tcl
# Encapsulation pattern
:private method internal {} {
    # Internal implementation
}

:public method interface {} {
    my internal                     # Use internal method
}

# Protected factory pattern
:protected method create_impl {type} {
    # Implementation details
}

:public method create {type} {
    my create_impl $type           # Use protected factory
}

# Visibility inheritance
:public method parent {} {
    next                           # Call parent's public method
}

:protected method child {} {
    next                           # Call parent's protected method
}
```

### Error Handling
```tcl
# Protected method error
if {[catch {obj protectedMethod} err]} {
    # Handle protection error
    puts "Access denied: $err"
}

# Safe dispatch
if {[::nsf::method::property Class method call-protected]} {
    nx::dispatch obj method args   # Use safe dispatch
} else {
    obj method args               # Direct call
}
```

## Property Patterns

### Basic Property Definition
```tcl
# Simple property
:property {name value}                # Property with default value

# Property with accessor
:property -accessor public {prop val} # Public accessor
:property -accessor protected {prop val} # Protected accessor
:property -accessor private {prop val} # Private accessor
:property -accessor none {prop val}   # No accessor

# Variable properties
:variable var value                   # Simple variable
:variable -accessor public var value  # Public variable
```

### Property Configuration
```tcl
# Configurable properties
:property -configurable true {prop val}  # Can be configured
:property -configurable false {prop val} # Fixed value (like variable)

# Property initialization
:property {name "default"}            # String default
:property {count 0}                   # Numeric default
:property {active:boolean true}       # Typed with default

# Property options
:property -incremental {prop val}     # Incremental updates
:property -trace {prop val}           # Add trace handler
:property -class {prop val}           # Class-level property
```

### Property Access
```tcl
# Direct access
obj cget -propName                    # Get property value
obj configure -propName value         # Set property value

# Accessor methods
obj propName                          # Get value (if public)
obj propName value                    # Set value (if public)

# Protected access
:public method wrapper {} {
    my protectedProp                  # Access protected property
}
```

### Property Introspection
```tcl
# Property information
obj info lookup syntax configure      # List configurable properties
obj info slots                        # List all slots
obj info lookup method propName       # Get accessor method

# Property definition
::Class::slot::propName definition    # Get property definition

# Property protection
nsf::method::property Class prop call-protected  # Check protection
```

### Property Patterns
```tcl
# Computed property
:property {computed} {
    :public method get {} {
        # Compute value
        return $result
    }
}

# Validated property
:property {validated} {
    :public method set {value} {
        if {![valid $value]} {
            error "Invalid value"
        }
        set :validated $value
    }
}

# Observable property
:property {observed} {
    :public method set {value} {
        set old ${:observed}
        set :observed $value
        my notify $old $value
    }
}
```

### Best Practices
```tcl
# Property documentation
:property {
    name:string                       # Property type
    -configurable true                # Configuration
    -accessor public                  # Access level
} {
    # Default value
}

# Property validation
:property {port:integer,1024..65535 8080}

# Property dependencies
:property {derived} {
    :public method get {} {
        expr {${:prop1} + ${:prop2}}
    }
}

# Property initialization
:public method init {} {
    next                             # Call parent init
    set :prop [compute_initial_value]
}
```

## Submethod Patterns

### Basic Submethod Definition
```tcl
# Simple submethods
:method "parent child" {} {
    return [current method]
}

# Nested submethods
:method "parent child grandchild" {} {
    return [current method]
}

# Object submethods
:object method "cmd subcmd" {} {
    return [current method]
}
```

### Submethod Parameters
```tcl
# Parameter validation
:method "cmd subcmd" {
    arg:integer                       # Type validation
    -flag:boolean                     # Optional flag
} {
    # Implementation
}

# Complex parameters
:method "api call" {
    x:integer                         # Required integer
    -y:boolean                        # Optional boolean
    args                             # Additional args
} {
    # Implementation
}
```

### Submethod Dispatch
```tcl
# Basic dispatch
obj parent child                      # Call submethod

# Nested dispatch
obj parent child grandchild           # Call nested submethod

# Error handling
if {[catch {obj cmd unknown} err]} {
    # Handle unknown submethod
}
```

### Submethod Patterns
```tcl
# Command group pattern
:object method "string length" {str} {
    string length $str
}
:object method "string tolower" {str} {
    string tolower $str
}
:object method "string info" {str} {
    return [string is $str]
}

# Default method
:object method "cmd defaultmethod" {args} {
    # Handle unknown submethods
}

# Unknown handler
:object method "cmd unknown" {args} {
    # Handle unknown submethods
    return [current method]
}
```

### Submethod Introspection
```tcl
# List submethods
obj cmd                              # Shows valid submethods

# Submethod validation
if {[obj info methods "cmd subcmd"]} {
    # Submethod exists
}

# Error messages
obj invalidCmd                       # Shows valid submethods
obj cmd invalidSubcmd               # Shows valid subcmds
```

### Best Practices
```tcl
# Submethod organization
:method "api get user" {id} {
    # Get user
}
:method "api get group" {id} {
    # Get group
}
:method "api create user" {data} {
    # Create user
}

# Validation pattern
:method "validate input" {data} {
    # Input validation
}
:method "validate output" {data} {
    # Output validation
}

# Operation grouping
:method "db connect" {args} {
    # DB connection
}
:method "db query" {sql} {
    # DB query
}
:method "db disconnect" {} {
    # DB disconnect
}
```

### Error Handling
```tcl
# Custom error messages
:method "cmd subcmd" {args} {
    if {![valid $args]} {
        error "Invalid arguments for cmd subcmd"
    }
}

# Submethod not found
:method "cmd unknown" {subcmd args} {
    error "Unknown subcmd '$subcmd' for cmd"
}

# Parameter validation
:method "api call" {
    -required:required                # Must be provided
    -optional                        # Optional parameter
} {
    # Implementation
}
```

## Method Introspection

### Basic Method Information
```tcl
# List methods
obj info methods                      # All methods
obj info methods -callprotection all  # All methods with protection
obj info methods pattern*             # Pattern matching

# Method lookup
obj info lookup method methodName     # Get method handle
obj info lookup methods methodName    # Get all matching methods

# Method definition
obj info method definition methodName # Get method definition
obj info method args methodName       # Get method arguments
obj info method body methodName       # Get method body
```

### Method Types
```tcl
# Filter by method type
obj info methods -type method         # Direct methods
obj info methods -type forward        # Forward methods
obj info methods -type alias          # Alias methods
obj info methods -type property       # Property methods

# Object methods
obj info object methods              # Object-specific methods
obj info object method definition name # Get object method def
```

### Method Protection
```tcl
# Protection information
obj info methods -callprotection all  # Show all protection levels
nsf::method::property Class method call-protected # Check protection

# Protection filtering
obj info methods -protection public   # Public methods
obj info methods -protection protected # Protected methods
obj info methods -protection private  # Private methods
```

### Method Inheritance
```tcl
# Superclass methods
Class info superclasses              # Direct superclasses
Class info superclasses -closure     # All superclasses

# Method inheritance
obj info lookup method name          # Find inherited method
obj info precedence                  # Method resolution order

# Pattern matching
Class info superclasses ::pattern*   # Qualified pattern
Class info superclasses pattern*     # Unqualified pattern
```

### Method Components
```tcl
# Method details
obj info method args methodName      # Parameter list
obj info method body methodName      # Method body
obj info method definition methodName # Full definition

# Method properties
obj info method protection methodName # Protection level
obj info method type methodName      # Method type
```

### Advanced Introspection
```tcl
# Method registration
obj info method registrationhandle name # Get handle

# Method existence
if {[obj info methods methodName] ne ""} {
    # Method exists
}

# Method origin
obj info method origin methodName    # Where method is defined

# Method filters
obj info filters                     # List filters
obj info method filters methodName   # Method-specific filters
```

### Best Practices
```tcl
# Safe method calling
if {[obj info lookup method name] ne ""} {
    obj name args                    # Call if exists
}

# Method documentation
:public method documented {} {
    set def [my info method definition [current method]]
    return $def
}

# Method analysis
:public method analyze {methodName} {
    set args [my info method args $methodName]
    set body [my info method body $methodName]
    set prot [my info method protection $methodName]
    # Analysis code
}

# Dynamic method handling
:public method handle {name args} {
    if {[my info methods $name] ne ""} {
        my $name {*}$args
    } else {
        error "Unknown method: $name"
    }
}
```

## Method Patterns

### Method Definition Patterns
```tcl
# Basic method types
:method name {args} {body}                    # Standard method
:public method name {args} {body}            # Public method
:protected method name {args} {body}         # Protected method
:private method name {args} {body}           # Private method

# Special method types
:abstract method name {args}                 # Abstract method
:forward name targetObj targetMethod         # Forward method
:alias name methodHandle                     # Alias method

# Method options
:method -returns type name {args} {body}     # Specify return type
:method -deprecated msg name {args} {body}   # Mark as deprecated
:method -debug level name {args} {body}      # Set debug level
```

### Method Protection and Visibility
```tcl
# Protection levels
:public method name {} {body}                # Accessible by anyone
:protected method name {} {body}             # Accessible by class and subclasses
:private method name {} {body}               # Only accessible within class

# Dispatch based on protection
obj method                                   # Call public method
::nsf::dispatch obj protectedMethod          # Call protected method
```

### Method Patterns with Self
```tcl
# Self-referential patterns
:method name {} {
    [self]                                   # Get current object
    [current method]                         # Get current method name
    [current args]                           # Get current arguments
    [current object]                         # Get current object
}

# Method chaining
:method chain {} {
    [self] method1                          # Chain method1
    [self] method2                          # Chain method2
}
```

### Ensemble (Subcommand) Methods
```tcl
# First-level subcommands
:method "Info filter" {args} {body}          # First-level ensemble
:method "Info methods" {args} {body}         # Another first-level

# Multi-level subcommands
:method "Info filter guard" {args} {body}    # Second-level ensemble
:method "Info filter methods" {args} {body}  # Another second-level

# Object-specific ensembles
:object method "list length" {} {body}       # Object ensemble
:object method "list reverse" {} {body}      # Another object ensemble
```

### Method Copying and Moving
```tcl
# Copy methods
::nsf::method::copy srcObj srcMethod destObj destMethod

# Move methods
::nsf::method::move srcObj srcMethod destObj destMethod

# Delete methods
::nsf::method::delete Class methodName           # Delete instance method
::nsf::method::delete Class -per-object methodName # Delete object method
```

### Unknown Method Handling
```tcl
# Basic unknown handler
:object method unknown {args} {
    # Handle unknown method
    return "unknown-$args"
}

# Pattern-based unknown
:object method unknown {methodName args} {
    switch -glob $methodName {
        "pattern1*" { # Handle pattern1 }
        "pattern2*" { # Handle pattern2 }
        default { error "Unknown method: $methodName" }
    }
}
```

### Method Assertions and Validation
```tcl
# Method assertions
:method name {} {body} {} {{condition}}      # Add postcondition
:method name {} {
    if {![precondition]} { error "Failed" }  # Add precondition
    body
}

# Enable assertions
nsf::method::assertion obj check all         # Enable all checks
nsf::method::assertion obj class-invar script # Class invariant
nsf::method::assertion obj object-invar script # Object invariant
```

### Method Interception
```tcl
# Filter definition
:public filter name {
    # Pre-processing
    set result [next {*}$args]               # Call next method
    # Post-processing
    return $result
}

# Mixin interception
:public method name {} {
    # Pre-processing
    set result [next]                        # Call next method
    # Post-processing
    return $result
}
```

### Method Properties and Debug
```tcl
# Set method properties
::nsf::method::property class method property value

# Common properties
call-protected          # Mark method as protected
call-private           # Mark method as private
class-only            # Class-only method
returns              # Return type constraint

# Debug and deprecation
:method -debug 1 name {} {body}            # Enable debugging
:method -deprecated "Use newMethod" name {} {body}  # Mark deprecated
```

### Best Practices
```tcl
# Method naming
:method lowerCamelCase {} {body}           # Instance methods
:method _prefixPrivate {} {body}           # Private methods
:method "Namespace Command" {} {body}       # Ensemble methods

# Documentation
:method name {
    arg1:type                              # Type constraint
    -arg2:type                             # Named parameter
    ?-arg3:type?                           # Optional parameter
} {
    # Method documentation
    body
}

# Error handling
:method name {} {
    if {[catch {operation} result]} {
        error "Operation failed: $result"
    }
    return $result
}
```

## Parameter Patterns

### Basic Parameter Types
```tcl
# Property parameters
:property name                              # Simple property
:property {name:type}                       # Typed property
:property {name:type default}               # Property with default
:property name:required                     # Required property

# Method parameters
:method name {
    arg1                                    # Required parameter
    arg2:optional                           # Optional parameter
    arg3:required                           # Required parameter
    args                                    # Variable arguments
}

# Type constraints
:property {name:integer}                    # Integer property
:property {name:boolean}                    # Boolean property
:property {name:double}                     # Double property
:property {name:string}                     # String property
:property {name:object}                     # Object reference
:property {name:class}                      # Class reference
:property {name:metaclass}                  # Metaclass reference
:property {name:baseclass}                  # Base class reference
```

### Parameter Multiplicity
```tcl
# Single values
:property name:type                         # Single value

# Multiple values
:property name:type,0..n                    # Zero or more values
:property name:type,1..n                    # One or more values
:property name:type,0..1                    # Optional single value
:property name:type,1..1                    # Required single value
:property name:type,n..m                    # Between n and m values

# Method parameter multiplicity
:method name {
    args:type,0..n                         # Variable number of typed args
    values:integer,1..*                    # One or more integers
    objects:object,0..*                    # Zero or more objects
}
```

### Parameter Validation
```tcl
# Type validation
:property {name:integer,nonNegative}        # Non-negative integer
:property {name:string,nonempty}            # Non-empty string
:property {name:object,type=ClassName}      # Object of specific type

# Custom validation
:method validate {value} {
    if {![valid $value]} {
        error "Invalid value: $value"
    }
    return $value
}

# Parameter checking
:method name {param:type} {
    if {![::nsf::is $type $param]} {
        error "Invalid parameter type"
    }
}

# Value constraints
:property {name:integer,min=0,max=100}      # Integer range
:property {name:string,regexp=pattern}      # String pattern match
:property {name:enum=red,green,blue}        # Enumeration
```

### Parameter Configuration
```tcl
# Property configuration
:property -accessor public name             # Public accessor
:property -accessor protected name          # Protected accessor
:property -configurable boolean name        # Configurable property
:property -incremental boolean name         # Incremental updates

# Method parameter configuration
:method name {
    -param:required                         # Required named parameter
    -flag:boolean                          # Boolean flag parameter
    -value:type,default                    # Parameter with default
}

# Switch parameters
:property foo:switch                        # Switch property (default false)
:property {foo:switch 1}                    # Switch property (default true)
```

### Parameter Inheritance
```tcl
# Class inheritance
:property {name:type}                       # Base class property
:method name {param:type} {body}           # Base class method

# Mixin parameters
Class mixins set {
    Mixin1                                 # Add mixin parameters
    {Mixin2 -param value}                  # Mixin with parameters
}

# Parameter precedence
:property {name:type}                      # Class property
:object property {name:type}               # Object property (overrides)
```

### Parameter Patterns with Self
```tcl
# Self-referential patterns
:property {name:substdefault "[current]"}   # Current object
:property {name:substdefault "[:info class]"} # Current class
:property {name:substdefault "[:cget -prop]"} # Property value

# Parameter initialization
:method init {} {
    next                                   # Call parent init
    set :param [compute_initial_value]     # Initialize parameter
}
```

### Best Practices
```tcl
# Parameter naming
:property lowerCamelCase                     # Property names
:property _privateProp                       # Private properties
:property publicProp                         # Public properties

# Documentation
:property {name:type "doc"}                  # Document type
:property {count:integer "Item count"}       # Document purpose
:property {-flag:boolean "Enable feature"}   # Document flag

# Validation
:property {value:integer,positive}           # Enforce positive integers
:property {name:string,nonempty}             # Enforce non-empty strings
:property {type:enum=a,b,c}                 # Enforce valid options
```

### Advanced Parameter Features
```tcl
# Parameter aliases
:property {name:alias}                      # Simple alias
:property {name:alias,method=methodName}    # Method alias

# Parameter forwarding
:property {name:forward,method=%self method %1} # Forward to method

# Parameter tracing
:property -trace set name {                 # Trace property changes
    :public object method value=set {obj var val} {
        # Handle value change
    }
}

# Parameter cache operations
::nsf::parameter::cache::classinvalidate class    # Invalidate class cache
::nsf::parameter::cache::objectinvalidate obj     # Invalidate object cache
```

### Advanced Parameter Types
```tcl
# Switch parameters
:property foo:switch                        # Switch property (default false)
:property {foo:switch 1}                    # Switch property (default true)

# Object type parameters with namespace binding
:property obj:object,type=ClassName         # Unqualified name (binds to current ns)
:property obj:object,type=::ns::Class      # Fully qualified name
:property obj:object,type=ns::Class        # Relative namespace path

# Parameter value checking
:property count:integer,nonNegative         # Non-negative integer
:property name:string,nonempty              # Non-empty string
:property level:integer,0..10               # Integer range
:property type:enum=red,green,blue          # Enumeration
```

### Parameter Value Handling
```tcl
# Value changed handlers
:property prop {
    :public object method value=set {obj var value} {
        # Handle value change
        ::nsf::var::set -notrace $obj $var [expr {$value + 1}]
    }
}

# Value trace handlers
:property -trace set prop {
    :public object method value=set {obj var value} {
        # Handle value change with trace
        ::nsf::var::set $obj $var $value
    }
}

# Value initialization
:property prop {
    :public object method initialize {obj var} {
        # Initialize property
        set :initCount 1
    }
}
```

### Parameter Validation and Type Checking
```tcl
# Type validation with constraints
:property {port:integer,1024..65535 8080}   # Port number with range
:property {list:string,nonempty ""}         # Non-empty string list
:property {obj:object,type=::C}             # Object with specific type

# Custom validation
:property prop {
    :public object method value=set {obj var value} {
        if {![valid $value]} {
            error "Invalid value: $value"
        }
        ::nsf::var::set $obj $var $value
    }
}

# Parameter checking
:method validate {value:type} {
    if {![::nsf::is $type $value]} {
        error "Invalid parameter type"
    }
}
```

### Parameter Configuration and Defaults
```tcl
# Default value handling
:property {name:substdefault "[self]"}       # Self-referential default
:property {path:substdefault "[pwd]"}        # Command substitution default

# Parameter configuration
:property -configurable true prop            # Allow runtime configuration
:property -configurable false prop           # Fixed value (like variable)
:property -incremental prop                  # Support incremental updates
:property -trace {get set} prop             # Add get/set traces
```

### Parameter Inheritance and Scope
```tcl
# Class-level parameters
:object property {name value}                # Class property
:object property -accessor public prop       # Public class property

# Instance-level parameters
:property {name value}                       # Instance property
:property -accessor protected prop           # Protected instance property

# Parameter precedence
:property prop                               # Base definition
:object property prop                        # Override in object
```

### Parameter Error Handling
```tcl
# Error propagation
:property prop {
    :public object method value=set {obj var value} {
        if {[catch {validate $value} err]} {
            error "Validation failed: $err"
        }
        next
    }
}

# Type error messages
:property obj:object,type=::C                # "expected object of type ::C"
:property count:integer                      # "expected integer but got..."
:property name:required                      # "required parameter not given"
```

### Best Practices
```tcl
# Parameter naming
:property lowerCamelCase                     # Property names
:property _privateProp                       # Private properties
:property publicProp                         # Public properties

# Documentation
:property {name:type "doc"}                  # Document type
:property {count:integer "Item count"}       # Document purpose
:property {-flag:boolean "Enable feature"}   # Document flag

# Validation
:property {value:integer,positive}           # Enforce positive integers
:property {name:string,nonempty}             # Enforce non-empty strings
:property {type:enum=a,b,c}                 # Enforce valid options
``` 