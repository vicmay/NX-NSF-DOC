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

## Slot Definition

### Slot Types
```tcl
::nx::Slot                    # Base slot type
::nx::ObjectParameterSlot     # Object parameter slot
::nx::MethodParameterSlot     # Method parameter slot
::nx::VariableSlot           # Variable slot
```

### Slot Properties
```tcl
-type type                   # Slot type (built-in or class)
-arg argument               # Argument specification
-multiplicity range         # Multiplicity constraint (e.g. "0..1", "1..n")
-required boolean          # Whether value is required
-convert boolean          # Enable value conversion
-noarg boolean           # No argument flag
-nodashalnum boolean    # No dash-alphanumeric flag
-configurable boolean   # Configurable flag
-incremental boolean   # Incremental flag
-substdefault pattern  # Subst default pattern (0b111 for all)
-methodname name      # Associated method name
-disposition type    # Slot disposition (alias|forward|cmd|initcmd)
-per-object boolean # Per-object flag
-private boolean   # Private slot flag
```

### Parameter Specification Format
```tcl
name                        # Simple parameter
name:required              # Required parameter
name:type=type            # Parameter with type
name:arg=arg             # Parameter with argument spec
name:0..1                # Optional parameter (0 or 1)
name:1..n               # Multiple required values (1 or more)
name:0..n              # Multiple optional values (0 or more)
name:convert          # Enable value conversion
name:noarg           # No argument parameter
name:nodashalnum    # No dash-alphanumeric parameter
name:method=method  # Parameter with associated method
name:substdefault  # Enable subst on default value
name:alias        # Alias parameter
name:forward     # Forward parameter
name:cmd        # Command parameter
name:initcmd   # Init command parameter
```

### Slot Operations
```tcl
::nx::slotObj -container type object name    # Create slot object
::nsf::var::set slot property value         # Set slot property
::nsf::method::setter class slotName       # Register standard setter
::nsf::method::property class slot property value  # Set slot method property
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
::nsf::object::alloc class ?name?       # Allocate object

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

## Meta-Programming

### Method Manipulation
```tcl
::nsf::method::create                     # Create method
::nsf::method::delete                     # Delete method
::nsf::method::copy                       # Copy method
::nsf::method::move                       # Move method
::nsf::method::property                   # Set method property
```

### Class Manipulation
```tcl
::nsf::class::create                      # Create class
::nsf::class::delete                      # Delete class
::nsf::class::property                    # Set class property
```

### Type System Extension
```tcl
::nsf::type::create typename {
    -validate {value} {script}            # Validation
    -validatearg {args} {script}          # Argument validation
    -convert {value} {script}             # Value conversion
}
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

## Utility Commands

### Object Utilities
```tcl
::nsf::object::exists obj                 # Check existence
::nsf::object::properties obj             # Get properties
::nsf::object::vars obj                   # Get variables
```

### Class Utilities
```tcl
::nsf::class::methods class              # Get methods
::nsf::class::slots class                # Get slots
::nsf::class::properties class           # Get properties
```

### System Utilities
```tcl
::nsf::configure option value            # Configure NSF
::nsf::debug level                       # Set debug level
::nsf::log level message                # Log message
```

## Best Practices

