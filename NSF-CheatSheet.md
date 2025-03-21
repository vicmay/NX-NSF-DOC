# NSF Cheat Sheet

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

## Method Manipulation

### Method Creation
```tcl
::nsf::method::create object methodName arguments body  # Create method
::nsf::method::delete object methodName                # Delete method
::nsf::method::copy srcObj srcMethod destObj destMethod  # Copy method
::nsf::method::move srcObj srcMethod destObj destMethod  # Move method
::nsf::method::property object methodName property value # Set method property
```

### Method Properties
```tcl
::nsf::method::property object method call-protected boolean  # Protection level
::nsf::method::property object method call-private boolean   # Private access
::nsf::method::property object method debug boolean         # Debug mode
::nsf::method::property object method deprecated message    # Deprecation
::nsf::method::property object method returns type         # Return type
```

## Variable and Slot Management

### Variable Operations
```tcl
::nsf::var::exists obj var               # Check if variable exists
::nsf::var::set obj var value           # Set variable value
::nsf::var::get obj var                # Get variable value
::nsf::var::unset ?-nocomplain? obj var  # Unset variable
```

### Slot Operations
```tcl
::nsf::slot::create object slotName      # Create slot
::nsf::slot::delete object slotName     # Delete slot
::nsf::slot::property object slot prop  # Set slot property
```

## Debugging and Development

### Debug Commands
```tcl
::nsf::debug::call level objectInfo methodInfo arglist  # Report method/proc call
::nsf::debug::exit level objectInfo methodInfo result usec  # Report method/proc exit
```

### Profiling
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

## Parameter Patterns and Type Checking

### Basic Type Checking
```tcl
# Built-in type checks
::nsf::is integer 1                   # Check for integer
::nsf::is boolean on                  # Check for boolean (on/off/1/0)
::nsf::is object obj                  # Check if object exists
::nsf::is class Class                 # Check if class exists

# Type checking with constraints
::nsf::is object,type=::C obj        # Check object type
::nsf::is -complain object obj       # Check with error message
::nsf::is -name name: type value     # Named type check

# Property type constraints
:property {name:string}               # String property
:property {flag:boolean}              # Boolean property
:property {count:integer}             # Integer property
```

### Parameter Validation
```tcl
# Method parameter validation
:public method validate {
    -object obj                       # Must be valid object
    -class cls                        # Must be valid class
    -boolean flag                     # Must be boolean
    args                             # Additional args
} {
    # Method body
}

# Complex parameter patterns
:public method complex {
    -object,type=::MyClass obj       # Object of specific type
    -class,type=::BaseClass cls      # Class of specific type
    -integer,min=0,max=100 num       # Integer with range
}

# Custom type validation
::nx::methodParameterSlot object method type=mytype {name value} {
    if {$value < 1 || $value > 3} {
        error "value '$value' of parameter $name is not between 1 and 3"
    }
}

# Custom type with arguments
::nx::methodParameterSlot object method type=in {name value arg} {
    if {$value ni [split $arg |]} {
        error "value '$value' of parameter $name not in permissible values $arg"
    }
    return $value
}
```

### Object and Class Checks
```tcl
# Object existence
::nsf::object::exists $obj           # Check if object exists

# Class type checks
::nsf::is baseclass ::nx::Object     # Check if baseclass
::nsf::is class ::nx::Object         # Check if class

# Mixin checks
obj info has mixin ::Mixin           # Check mixin
obj info has type Class              # Check type

# Object type validation
::nsf::is object,type=::C obj        # Check object type
::nsf::is -complain object,type=::C obj # Check with error message
```

### Property Type Definitions
```tcl
# Simple property types
:property {name:string}               # String property
:property {age:integer}              # Integer property
:property {active:boolean}           # Boolean property

# Property with constraints
:property {count:integer,min=0}      # Non-negative integer
:property {level:integer,0..10}      # Integer range
:property {type:enum=red,green,blue} # Enumeration

# Property with default
:property {timeout:integer 30}       # Default value
:property {prefix:string ""}         # Empty string default

# Property with type checking
:property {obj:object,type=::C}      # Object of specific type
:property {cls:class,type=::MC}      # Class of specific type
```

### Parameter Cache Operations
```tcl
# Cache invalidation
::nsf::parameter::cache::classinvalidate class    # Class cache
::nsf::parameter::cache::objectinvalidate obj     # Object cache

# Parameter handling
::nsf::parameter::cache::get obj                 # Get cache
::nsf::parameter::cache::set obj value          # Set cache
::nsf::parameter::cache::clear obj             # Clear cache
```

### Low-level Parameter Commands
```tcl
# Parameter creation
::nsf::parameter::create name spec            # Create parameter
::nsf::parameter::property param prop value   # Set property

# Parameter validation
::nsf::parameter::validate param value       # Validate value
::nsf::parameter::convert param value        # Convert value

# Parameter introspection
::nsf::parameter::info param property        # Get property
::nsf::parameter::exists param               # Check existence
```

### Parameter Manager System
```tcl
# Custom type manager
::paramManager {
    :object method type=customtype {name value} {
        # Validation logic
        return $result
    }
}

# Parameter registration
::nsf::parameter::register type manager     # Register type
::nsf::parameter::unregister type          # Unregister type
```

### Parameter Value Handling
```tcl
# Value operations
::nsf::var::set slot property value        # Set value
::nsf::var::get slot property              # Get value
::nsf::var::exists slot property           # Check existence
::nsf::var::unset slot property            # Unset value

# Value checking
::nsf::is -configure -complain -name name: type value  # Full check
::nsf::var::exists obj var                           # Check existence
::nsf::var::set obj var value                       # Set with check
```

### Parameter Trace System
```tcl
# Trace types
default                                    # Default value trace
get                                       # Get value trace
set                                      # Set value trace

# Trace operations
::trace add variable var ops cmdPrefix    # Add trace
::trace remove variable var ops cmdPrefix # Remove trace
::trace info variable var                # Get traces

# Trace handlers
__trace_default obj                      # Default handler
__trace_get obj                         # Get handler
__trace_set obj                        # Set handler

# Value changed handler
:public object method value=set {obj var value} {
    # Handle value change
    ::nsf::var::set -notrace $obj $var [expr {$value + 1}]
}
```

### Parameter Specification Format
```tcl
# Basic format
name                                       # Simple parameter
name:required                              # Required parameter
name:type=type                            # Typed parameter
name:arg=arg                              # Argument spec

# Multiplicity format
name:0..1                                 # Optional parameter
name:1..n                                 # Multiple required
name:0..n                                 # Multiple optional
name:convert                              # Enable conversion

# Special formats
name:noarg                                # No argument
name:nodashalnum                          # No dash-alphanumeric
name:method=method                        # Associated method
name:substdefault                         # Enable subst default
name:alias                                # Alias parameter
name:forward                              # Forward parameter
```

## Parameter Handling and Type System

### Parameter Type Checking
```tcl
# Basic type checking
::nsf::is integer value                    # Check integer type
::nsf::is boolean value                    # Check boolean type
::nsf::is object value                     # Check object existence
::nsf::is class value                      # Check class existence

# Type checking with options
::nsf::is -configure type value            # Configure type check
::nsf::is -complain type value             # Check with error message
::nsf::is -name name: type value           # Named type check

# Object type checking
::nsf::is object,type=::C obj              # Check object type
::nsf::is class,type=::C cls               # Check class type
::nsf::is metaclass,type=::C mcls          # Check metaclass type
```

### Parameter Validation System
```tcl
# Custom type validation
::nsf::type::create typename {
    -validate {value} {
        # Validation logic
        return $value
    }
    -validatearg {args} {
        # Argument validation
    }
    -convert {value} {
        # Value conversion
    }
    -errormsg {value args} {
        # Error message formatting
    }
}

# Parameter validation
::nsf::parameter::validate param value     # Validate parameter
::nsf::parameter::convert param value      # Convert parameter value
::nsf::parameter::exists param             # Check parameter existence
```