### Naming Conventions
- Class names: UpperCamelCase
- Method names: lowerCamelCase
- Property names: lowerCamelCase
- Slot names: lowerCamelCase
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
```tcl
# Basic forwarding
:forward name targetObj targetMethod

# Forwarding with argument mapping
:forward name targetObj targetMethod \
    -prefix prefix \
    -suffix suffix \
    -frame frame \
    -objframe boolean

# Conditional forwarding
:forward name targetObj targetMethod \
    -guard condition
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

## Slot Advanced Features

### Slot Inheritance
```tcl
:slot name {
    :superclass slot                      # Inherit from superclass slot
    :override {                           # Override specific aspects
        :getter {script}
        :setter {value} {script}
    }
}
```

### Slot Composition
```tcl
:slot name {
    :composite true                       # Composite slot
    :multiplicity 0..*                    # Container multiplicity
    :type ComponentClass                  # Component type
    :relationship aggregation|composition # Relationship type
}
```

### Slot Persistence
```tcl
:slot name {
    :persistent true                      # Make slot persistent
    :serialize {
        :store {script}                   # Custom serialization
        :load {script}                    # Custom deserialization
    }
}
```

## Introspection Commands

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

### Object Method Introspection
```tcl
$obj info object method args name        # Get object method arguments
$obj info object method body name        # Get object method body
$obj info object method definition name  # Get object method definition
$obj info object method exists name      # Check if object method exists
$obj info object method handle name      # Get object method handle
$obj info object method origin name      # Get object method origin
$obj info object method parameters name  # Get object method parameters
$obj info object method syntax name      # Get object method syntax
$obj info object method type name        # Get object method type
$obj info object method submethods name  # Get object method submethods
$obj info object method returns name     # Get object method return type
```

### Lookup Commands
```tcl
$obj info lookup filter pattern          # Find filter
$obj info lookup filters pattern         # Find filters
$obj info lookup method name            # Find method
$obj info lookup methods pattern        # Find methods
$obj info lookup mixins pattern         # Find mixins
$obj info lookup slots ?-type type? pattern # Find slots
$obj info lookup parameters methodName   # Find method parameters
$obj info lookup syntax methodName      # Get method syntax
$obj info lookup variables pattern      # Find variables
```

### Object Information
```tcl
$obj info baseclass                     # Get base class
$obj info children                      # Get child objects
$obj info class                         # Get class
$obj info has mixin mixinName          # Check mixin
$obj info has namespace                 # Check namespace
$obj info has type typeName            # Check type
$obj info name                         # Get object name
$obj info parent                       # Get parent object
$obj info precedence                   # Get method precedence
$obj info vars                         # Get variables
```

### Property Introspection
```tcl
$obj info property definition name       # Get property definition
$obj info property options name          # Get property options
$obj info property type name            # Get property type
$obj info property default name         # Get default value
$obj info property accessor name        # Get accessor type
```

### Slot Introspection
```tcl
$obj info slot definition name          # Get slot definition
$obj info slot options name            # Get slot options
$obj info slot type name               # Get slot type
$obj info slot multiplicity name       # Get multiplicity
$obj info slot constraint name         # Get constraints
$obj info slot handlers name           # Get handlers
```

## NSF System Commands

### Procedure Definition
```tcl
::nsf::proc ?-ad? ?-checkalways? ?-debug? ?-deprecated? procName arguments body
```
Options:
- `-ad`: Enable argument dispatch
- `-checkalways`: Always check arguments
- `-debug`: Enable debug mode for the proc
- `-deprecated`: Mark proc as deprecated

### Method Definition Commands
```tcl
::nsf::method::create object methodName arguments body  # Create method
::nsf::method::delete object methodName                # Delete method
::nsf::method::copy srcObj srcMethod destObj destMethod  # Copy method
::nsf::method::move srcObj srcMethod destObj destMethod  # Move method
::nsf::method::property object methodName property value # Set method property
::nsf::method::require object methodName isPerObject    # Require method
```

### Method Properties
```tcl
::nsf::method::property object method call-protected boolean  # Protection level
::nsf::method::property object method call-private boolean   # Private access
::nsf::method::property object method debug boolean         # Debug mode
::nsf::method::property object method deprecated message    # Deprecation
::nsf::method::property object method returns type         # Return type
```

### Object System Commands
```tcl
::nsf::objectsystem::create name classCmd {options}    # Create object system
::nsf::object::exists object                          # Check existence
::nsf::object::property object property value         # Set object property
```

### Configuration and Debug
```tcl
::nsf::configure option value                         # Configure NSF
::nsf::debug level                                    # Set debug level
::nsf::log level message                             # Log message
```

### Namespace Management
```tcl
::nsf::directdispatch object cmd args                # Direct method dispatch
::nsf::dispatch object method args                   # Method dispatch
::nsf::current ?option?                             # Get current context info
::nsf::next ?args?                                  # Call next method
```

## Extended Type System

### Custom Type Definition
```tcl
::nsf::type::create typename {
    # Basic validation
    -validate {value} {
        # Return validated value or throw error
    }
    
    # Argument validation for parameterized types
    -validatearg {args} {
        # Validate type parameters
    }
    
    # Value conversion
    -convert {value} {
        # Convert value to canonical form
    }
    
    # Custom error formatting
    -errormsg {value args} {
        # Return formatted error message
    }
}
```

### Type Composition
```tcl
# Union type
type1|type2

# Intersection type
type1&type2

# Parameterized type
type,param1,param2

# Constrained type
type,constraint
```

### Built-in Constraints
```tcl
# Value constraints
nonNegative                            # Value >= 0
positive                               # Value > 0
negative                               # Value < 0
between,min,max                        # min <= value <= max

# String constraints
nonempty                              # Non-empty string
alnum                                 # Alphanumeric
alpha                                 # Alphabetic
ascii                                 # ASCII characters
control                               # Control characters
digit                                 # Digits
graph                                 # Graphical chars
lower                                 # Lowercase
print                                 # Printable chars
punct                                 # Punctuation
space                                 # Whitespace
upper                                 # Uppercase
xdigit                               # Hex digits