### Parameter Cache Operations
```tcl
# Cache management
::nsf::parameter::cache::classinvalidate class    # Invalidate class cache
::nsf::parameter::cache::objectinvalidate obj     # Invalidate object cache
::nsf::parameter::cache::get obj                  # Get cache
::nsf::parameter::cache::set obj value           # Set cache
::nsf::parameter::cache::clear obj               # Clear cache

# Parameter handling
::nsf::parameter::create name spec               # Create parameter
::nsf::parameter::property param prop value      # Set property
::nsf::parameter::info param property            # Get property
```

### Parameter Value Handling
```tcl
# Value operations
::nsf::var::set obj var value                   # Set value
::nsf::var::get obj var                         # Get value
::nsf::var::exists obj var                      # Check existence
::nsf::var::unset -nocomplain obj var          # Unset value

# Value checking
::nsf::is -configure -complain -name name: type value  # Full check
::nsf::var::exists obj var                            # Check existence
::nsf::var::set obj var value                        # Set with check
```

### Parameter Trace System
```tcl
# Trace types
::trace add variable var ops cmdPrefix            # Add trace
::trace remove variable var ops cmdPrefix         # Remove trace
::trace info variable var                         # Get traces

# Trace operations
read                                             # Read operation
write                                            # Write operation
unset                                            # Unset operation
default                                          # Default value trace

# Value changed handler
:public object method value=set {obj var value} {
    # Handle value change
    ::nsf::var::set -notrace $obj $var $value
}

# Trace restrictions
-trace default + -trace get                      # Invalid combination
-trace default + default value                   # Invalid combination
```

### Parameter Namespace Binding
```tcl
# Namespace qualification
::nsf::parameter::qualify name                   # Qualify parameter name
::nsf::parameter::unqualify name                 # Unqualify parameter name

# Type binding
type=[namespace current]::type                   # Current namespace
type=[namespace qualifiers [self]]::type         # Object namespace
type=::fully::qualified::type                    # Absolute namespace
```

### Parameter Error Handling
```tcl
# Error generation
::nsf::parameter::error param msg                # Raise parameter error
::nsf::parameter::warning param msg              # Issue warning

# Error checking
catch {::nsf::is type value} err                # Catch type error
catch {::nsf::parameter::validate param value} err  # Catch validation error

# Error messages
"expected type but got value"                    # Type mismatch
"invalid value constraints"                      # Invalid constraints
"required parameter not given"                   # Missing required
```

### Parameter Parsing
```tcl
# Parse arguments
::nsf::parseargs spec args                       # Parse arguments
::nsf::parseargs -asdict spec args              # Parse as dictionary

# Argument specifications
name:type                                        # Type specification
{-name:type default}                             # Default value
name:type,constraint                             # With constraint
args:type,0..n                                   # Variable arguments
```

### Parameter Manager System
```tcl
# Type manager
::paramManager {
    :object method type=customtype {name value} {
        # Validation logic
        return $result
    }
}

# Registration
::nsf::parameter::register type manager          # Register type
::nsf::parameter::unregister type               # Unregister type
```

### Parameter Slot System
```tcl
# Slot creation
::nx::slotObj -container type object name        # Create slot
::nsf::var::set slot property value             # Set slot property

# Slot operations
::nsf::method::setter class slotName            # Register setter
::nsf::method::property class slot property value  # Set property

# Slot validation
::nsf::slot::validate slot value                # Validate slot
::nsf::slot::convert slot value                 # Convert value
```

### Best Practices
```tcl
# Type checking
::nsf::is -complain type value                  # Always use -complain
::nsf::is -name param: type value               # Name parameters
::nsf::is -configure type value                 # Configure checks

# Error handling
catch {::nsf::parameter::validate param value} err  # Always catch
if {![::nsf::parameter::exists param]} { error }   # Check existence

# Cache management
::nsf::parameter::cache::clear obj              # Clear after changes
::nsf::parameter::cache::invalidate obj         # Invalidate modified

# Trace usage
-trace set                                      # Use for changes
-trace get                                      # Use for access
-trace {get set}                                # Use for both
``` 