# Collection constraints
unique                               # Unique elements
sorted                               # Sorted elements
nonempty                            # Non-empty collection
size,n                              # Exact size
minsize,n                           # Minimum size
maxsize,n                           # Maximum size
```

## Debugging and Development

### Debug Commands
```tcl
::nsf::debug::call level objectInfo methodInfo arglist  # Report method/proc call
::nsf::debug::exit level objectInfo methodInfo result usec  # Report method/proc exit
```

### Profiling
Note: These commands are only available if NSF was compiled with profiling support (NSF_PROFILE defined).

```tcl
::nsf::__profile_clear                    # Clear profiling data
::nsf::__profile_get                      # Get profiling data
::nsf::__profile_trace -enable 1|0 \      # Enable/disable tracing
    ?-verbose 1|0? \                      # Enable verbose output
    ?-dontsave 1|0? \                     # Don't save trace data
    ?-builtins cmdList?                   # Built-in commands to trace
```

### Development Tools
```tcl
::nsf::cmd::info                    # Command information
::nsf::cmd::usage                   # Usage information
::nsf::cmd::complete               # Command completion
```

## Package Management

### Package Commands
```tcl
package require nx                  # Load NX
package require nx::test           # Load test framework
package require nsf                # Load NSF core
```

### Version Information
```tcl
::nsf::version                     # Get NSF version
::nx::version                      # Get NX version
```

## Parameter Slots

### Object Parameter Slot Properties
```tcl
name                        # Slot name (defaults to namespace tail)
domain                     # Domain object/class
manager                   # Manager object
per-object               # Per-object flag
methodname              # Method name
forwardername          # Forwarder method name
defaultmethods        # Default methods
accessor             # Access level (public|protected|private)
incremental         # Incremental flag
configurable       # Configurable flag
noarg             # No argument flag
nodashalnum      # No dash-alphanumeric flag
disposition      # Disposition (alias|forward|cmd|initcmd|slotset)
required        # Required flag
default        # Default value
initblock     # Initialization block
substdefault # Subst default pattern
position    # Position (0-based)
positional # Positional flag
elementtype # Element type
multiplicity # Multiplicity constraint
trace      # Trace settings
```

### Object Parameter Slot Methods
```tcl
$slot init args                           # Initialize slot
$slot destroy                            # Destroy slot
$slot createForwarder name domain       # Create forwarder method
$slot onError cmd msg                  # Handle error
$slot makeForwarder                   # Build forwarder from domain
$slot getParameterOptions ?options?  # Get parameter options
```

### Method Parameter Slot Operations
```tcl
::nsf::parameter::cache::classinvalidate class    # Invalidate class parameter cache
::nsf::parameter::cache::objectinvalidate obj    # Invalidate object parameter cache
::nsf::method::forward domain ?options? target ?args?  # Create method forwarder
```

### Parameter Cache Operations
```tcl
::nsf::parameter::cache::classinvalidate class   # Invalidate class cache
::nsf::parameter::cache::objectinvalidate obj   # Invalidate object cache
```

## Relation Slots

### Relation Slot Properties
```tcl
accessor                    # Access level (public|protected|private)
multiplicity              # Multiplicity constraint (default: 0..n)
settername              # Setter method name
```

### Relation Slot Methods
```tcl
$slot init                                # Initialize slot
$slot value=set obj prop value           # Set relation value
$slot value=get obj prop                # Get relation value
$slot value=clear obj prop             # Clear relation value
$slot value=add obj prop value ?pos?  # Add value to relation
$slot value=delete ?-nocomplain? obj prop value  # Delete value from relation
```

### Relation Operations
```tcl
::nsf::relation::set obj prop value    # Set relation
::nsf::relation::get obj prop         # Get relation
```

### Relation Value Handling
```tcl
# Value Types
simple_value              # Single value
list_value               # List of values
qualified_value         # Fully qualified value (::namespace::value)
glob_pattern           # Pattern with * or [ for matching

# Value Operations
lsearch -exact        # Exact value matching
lsearch -glob       # Pattern matching with * and []
linsert pos value  # Insert at position
lreplace pos pos  # Remove at position
```

## Variable Slots

### Variable Slot Properties
```tcl
arg                         # Argument specification
convert                    # Enable value conversion
incremental              # Incremental flag
multiplicity            # Multiplicity constraint (default: 1..1)
accessor               # Access level (public|protected|private)
type                 # Value type
settername          # Setter method name
trace              # Trace settings (none|set)
```

### Variable Slot Methods
```tcl
$slot setCheckedInstVar ?-nocomplain? ?-allowpreset? obj value  # Set checked instance variable
$slot value=set obj value                                      # Set value
$slot value=get obj                                          # Get value
$slot initialize obj                                        # Initialize slot
```

### Built-in Value Types
```tcl
# Basic Types
boolean          # Boolean value
integer         # Integer value
double         # Double value
string        # String value

# Object Types
object        # Any object
class        # Class object
metaclass   # Metaclass object
baseclass  # Base class object
parameter # Parameter object

# String Types
alnum      # Alphanumeric
alpha     # Alphabetic
ascii    # ASCII
control # Control characters
digit   # Digits
graph  # Graphical characters
lower # Lowercase letters
print # Printable characters
punct # Punctuation
space # Whitespace
upper # Uppercase letters
wordchar # Word characters
xdigit   # Hexadecimal digits

# Special Types
switch   # Switch/boolean parameter
cmd     # Command parameter
initcmd # Initialization command
```

### Value Checking
```tcl
::nsf::is -configure -complain -name name: type value  # Check value against type
::nsf::var::exists obj var                           # Check if variable exists
::nsf::var::set obj var value                      # Set variable value
```

## Variable Traces

### Trace Types
```tcl
default          # Default value trace
get             # Get value trace
set            # Set value trace
```

### Trace Operations
```tcl
::trace info variable var                    # Get variable traces
::trace add variable var ops cmdPrefix      # Add variable trace
::trace remove variable var ops cmdPrefix  # Remove variable trace
```

### Trace Commands
```tcl
$slot removeTraces obj matchOps                  # Remove matching traces
$slot handleTraces                              # Set up traces
$slot __default_from_cmd obj cmd var sub op    # Default value handler
$slot __trace_default obj                     # Default trace handler
$slot __trace_get obj                       # Get trace handler
$slot __trace_set obj                      # Set trace handler
```

### Trace Options
```tcl
# Operation Types
read            # Read operation
write          # Write operation
unset         # Unset operation

# Trace Combinations
read write    # Read and write operations
read unset   # Read and unset operations
write unset # Write and unset operations
```

### Trace Restrictions
```tcl
# Invalid Combinations
-trace default + -trace get     # Can't use together
-trace default + default value # Can't use together
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

# Examples:
$obj object variable -accessor public name "John"     # Public variable with default
$obj object variable -incremental items              # Incremental list variable
$obj object variable -trace {get set} counter 0     # Traced counter variable
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

# Examples:
$obj object property -accessor public name           # Public property
$obj object property -incremental items             # Incremental property
$obj object property -trace get computed script    # Computed property
```

### Variable Operations
```tcl
::nsf::var::exists obj var               # Check if variable exists
::nsf::var::set obj var value           # Set variable value
::nsf::var::get obj var                # Get variable value
::nsf::var::unset ?-nocomplain? obj var  # Unset variable
```

### Property Features
```tcl
# Slot-less Variables
- No accessor
- No configuration
- No incremental operations
- No traces
- Optional default value

# Slot-based Variables
- Custom accessors
- Configuration support
- Incremental operations
- Trace support
- Initialization blocks
- Value validation
```

## Object Creation and Manipulation

### Namespace Operations
```tcl
$obj contains ?options? script               # Execute in object namespace
$obj requirenamespace                       # Ensure namespace exists
namespace current                          # Get current namespace
namespace children ns ?pattern?           # Get child namespaces
```

### Contains Command Options
```tcl
-withnew bool          # Enable scoped new (default: true)
-object obj           # Target object
-class className     # Object class (default: ::nx::Object)
```

### Object Copying
```tcl
# Copy Handler Properties
targetList           # List of objects to copy
dest                # Destination path
objLength          # Original object path length

# Copy Handler Methods
$handler makeTargetList target     # Build copy target list
$handler getDest origin           # Get destination path
$handler copyTargets             # Copy all targets

# Command Mapping
alias -> alias         # Copy alias
forward -> forward    # Copy forward
method -> create     # Copy method
setter -> setter    # Copy setter
```

### Object Moving
```tcl
$obj move target                  # Move object to target
$obj rename newName             # Rename object
::nsf::object::move obj target # Move object (low-level)
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

### Object Properties
```tcl
::nsf::object::property obj keepcallerself bool     # Keep caller self
::nsf::object::property obj perobjectdispatch bool # Per-object dispatch
::nsf::object::property obj hasperobjectslots bool # Has per-object slots
::nsf::object::property obj initialized bool      # Object initialized
::nsf::object::property obj slotcontainer bool  # Is slot container
```

### Namespace Operations
```tcl
::nsf::nscopyvars source dest          # Copy namespace variables
::nsf::directdispatch obj ?opts? cmd  # Direct method dispatch
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