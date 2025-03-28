# NX/NSF: The Definitive Guide

## Introduction

NX/NSF (Next Scripting Framework) is a Tcl-based object-oriented programming system that provides advanced capabilities for building complex applications. This guide serves as a comprehensive reference for NX/NSF programming.

### Historical Context

While NX has predecessors in the Tcl ecosystem (XOTcl and XOTcl2), it is a distinct and improved language with its own features and design philosophy. Key points about NX's position in the Tcl ecosystem:

- **Foundation**: Built on Tcl (requires Tcl 8.5 or newer)
- **Framework**: Part of the Next Scripting Framework (NSF)
- **Design Goals**: 
  - Easier learning curve for novices
  - Improved maintainability
  - Better structured programs
  - Enhanced support for large projects
  - Language-oriented programming support

### Key Differentiators

NX differs from its predecessors in several important ways:
- More mainstream terminology
- Higher orthogonality of methods
- Fewer predefined methods
- Strong focus on maintainability
- Built-in support for interfaces
- Language-oriented programming capabilities

## Core Packages and Base Classes

The foundation of NX/NSF begins with its core packages:

```tcl
package require nsf     # Next Scripting Framework
package require nx      # NX object system
```

The system is built on two fundamental base classes:
- `nx::Object`: The base object class for all objects in the system
- `nx::Class`: The metaclass for creating classes (which is an instance of itself)

These base classes provide the essential functionality for object creation, method dispatch, and property management. The system ensures safety by protecting these base classes from accidental deletion or modification.

### Tcl Interpreter Integration

NX/NSF provides robust integration with Tcl's interpreter system, allowing for sophisticated control over command visibility and interpreter management. This section covers the essential aspects of working with Tcl interpreters in NX/NSF applications.

#### Basic Interpreter Operations

```tcl
# Create a new slave interpreter
interp create

# Create a new interpreter with NSF loaded
::nsf::interp create

# Create a new safe interpreter with NSF loaded
::nsf::interp create -safe

# Evaluate commands in a slave interpreter
$i eval {cmd}

# Destroy an interpreter
interp delete $i

# Check if interpreter is safe
interp issafe $i
```

#### Command Hiding and Exposure

NX/NSF provides mechanisms to control command visibility in interpreters:

```tcl
# Hide a command in the interpreter
$i hide cmdName

# Hide a command under a different name
$i hide cmdName newName

# Re-expose a hidden command
interp expose $i hiddenCmd

# Re-expose a hidden command under a different name
interp expose $i hiddenCmd newName

# List all hidden commands
interp hidden $i

# Invoke a hidden command
interp invokehidden $i cmd args
```

#### Hidden Command Characteristics

Hidden commands in NX/NSF have specific behaviors and limitations:

1. **Storage and Access**:
   - Removed from normal command table
   - Placed in separate interpreter-wide hash table
   - Cannot be accessed via normal command invocation
   - Cannot use namespace qualifiers when hiding commands
   - Command structure is preserved internally
   - Object system relationships remain intact

2. **Limitations**:
   - Cannot hide namespace-qualified commands
   - Cannot directly dispatch to hidden commands
   - Hidden commands are cleaned up later than regular commands during interpreter deletion

#### Object System Interaction

When working with hidden commands in NX/NSF:

1. **Object Structure Preservation**:
   - Object instances remain in the object system
   - Object-class relationships are maintained
   - Mixin relationships are preserved
   - Introspection still functions for pattern-based queries

2. **Method Dispatch**:
   - Hidden objects can still be accessed via their instances
   - Methods from hidden classes still function on instances
   - Existing mixin relationships continue to work

3. **Alias Handling**:
   - Aliases to hidden procs/objects cannot be dispatched
   - Re-exposing with original name restores alias functionality
   - Re-exposing with a different name does not automatically restore alias
   - The `::nsf::alias` array can be manually modified to fix aliases

#### Object System Cleanup

```tcl
# Shut down NSF object system in an interpreter
nsf::finalize [-keepvars]

# The -keepvars flag preserves global variables
```

#### Destruction Behavior

1. **Normal Destruction**:
   - Object destructors are called during cleanup
   - Hidden commands are processed after exit handlers

2. **Explicit Destruction**:
   - Hidden objects can be destroyed via `interp invokehidden`
   - After destruction, object is removed from hidden command table

3. **Error Handling in Destroy**:
   - Errors in destroy methods don't prevent cleanup
   - Self-deletion or self-hiding in destroy methods requires careful handling

#### Mixin Relationships

When working with hidden commands and mixins:

1. Existing mixins continue to function when commands are hidden
2. Adding/removing mixins involving hidden classes is problematic
3. Mixin order computation handles hidden mixins properly

#### Best Practices

1. **When Working with Hidden Commands**:
   - Use `interp invokehidden` from the master interpreter
   - Don't rely on aliases to hidden commands
   - Be careful with destructors that modify command visibility

2. **For Cleanup**:
   - Use `nsf::finalize` for controlled shutdown
   - Check hidden commands after cleanup with `interp hidden`

#### Example: Hide and Re-expose

```tcl
# Create and hide a command
set i [interp create]
$i eval {nx::Object create ::o}
$i hide o

# Check status
interp hidden $i         # Returns "o"
$i eval {info commands ::o}  # Returns ""

# Access via hidden mechanism
interp invokehidden $i o method args

# Re-expose the command
interp expose $i o
```

### Internationalization and Message Handling

NX/NSF provides robust support for internationalization through integration with Tcl's msgcat package. This allows for easy localization of messages and text in NX applications.

#### Basic Usage

```tcl
# Load the msgcat package
package req msgcat

# Set messages in the current locale
::msgcat::mcset [::msgcat::mclocale] message_key "message text"

# Example with namespace context
::msgcat::mcset [::msgcat::mclocale] m1 "[namespace current] message1"
```

#### Accessing Messages

```tcl
# Import mc command for easier access
namespace import ::msgcat::mc

# Retrieve a message
mc message_key
```

#### Namespace Behavior

The msgcat package respects Tcl namespaces when looking up messages:

1. Messages are first looked up in the current namespace
2. If not found, msgcat looks in parent namespaces
3. Finally falls back to the global namespace

Example namespace structure:
```
::              (global)
  ↓
::foo           (child namespace)
  ↓
::foo::bar      (grandchild namespace)
```

#### Integration with NX/NSF Classes

Within nx::Class definitions, msgcat can be used in various contexts:

```tcl
nx::Class create ClassName {
  :require namespace
  
  # Using mc in class definition
  ? [list set _ [mc message_key]] $expected_value
  
  # Using mc in instance methods
  :public method methodName {} {
    return [mc message_key]
  }
  
  # Using mc in object methods
  :public object method methodName {} {
    return [mc message_key]
  }
  
  # Using mc in property accessors
  :property propName {
    :public object method value=get {args} {
      return [namespace current]-[mc message_key]
    }
  }
}
```

#### Custom Property Behavior with Msgcat

Properties can be enhanced with msgcat integration:

```tcl
:property -accessor public propName {
  :public object method value=set {obj prop value} {
    ::msgcat::mcset [::msgcat::mclocale] $value "new message"
    next
  }
  
  :public object method value=get {args} {
    mc [next]
  }
}
```

#### Testing Message Resolution

Message resolution can be tested using various methods:

```tcl
# Test instance method result
? {[::Namespace::ClassName new] methodName} $expected_value

# Test object method result
? {::Namespace::ClassName methodName} $expected_value

# Test property access
? {[::Namespace::ClassName new] cget -propName} $expected_value
```

#### Key Concepts

1. **Namespace Awareness**: Messages are bound to their defining namespace
2. **Locale Management**: `::msgcat::mclocale` returns or sets the current locale
3. **Message Setting**: `::msgcat::mcset` associates a key with a message in a locale
4. **Message Retrieval**: `::msgcat::mc` (or imported `mc`) retrieves messages based on context
5. **Inheritance**: Messages cascade from child to parent namespaces

### Mixins

Mixins are a powerful feature in NX that allows you to add functionality to classes or objects without using inheritance. A mixin is a class that is mixed into another class or object to provide additional functionality.

#### Basic Concepts

- **Mixin**: A class that is mixed into another class or object to provide additional functionality
- **Per-Object Mixin**: A mixin applied to a specific object instance
- **Per-Class Mixin**: A mixin applied to a class, affecting all instances of that class

#### Setting Mixins

```tcl
# Apply per-object mixin
nx::Object create obj -object-mixins MixinClass

# Apply per-class mixin
nx::Class create MyClass -mixin MixinClass

# Set mixin on existing class
MyClass mixins set MixinClass

# Add guard to mixin
MyClass mixins guard MixinClass "guardCondition"
```

#### Querying Mixins

```tcl
# Get mixins for an object
obj object mixins get        # Returns list of object mixins
obj info object mixins       # Alternative syntax

# Get mixins for a class
MyClass mixins get           # Returns list of class mixins
MyClass info mixins          # Alternative syntax
MyClass info mixins -guards  # Show mixins with guards
```

#### Finding Where a Class is Mixed In

```tcl
# Basic usage
MixinClass info mixinof              # Shows where MixinClass is mixed in

# Scope options
MixinClass info mixinof -scope class  # Only class-level mixins
MixinClass info mixinof -scope object # Only object-level mixins
MixinClass info mixinof -scope all    # Both class and object level (default)

# Transitive closure options
MixinClass info mixinof -closure      # Includes indirect mixinof relationships
MixinClass info mixinof -closure pattern  # Filter with glob pattern
```

#### Method Precedence

When an object has mixins, method calls use the following precedence order:

1. Per-object mixins
2. Class of the object
3. Per-class mixins of the object's class
4. Superclasses (in inheritance order)
5. nx::Object (base class)

Example precedence: `::MixinClass ::MyClass ::nx::Object`

#### Mixin Inheritance Behavior

- Mixins from superclasses are inherited by subclasses (transitive)
- When a class used as a mixin has its own mixins, those are included in the precedence chain
- Destroying a mixin class removes it from all objects and classes

#### Recreating Classes with Mixins

##### With softrecreate = false (default)

When recreating a class that is used as a mixin:
- All mixin relationships are lost
- Subclass relationships are broken
- Objects of the old class become instances of nx::Object

##### With softrecreate = true

When recreating a class that is used as a mixin:
- Mixin relationships are preserved
- Subclass relationships are maintained
- Objects remain instances of their classes

#### Common Patterns and Examples

##### Per-Object Mixins

```tcl
nx::Class create Logger {
    :method log {msg} {
        puts "LOG: $msg"
        next
    }
}

nx::Object create myObj -object-mixins Logger
```

##### Per-Class Mixins

```tcl
nx::Class create Auditable {
    :method save {} {
        puts "Auditing save operation"
        next
    }
}

nx::Class create Document -mixin Auditable
```

##### Complex Precedence Example

```tcl
nx::Class create A
nx::Class create B -mixin A
nx::Class create C -superclass B
C create c1

# c1's precedence: ::A ::C ::B ::nx::Object
```

### Variable and Parameter Information

The NX/NSF system provides comprehensive introspection capabilities for variables and parameters. This section covers the essential commands and patterns for working with class and object variables.

#### Class Information Commands

```tcl
# Get list of parameters for class creation
/cls/ info configure parameters ?pattern?

# Get syntax output for class creation
/cls/ info configure syntax

# Get method parameters
/cls/ info method parameters /methodname/ ?/pattern/?

# Get method syntax
/cls/ info method syntax /methodname/

# Get variable handles
/cls/ info variables ?/pattern/?
```

#### Object Information

```tcl
# Get object method parameters
/obj/ info object method parameters /methodname/ ?/pattern/?

# Get object method syntax
/obj/ info object method syntax /methodname/

# Get object variable handles
/obj/ info object variables ?/pattern/?
```

#### Lookup Information

```tcl
# Get parameters from class hierarchy
/obj/ info lookup configure parameters ?/pattern/?

# Get syntax from class hierarchy
/obj/ info lookup configure syntax

# Get variable handles from class hierarchy
/obj/ info lookup variables ?/pattern/?
```

#### Context-free Operations

```tcl
# Work on any object (does not need object)
/obj/ info parameter list|name|syntax /param/
/obj/ info variable definition|name|parameter /handle/
```

#### Parameter Handling with `nsf::parameter::info`

```tcl
# Get parameter syntax representation
nsf::parameter::info syntax parameter_definition

# Get parameter name
nsf::parameter::info name parameter_definition

# Check if parameter has default value
nsf::parameter::info default parameter_definition ?varname?

# Get parameter type
nsf::parameter::info type parameter_definition
```

Examples:
```tcl
nsf::parameter::info syntax age:integer         # Returns: "/age/"
nsf::parameter::info syntax -force:switch       # Returns: "?-force?"
nsf::parameter::info name "a b"                 # Returns: "a"
nsf::parameter::info default "b:integer 123"    # Returns: 1 (has default)
nsf::parameter::info type "age:integer"         # Returns: "integer"
```

#### Variable and Property Definition Examples

##### Class Level Properties and Variables
```tcl
# Basic property
:property name

# Typed property
:property age:integer

# Property with default value
:property {b:integer 123}

# Variable with default value
:variable c 456

# Typed variable with default
:variable d:lower abc

# Public accessor
:variable -accessor public e:lower efg

# Private accessor
:property -accessor private {p 19}

# Protected accessor
:property -accessor protected q

# Incremental property
:property -incremental i
```

##### Object Level Properties and Variables
```tcl
# Object property
:object property oa:integer

# Object property with default
:object property {ob:integer 123}

# Object variable
:object variable oc 456

# Object variable with type
:object variable od:lower abc

# Public object variable
:object variable -accessor public oe:lower efg

# Incremental object property
:object property -incremental oi

# Private object property
:object property -accessor private {op 19}

# Protected object property
:object property -accessor protected oq
```

#### Slot and Variable Information

```tcl
# List all slots
::Foo info slots

# Get specific slot
::Foo info slots p

# Get slot definition
::Foo::slot::b definition

# List all variables
::Foo info variables

# List specific variable
::Foo info variables p

# Get variable definition
::Foo info variable definition handle

# Get variable parameter
::Foo info variable parameter handle

# Get variable name
::Foo info variable name handle
```

#### Lookup Variables
```tcl
# Get count of lookup variables
llength [::f1 info lookup variables]

# List all lookup variables (includes inherited)
::f1 info lookup variables

# Search for specific lookup variables
::f1 info lookup variables p
```

#### Accessor Usage Patterns

```tcl
# Private and protected access via method
:public method m {} {: -local p get}

# Object-level private property access
:public object method om {} {: -local p}
```

#### Variable Naming Notes

- Private properties are prefixed with `____ClassName` in slot names
- Per-object variables use `per-object-slot` namespace
- Private properties in name output appear as `__private(namespace,name)`

### Info Method Commands

The NX/NSF system provides comprehensive introspection capabilities through its info method commands. These commands allow you to inspect and query various aspects of objects and classes.

#### Basic Info Commands

```tcl
# Superclass Information
obj info superclasses                   # Get direct superclasses
obj info superclasses -closure          # Get all superclasses (including indirect)
obj info superclasses pattern           # Get superclasses matching pattern
obj info superclasses -closure pattern  # Get all superclasses matching pattern

# Heritage and Precedence
obj info heritage                       # Get class inheritance path
obj info precedence                     # Get method dispatch order
obj info precedence pattern             # Get method dispatch order matching pattern

# Method Information
obj info methods                        # List methods
obj info methods -callprotection all    # List all methods (including protected)
obj info methods -type scripted         # List only scripted methods
obj info methods -path                  # List methods as path names
obj info methods -closure pattern       # List all methods (including inherited) matching pattern
obj info methods -source application    # List only application-defined methods
obj info methods -source system         # List only system methods
```

#### Method Lookup and Details

```tcl
# Method Lookup
obj info lookup method name             # Get actual method to be called for name
obj info lookup methods pattern         # List available methods matching pattern
obj info lookup methods -path pattern   # List methods with ensemble paths
obj info lookup methods -source all     # List all available methods

# Method Details
obj info method definition name         # Get method definition
obj info method returns name            # Get return type constraint
obj info method parameters name         # Get parameter definitions
obj info method syntax name             # Get syntax documentation
obj info method exists name             # Check if method exists
obj info method type name               # Get method type
```

#### Object Methods and Properties

```tcl
# Object Methods
obj info object methods                 # List object methods
obj info object method definition name  # Get object method definition
obj info object method parameters name  # Get object method parameters
obj info object method returns name     # Get object method return type
obj info object method submethods name  # List submethods of ensemble

# Slots (Properties)
obj info slots                          # List slots
obj info slots -closure                 # List all slots (including inherited)
obj info slots -closure -source application # List application-defined slots
obj info slots pattern                  # List slots matching pattern
obj info object slots                   # List object-specific slots
```

#### Mixins and Filters

```tcl
# Mixins
obj info mixins                         # List direct mixins
obj info mixins -closure                # List all transitive mixins
obj info mixins -heritage               # List explicit and implicit mixins
obj info object mixins                  # List object mixins
obj info object mixins -guards          # List object mixins with guards
obj info object mixins -guards name     # Get guard for specific mixin

# Filters
obj info filters                        # List filters
obj info filters -guards                # List filters with their guards
obj info object filters                 # List object filters
obj info object filters -guards         # List object filters with guards
```

#### Ensemble Methods

```tcl
# Ensemble Method Information
obj info method submethods ensemble     # List submethods of ensemble
obj info method exists "ensemble submethod" # Check if submethod exists
obj info method parameters "ensemble submethod" # Get parameters of submethod
obj info method definition "ensemble submethod" # Get definition of submethod
```

#### Method Types and Return Types

NX supports several method types:
- `scripted`: Regular Tcl methods
- `alias`: Aliases to Tcl commands
- `forward`: Forwarding to other methods
- `object`: Object-specific methods
- `setter`: Property setter methods
- `builtin`: Built-in methods

Return types can be specified with `-returns` and queried:
```tcl
obj info method returns methodName      # Get return type constraint

# Common return types:
# integer - Integer values
# object - Object references
# object,1..n - One or more object references
```

### Basic Object Creation Examples

The NX/NSF system provides several ways to create objects:

1. **Creating Basic Objects**
```tcl
# Create a simple object
nx::Object create myObject

# Create an object with initialization
nx::Object create myObject {
    :property name
    :property age 0
}

# Create an object in a specific namespace
nx::Object create ::app::myObject
```

2. **Creating Classes**
```tcl
# Define a basic class
nx::Class create Person {
    :property name
    :property age 0
    
    :method init {} {
        # Constructor logic
    }
    
    :method greet {} {
        return "Hello, my name is [:get name]"
    }
}

# Create instance of the class
Person create john -name "John Doe" -age 30
```

3. **Inheritance Examples**
```tcl
# Single inheritance
nx::Class create Employee -superclass Person {
    :property department
    :property salary
    
    :method init {} {
        next ;# Call parent's init method
    }
}

# Multiple inheritance
nx::Class create Manager -superclass {Employee Leader} {
    :property team
}
```

### Coroutines and Yield

The NX/NSF system provides powerful support for coroutines and yielding, enabling advanced control flow patterns and asynchronous programming capabilities.

#### Simple Number Generator
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

#### Enumerator Patterns

##### Basic Enumerator (Single Class)
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

##### Advanced Enumerator (Yielder & Enumerator)
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

##### Using Enumerator
```tcl
# Using next() method
set e [Enumerator new -members {1 2 3}]
while 1 { incr sum [$e next] }  # Sum will be 6

# Using each() method
set e [Enumerator new -members {a be bu}]
$e each x { append string $x }  # String will contain "abebu"
```

##### Extending Enumerator
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

#### Apply Function

The NX/NSF system provides powerful support for the apply function, enabling functional programming patterns:

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

### Methods and Properties

The NX/NSF system provides comprehensive support for method definition and property management:

#### Method Provision and Requirements

```tcl
# Basic method provision
nsf::method::provide method_name {implementation}

# Alias to a Tcl command
nsf::method::provide append {::nsf::method::alias append -frame object ::append}

# Create a custom method
nsf::method::provide foo {::nsf::method::create foo {x y} {return x=$x,y=$y}}

# Provide a method using a mixin
nsf::method::provide x {::get_mixin ::MIX x} {
  ::nx::Class create ::MIX {:public method x {} {return x}}
}
```

#### Method Requirements

Methods can be required in class definitions to ensure proper interface implementation:

```tcl
# Require a method in a class definition
nx::Class create C {
  :require method set
  :require method exists
}

# Require a method with different name than registered name
C require method tcl::set

# Require object methods
C require object method lappend

# Public vs. Protected methods
C require public method lappend
C require protected method lappend

# Require methods directly on objects
Object create o1
o1 require object method set
o1 require public object method lappend
o1 require protected object method lappend
```

#### Method Properties and Protection

Methods can have various properties and protection levels:

```tcl
# Check if a method is protected
::nsf::method::property C lappend call-protected

# Protected methods cannot be redefined as public
nx::Class public method __alloc arg {return 1}  # Will fail

# Class-specific methods cannot be called on objects
::nsf::method::require object __alloc  # Will fail when called
```

#### Parent/Namespace Requirements

The NX framework creates parent namespaces automatically when needed:

```tcl
# Creating objects in nested namespaces
C create ::o::o        # Creates ::o namespace and ::o::o object
C create ::1::2::3::4  # Creates all parent namespaces and the object
```

#### Method Definition and Usage

```tcl
nx::Class create Example {
    # Public method
    :public method sayHello {name} {
        return "Hello, $name!"
    }
    
    # Protected method - only accessible by class and subclasses
    :protected method internalHelper {} {
        # Internal implementation
    }
    
    # Method with default arguments
    :public method greet {{greeting "Hello"} name} {
        return "$greeting, $name!"
    }
}

# Using methods
set obj [Example new]
$obj sayHello "World"
```

#### Properties

Properties in NX/NSF can be defined with various characteristics:

```tcl
nx::Class create Person {
    # Simple property
    :property name
    
    # Property with default value
    :property {age 0}
    
    # Property with type checking
    :property -incremental {friends:object,*}
    
    # Property with custom accessor
    :property {score 0} {
        :public object method score=set {obj prop value} {
            if {$value < 0} {
                error "Score cannot be negative"
            }
            next $obj $prop $value
        }
    }
}
```

#### Property Declaration Syntax

Properties can be declared at both class and object levels with various options:

```tcl
# Class Level Properties
:property {name defaultValue}                    # Basic property
:property -accessor public|protected|private|none {name defaultValue}  # With accessor
:property -incremental {name defaultValue}       # For collections
:property -incremental name:type,multiplicity   # With type and multiplicity
:property -accessor none -configurable false {name defaultValue}  # Non-configurable

# Object Level Properties
:object property {name defaultValue}             # Basic object property
:object property -accessor public|protected|private|none {name defaultValue}  # With accessor
:object property -incremental {name defaultValue}  # For collections
```

#### Accessor Visibility

Properties can have different access levels:
- **public**: Accessible from anywhere
- **protected**: Accessible only from methods in the class and its subclasses
- **private**: Accessible only from methods within the class
- **none**: No accessor method is created

#### Incremental Properties

The `-incremental` flag changes property behavior:
- Creates an accessor even when not explicitly requested
- Enables collection operations (add, delete)
- Makes properties multivalued by default

#### Property Operations

```tcl
# Configure a property
object configure -propertyName value

# Get property value
object cget -propertyName

# Using accessor methods
object propertyName get
object propertyName set newValue

# Incremental property operations
object propertyName add value
object propertyName set {value1 value2 value3}
object propertyName delete value
object propertyName delete -nocomplain value
object propertyName exists
object propertyName unset
```

#### Property Multiplicity

Properties can have different multiplicity constraints:
- **0..n**: Zero or more values (default for incremental properties)
- **1..n**: One or more values (non-empty)
- **0..1**: Zero or one value (optional)
- **1..1**: Exactly one value (required)

#### Variable Substitution with substdefault

The `substdefault` modifier in NX/TCL framework allows for variable substitution in default values. This feature provides fine-grained control over how variables, commands, and backslashes are substituted in property default values.

##### Basic Syntax

```tcl
:property {name:substdefault "value"}
:property {name:substdefault=OPTION "value"}
```

Where OPTION is a binary flag that controls the substitution behavior.

##### Substitution Options

| Flag Notation | Decimal | Description |
|---------------|---------|-------------|
| 0b111         | 7       | Substitute all (variables, commands, backslashes) |
| 0b100         | 4       | Only substitute backslashes (-novars -nocommands) |
| 0b010         | 2       | Only substitute variables (-nocommands -nobackslashes) |
| 0b001         | 1       | Only substitute commands (-novars -nobackslashes) |
| 0b000         | 0       | Substitute nothing (-nocommands -novars -nobackslashes) |

##### Examples with Results

Given input: `{a $::X [set x 4] \t}`

| Option        | Result              | Description |
|---------------|--------------------|-------------|
| No substdefault | `a $::X [set x 4] \t` | No substitution |
| :substdefault  | `a 123 4 	` | Default substitution (all) |
| :substdefault=0b111 | `a 123 4 	` | Substitute all |
| :substdefault=0b100 | `a $::X [set x 4] 	` | Only substitute backslashes |
| :substdefault=0b010 | `a 123 [set x 4] \t` | Only substitute variables |
| :substdefault=0b001 | `a $::X 4 \t` | Only substitute commands |
| :substdefault=0b000 | `a $::X [set x 4] \t` | No substitution |

##### Context and Scoping

1. **General Considerations**
   - `[self]` is always set correctly in substdefault expressions

2. **Object Parameters**
   - Use caution when referring to instance variables
   - Referring to global or namespaced variables avoids creation order issues
   - `[current class]` called directly may not return expected results
   - Recommendation: Define methods to get default values instead of direct references

3. **Method Parameters**
   - Instance variables can be referenced directly in the default scope
   - Method frame contains instance variables, allowing direct access

##### Usage Patterns

1. **Referring to Current Object**
```tcl
:property {b:substdefault "[current]"}  # Evaluates to object name
```

2. **Accessing Property Values**
```tcl
:property -accessor public {c 1}
:property {param:substdefault "[:c get]"}  # Access another property's value
```

3. **Accessing Instance Variables**
```tcl
:property {d 2}
:property {param:substdefault "$d"}  # Direct reference to instance variable
```

4. **Accessing Object Variables**
```tcl
:object variable Y 1002
:property {param:substdefault "[:object getvar Y]"}  # Access object variable
```

5. **Accessing Class Information**
```tcl
:property {param:substdefault "[:current class]"}  # Get current class
```

6. **Accessing Namespaced Variables**
```tcl
namespace eval ::my-module { set X 1001 }
:method file-scoped {x} { namespace eval ::my-module [list set $x ] }
:property {param:substdefault "[:file-scoped X]"}  # Access namespaced variable
```

##### Special Cases and Caveats

1. The value of `[current class]` directly in substdefault may not be as expected
   - Use a method that returns `[current class]` instead
   
2. When using substdefault in a namespace:
   - The scope of `[current]` is preserved (e.g., `::my-module::d1`)
   - Definition namespace can be accessed via `[nsf::definitionnamespace]`

3. Dynamic resolution:
   - Variable values are resolved dynamically at the time of evaluation
   - Changes to instance variables are reflected in subsequent evaluations

##### Best Practices

1. Use methods to get default values instead of direct expressions
2. Leverage namespaces for better organization of variables
3. Be aware of the evaluation context when using substdefault
4. Use appropriate substitution flags based on security and performance needs
5. For complex cases, define helper methods that return the appropriate values

#### Private Storage

Private properties are stored in the `__private` array:
```tcl
# Access the private storage (from within a method)
array get :__private
```

#### Property Inheritance

Properties follow inheritance rules:
- Properties defined in a superclass are inherited by subclasses
- Properties from mixins are also available
- Adding a property to a superclass or mixin makes it available to all dependent classes

#### Property Introspection

```tcl
# List available configure options
object info lookup syntax configure

# Check if a property method exists
object info lookup method propertyName

# Get all slots in a class
Class info slots

# Get slot definition
::Class::slot::propertyName definition

# Check property protection level
nsf::method::property Class propertyName call-protected
nsf::method::property Class propertyName call-private

# Check instance variables
object info vars

# Get object slot
object info object slots propertyName

# Get multiplicity of a property
[object info object slots propertyName] eval {set :multiplicity}
```

#### Common Property Patterns

1. Use `-accessor none` when you just need storage without accessors
2. Use `-incremental` for collection properties
3. Use public accessors for properties that need external access
4. Use protected and private for implementation details
5. Use proper type and multiplicity constraints to validate property values
6. Check property existence before access with `exists`
7. Default accessors can be configured globally with `nx::configure defaultAccessor`

### Protection Mechanisms

The NX/NSF system provides comprehensive protection mechanisms for methods and properties, allowing fine-grained control over access and visibility.

#### Access Modifiers

Methods and properties can be declared with different access levels:

```tcl
# Method Declaration with Access Modifiers
:public method methodName {args} {body}      # Public method (default)
:protected method methodName {args} {body}   # Protected method
:private method methodName {args} {body}     # Private method

# Per-object methods
:public object method methodName {args} {body}
:protected object method methodName {args} {body}
:private object method methodName {args} {body}

# Property Declaration with Access Modifiers
:property -accessor public {propertyName defaultValue}     # Public property
:property -accessor protected {propertyName defaultValue}  # Protected property
:property -accessor private {propertyName defaultValue}    # Private property

# Property with value constraint
:property -accessor private {propertyName:type defaultValue}

# Per-object properties
:object property -accessor public {propertyName defaultValue}
:object property -accessor protected {propertyName defaultValue}
:object property -accessor private {propertyName defaultValue}
```

#### Method Property Handling

Methods can have various protection flags that can be checked and modified:

```tcl
# Check if a method is protected
::nsf::method::property ClassName methodName call-protected
# Returns 1 if protected, 0 if not

# Set a method as protected
::nsf::method::property ClassName methodName call-protected true

# Check if a method is private
::nsf::method::property ClassName methodName call-private
# Returns 1 if private, 0 if not

# Set a method as private
::nsf::method::property ClassName methodName call-private true

# Prevent a method from being redefined
::nsf::method::property ClassName methodName redefine-protected true
```

#### Calling Protected and Private Methods

There are several ways to access protected and private methods:

```tcl
# Local Method Access (Within the same class)
: -local privateMethodName arg1 arg2

# Using Method Handles
set handle [ClassName info method registrationhandle methodName]
: $handle arg1 arg2

# Using Dispatch
dispatch [self] [ClassName info method registrationhandle methodName] arg1 arg2

# Calling protected methods with nx::dispatch
nx::dispatch objectName methodName args

# Bypass an overloaded system method
nx::dispatch objectName -system methodName args
```

#### Protection Behavior with Inheritance

1. Public methods in a subclass can access all public methods from superclasses
2. Private methods in a subclass can only be called via `-local` or method handles
3. Private methods do not participate in the `next` chain - they're skipped
4. Protected methods are not callable from outside but are callable from subclasses
5. Private properties in different classes don't conflict, even with the same name

#### Protection with Mixins and Filters

1. Private methods in mixins are invisible to method calls but can be called by other methods in the same mixin
2. Protected and private methods can be used as filters
3. Mixin methods can call protected/private methods from the class they're mixed into
4. Filters run on all methods, including when accessing private methods via `-local`

#### Common Protection Patterns

1. **Private Helper Methods in Mixins**
```tcl
nx::Class create MyMixin {
  :public method publicAPI {} {: -local privateHelper}
  :private method privateHelper {} {
    # Implementation details hidden from users
    return "result"
  }
}
```

2. **Protected Class Hierarchy Methods**
```tcl
nx::Class create Base {
  :protected method implementation {} {
    # Shared with subclasses but not with external callers
    return "base implementation"
  }
  :public method publicAPI {} {: -local implementation}
}

nx::Class create Sub -superclass Base {
  :protected method implementation {} {
    return "Sub [next]"  # Can call protected method in superclass
  }
}
```

3. **Private Object State**
```tcl
nx::Object create obj {
  :object property -accessor private {state initial}
  :public object method getState {} {: -local state get}
  :public object method setState {newValue} {: -local state set $newValue}
}
```

4. **System Method Override with Dispatch**
```tcl
nx::Object create obj {
  :public object method info {} {
    # Custom info implementation
    return "Custom info"
  }
  
  :public object method realInfo {} {
    # Access the actual system info method
    return [nx::dispatch [self] -system info]
  }
}
```

### Method Protection and Visibility

The NX/NSF system provides three levels of method protection to control access and visibility:

```tcl
nx::Class create SecureClass {
    # Public interface - accessible from anywhere
    :public method publicMethod {} {
        return "This is public"
    }
    
    # Protected method - only accessible by class and subclasses
    :protected method protectedMethod {} {
        return "This is protected"
    }
    
    # Private method - only accessible within the class
    :private method privateMethod {} {
        return "This is private"
    }
}
```

#### Protection Levels

1. **Public Methods**
   - Accessible from anywhere
   - Default interface for the class/object
   - Can be called by any other object
   - Example:
   ```tcl
   :public method getData {} {
       return ${:data}
   }
   ```

2. **Protected Methods**
   - Only accessible within the class hierarchy
   - Can be called by the class and its subclasses
   - Useful for internal class operations
   - Example:
   ```tcl
   :protected method validateData {data} {
       if {![::nsf::is valid $data]} {
           error "Invalid data format"
       }
       return $data
   }
   ```

3. **Private Methods**
   - Only accessible within the defining class/object
   - Highest level of encapsulation
   - Cannot be called from outside the class
   - Example:
   ```tcl
   :private method internalHelper {} {
       # Internal implementation details
   }
   ```

#### Best Practices for Method Protection

1. **Interface Design**
   ```tcl
   nx::Class create BankAccount {
       # Public interface
       :public method deposit {amount} {
           :validateAmount $amount
           :updateBalance $amount
       }
       
       # Protected validation
       :protected method validateAmount {amount} {
           if {$amount <= 0} {
               error "Amount must be positive"
           }
       }
       
       # Private implementation
       :private method updateBalance {amount} {
           incr :balance $amount
       }
   }
   ```

2. **Inheritance Considerations**
   ```tcl
   nx::Class create BaseClass {
       :protected method sharedLogic {} {
           # Shared implementation for subclasses
       }
   }
   
   nx::Class create SubClass -superclass BaseClass {
       :public method publicMethod {} {
           :sharedLogic  # Can access protected method
       }
   }
   ```

3. **Encapsulation**
   ```tcl
   nx::Class create DataStore {
       :variable internalData
       
       # Public accessor
       :public method getData {key} {
           :validateKey $key
           return [:retrieveData $key]
       }
       
       # Private implementation
       :private method retrieveData {key} {
           return ${:internalData($key)}
       }
   }
   ```

#### Return Value Checking

NX provides a comprehensive system for checking and validating method return values. This system allows for type checking and conversion of method return values.

##### Basic Configuration

```tcl
# Enable return value checking globally
::nsf::configure checkresult true

# Disable return value checking globally
::nsf::configure checkresults false
```

##### Setting Return Types

Return types can be set in two ways:

1. **For Existing Methods**
```tcl
# Set return type for a method
::nsf::method::property ClassName methodName returns typeName

# Set return type with additional arguments
::nsf::method::property ClassName methodName returns typeName,arg=value

# Enable value conversion for return values
::nsf::method::property ClassName methodName returns typeName,convert

# Remove return type checking
::nsf::method::property ClassName methodName returns ""
```

2. **During Method Declaration**
```tcl
# Method with return type
:method methodName {param1 param2} -returns typeName {
    # method body
}

# Alias with return type
:alias aliasName -returns typeName -frame object ::someCommand

# Forward with return type
:forward forwardName -returns typeName ::someCommand

# Object method with complex return type (object with cardinality)
:public object method methodName {} -returns object,1..n {
    # method body
}
```

##### Built-in Return Types

- `integer`: Checks if return value is an integer
- `object`: Checks if return value is a valid object
- `object,1..n`: Checks if return value is one or more valid objects

##### Custom Return Types

Custom return types can be created using the `::nx::methodParameterSlot` command:

```tcl
::nx::methodParameterSlot object method type=typeName {name value args} {
    # Validation logic
    if {!valid} {
        error "Error message"
    }
    return $value  # Return original or modified value
}
```

Example: Range Type
```tcl
::nx::methodParameterSlot object method type=range {name value arg} {
    lassign [split $arg -] min max
    if {$value < $min || $value > $max} {
        error "Value '$value' of parameter $name not between $min and $max"
    }
    return $value
}

# Usage:
::nsf::method::property ClassName methodName returns range,arg=1-30
```

Example: Value Conversion Type
```tcl
::nx::methodParameterSlot object method type=sex {name value args} {
    switch -glob $value {
        m* {return m}
        f* {return f}
        default {error "expected sex but got $value"}
    }
}

# Usage with conversion:
::nsf::method::property ClassName methodName returns sex,convert
# Now "male" returns as "m", "female" as "f"
```

##### Behavior with Check Results Enabled/Disabled

1. **With `checkresult true`**:
   - Methods with return type constraints will validate return values
   - Return value errors are raised when constraints aren't met
   - Converters with `convert` flag still function

2. **With `checkresult false`**:
   - Type checking is disabled (no errors for invalid return values)
   - Converters with `convert` flag still function (conversion still happens)

##### Method Types Supporting Return Values

- Regular methods (`:method`)
- Object methods (`:object method`)
- Aliases (`:alias`)
- Forwards (`:forward`)

##### Common Error Messages

- `expected integer but got "x" as return value`
- `Value 'x' of parameter return-value not between min and max`
- `expected sex but got x`

##### Testing Return Values

```tcl
# In NX test cases:
? {objectName methodName args} expectedResult
```

##### Notes on Empty Parameter Definitions

- Return value specifications work even with methods that have no parameters
- Setting a return type does not affect the parameter definitions

#### Method Combination with `next`

The `next` command is used to call the next method in the method chain. It is a powerful feature in NX that allows for method chaining and delegation.

```tcl
# Example of method chaining
nx::Object create obj {
    :public method foo {} {
        return "foo"
    }
    
    :public method bar {} {
        return "bar"
    }
}

# Usage
$obj foo
$obj bar
```

### Method Forwarding

The NX/NSF system provides powerful method forwarding capabilities that allow methods to be delegated to other objects or commands:

#### Basic Forward Command Syntax

```tcl
object public [object] forward methodName targetObject|targetCommand [args...]
```

#### Basic Usage Patterns

1. **Simple Delegation**
```tcl
# Delegate method calls to another object
nx::Object create dog
nx::Object create tail {
  :public object method wag args { return $args }
}
dog public object forward wag tail %proc
```

2. **Executing Commands**
```tcl
# Forward to Tcl commands
nx::Object create obj {
  :public object forward addOne expr 1 +
}
# obj addOne 5  -> returns 6
```

#### Special Substitution Variables

| Variable | Description |
|----------|-------------|
| `%self`  | Reference to the current object |
| `%method`| Name of the current method |
| `%proc`  | Refers to the target procedure |
| `%%`     | Literal percent sign |
| `%1`     | First argument or default from list |

#### Forwarding Options

| Option | Description |
|--------|-------------|
| `-frame object` | Execute in object's variable scope |
| `-prefix string` | Add prefix to method name |
| `-verbose` | Enable verbose mode |

#### Positional Substitutions

```tcl
# Add argument at the end
obj public object forward foo list {%@end value}
# obj foo 1 2 3  -> returns [1 2 3 value]

# Add argument at specific position
obj public object forward foo list {%@2 value}
# obj foo 1 2 3  -> returns [1 value 2 3]

# Add argument at beginning
obj public object forward foo list {%@1 value}
# obj foo 1 2 3  -> returns [value 1 2 3]

# Add argument at second-to-last position
obj public object forward foo list {%@-1 value}
# obj foo 1 2 3  -> returns [1 2 value 3]
```

#### Dynamic Command Selection

```tcl
# Choose from multiple methods based on first argument
obj public object forward foo %self {%1 {methodA methodB}}

# With default values
obj public object forward foo %self {%1 {methodA methodB}} {%1 {defaultA defaultB}}
```

#### Argument Count-Based Forwarding

```tcl
nx::Object create obj {
  :public object forward f %self [list %argclindex [list a b c]]
  :object method a args {...}
  :object method b args {...}
  :object method c args {...}
}
# obj f       -> calls method a
# obj f 1     -> calls method b with argument 1
# obj f 1 2   -> calls method c with arguments 1 2
```

#### Introspection

```tcl
# List all forwarders
obj info object methods -type forwarder

# Get forwarder definition
obj info object method definition forwardName
```

#### Variable Scope Access

```tcl
nx::Class create X {
  :property {x 1}
  :public forward Incr -frame object incr
}
# Allows accessing object variables
```

#### Fully-Qualified Target Shortcut

```tcl
# Shortcut for forwarding to a fully-qualified command
obj public object forward ::ns1::foo
```

#### Using Object Variables in Forwarded Commands

```tcl
# Access object variable
obj public object forward x* expr {%:eval {set :x}} *
```

### Ensemble Objects

Ensemble objects provide a way to organize related methods into logical groups, creating a hierarchical command structure:

```tcl
# Create an ensemble object for grouped functionality
nx::Class create Calculator {
    :public object method math.add {a b} {
        return [expr {$a + $b}]
    }
    
    :public object method math.subtract {a b} {
        return [expr {$a - $b}]
    }
    
    :public object method math.multiply {a b} {
        return [expr {$a * $b}]
    }
}

# Usage
Calculator math add 5 3
Calculator math subtract 10 4
```

#### Ensemble Features

1. **Logical Grouping**
   ```tcl
   nx::Class create FileManager {
       # File operations
       :public object method file.open {filename} {
           return [open $filename r]
       }
       
       :public object method file.close {handle} {
           close $handle
       }
       
       # Directory operations
       :public object method dir.create {path} {
           file mkdir $path
       }
       
       :public object method dir.delete {path} {
           file delete $path
       }
   }
   
   # Usage
   FileManager file open "example.txt"
   FileManager dir create "new_folder"
   ```

2. **Nested Ensembles**
   ```tcl
   nx::Class create Database {
       # Connection management
       :public object method connection.open {dbname} {
           return [::db::connect $dbname]
       }
       
       # Query operations
       :public object method query.execute {sql} {
           return [::db::execute $sql]
       }
       
       # Transaction management
       :public object method transaction.begin {} {
           ::db::begin
       }
       
       :public object method transaction.commit {} {
           ::db::commit
       }
   }
   
   # Usage
   Database connection open "mydb"
   Database query execute "SELECT * FROM users"
   Database transaction begin
   ```

3. **Dynamic Ensemble Creation**
   ```tcl
   nx::Class create DynamicEnsemble {
       :public object method add {subcommand method} {
           :public object method $subcommand {args} $method
       }
   }
   
   # Usage
   DynamicEnsemble add "greet" {puts "Hello, World!"}
   DynamicEnsemble greet
   ```

#### Best Practices for Ensembles

1. **Clear Naming**
   ```tcl
   nx::Class create ConfigManager {
       # Use descriptive subcommand names
       :public object method config.load {filename} {
           source $filename
       }
       
       :public object method config.save {filename} {
           # Save configuration
       }
   }
   ```

2. **Consistent Structure**
   ```tcl
   nx::Class create Logger {
       # Group related operations
       :public object method log.info {message} {
           puts "INFO: $message"
       }
       
       :public object method log.error {message} {
           puts "ERROR: $message"
       }
       
       :public object method log.debug {message} {
           puts "DEBUG: $message"
       }
   }
   ```

3. **Error Handling**
   ```tcl
   nx::Class create SafeEnsemble {
       :public object method operation.perform {args} {
           try {
               # Perform operation
               return [eval $args]
           } trap {NSF LOOKUP METHOD} {err opts} {
               error "Unknown operation: [lindex $args 0]"
           }
       }
   }
   ```

### Object Copying

The NX/NSF system provides powerful object copying capabilities that allow you to create duplicates of objects with various options:

```tcl
# Create an original object
nx::Class create Template {
    :property name
    :property config
    
    :method init {} {
        :configure -name "Default"
        :configure -config {color blue size large}
    }
}

# Create and copy objects
set original [Template new]
set copy [$original copy]

# Copy with new name
set namedCopy [$original copy "myNewTemplate"]
```

#### Copying Features

1. **Basic Object Copying**
   ```tcl
   nx::Class create DataObject {
       :property data
       
       :method init {} {
           :configure -data {}
       }
   }
   
   # Create and copy
   set obj1 [DataObject new -data {1 2 3}]
   set obj2 [$obj1 copy]
   ```

2. **Deep Copying**
   ```tcl
   nx::Class create Container {
       :property -incremental {items:object,*}
       
       :method copy {?newName?} {
           set new [next]
           foreach item [:get items] {
               $new items add [$item copy]
           }
           return $new
       }
   }
   ```

3. **Selective Copying**
   ```tcl
   nx::Class create Configurable {
       :property name
       :property settings
       :property internal
       
       :method copy {?newName?} {
           set new [next]
           # Only copy specific properties
           $new configure -name [:get name]
           $new configure -settings [:get settings]
           return $new
       }
   }
   ```

#### Copying Best Practices

1. **Property Handling**
   ```tcl
   nx::Class create ComplexObject {
       :property data
       :property metadata
       
       :method copy {?newName?} {
           set new [next]
           # Handle each property appropriately
           $new configure -data [:get data]
           $new configure -metadata [dict create {*}[dict get [:get metadata] copy]]
           return $new
       }
   }
   ```

2. **Relationship Management**
   ```tcl
   nx::Class create Parent {
       :property -incremental {children:object,*}
       
       :method copy {?newName?} {
           set new [next]
           # Copy relationships
           foreach child [:get children] {
               $new children add [$child copy]
           }
           return $new
       }
   }
   ```

3. **Resource Management**
   ```tcl
   nx::Class create ResourceHolder {
       :variable resourceHandle
       
       :method copy {?newName?} {
           set new [next]
           # Create new resource handle
           set newHandle [::resource::create]
           $new configure -resourceHandle $newHandle
           return $new
       }
   }
   ```

#### Common Copying Patterns

1. **Template-Based Copying**
   ```tcl
   nx::Class create DocumentTemplate {
       :property content
       :property style
       
       :method createFromTemplate {name} {
           set new [:copy $name]
           $new configure -content [:get content]
           return $new
       }
   }
   ```

2. **Configuration Copying**
   ```tcl
   nx::Class create ConfigurableObject {
       :property settings
       
       :method copyWithSettings {newName settings} {
           set new [:copy $newName]
           $new configure -settings $settings
           return $new
       }
   }
   ```

3. **State Preservation**
    ```tcl
    nx::Class create StatefulObject {
        :variable state
        
        :method copy {?newName?} {
            set new [next]
            # Preserve state
            $new configure -state [:get state]
            return $new
        }
    }
    ```

### Serialization

The NX/NSF system provides comprehensive serialization capabilities through the `nx::serializer` package, allowing objects to be converted to and from a serialized format.

#### Basic Serialization

```tcl
# Serialize an object
set script [object serialize]

# Eval the script to recreate the object
eval $script
```

#### Target Mapping

```tcl
# Serialize an object with a target mapping (different name/namespace)
set script [object serialize -target NewObjectName]

# The serialized object will be created with the new target name
eval $script
```

#### Deep Serialization

```tcl
# Serialize an object and all its children
set script [::Serializer deepSerialize object]

# Recreate the object hierarchy
eval $script
```

#### Name Mapping in Deep Serialization

```tcl
# Remap object names during serialization
set script [::Serializer deepSerialize -map {::old::name ::new::name} object]

# Example with multiple mappings
set script [::Serializer deepSerialize -map {::a::b ::x::y ::a ::x} ::a]
```

#### Variable Filtering

```tcl
# Ignore no variables (serialize all)
set script [::Serializer deepSerialize -ignoreVarsRE "" object]

# Ignore variables matching a pattern
set script [::Serializer deepSerialize -ignoreVarsRE "pattern" object]

# Ignore all variables
set script [::Serializer deepSerialize -ignoreVarsRE "." object]

# Specific variable filtering examples:
# Ignore variables ending with 'a'
set script [::Serializer deepSerialize -ignoreVarsRE {::a$} object]

# Exclude specific slot names
set names {}
foreach s [Class info slots] {
  lappend names [$s cget -name]
}
set script [::Serializer deepSerialize -ignoreVarsRE [join $names |] object]
```

#### Object Exclusion

```tcl
# Serialize a parent object but exclude a specific child
set script [::Serializer deepSerialize -ignore ::parent::child ::parent]
```

#### Slot Container Preservation

Serialization preserves slot containers and their relationships:

```tcl
# Class with properties
nx::Class create C {
  :object property x
  :property a
}

# Serializing preserves slot containers
set script [C serialize]
```

#### Property Preservation

Serialization preserves important object properties:

```tcl
# Set object properties
::nsf::object::property ::object keepcallerself 1
::nsf::object::property ::object perobjectdispatch 1

# Properties are preserved after serialization
set script [object serialize]
```

#### Method Property Preservation

Method properties like `-debug` and `-deprecated` are preserved:

```tcl
# Define methods with properties
nx::Object create o {
  :public object method -deprecated method1 {} {return 1}
  :public object method -debug method2 {} {return 1}
  :public alias -deprecated -debug aliasName ::command
}

# Properties are preserved after serialization
set script [o serialize]
```

#### Method Serialization

```tcl
# Serialize a specific method
set script [::Serializer methodSerialize object methodName ""]
```

#### Integration with XOTcl

```tcl
# XOTcl compatibility
package require XOTcl
package require xotcl::serializer

# Serialize XOTcl class info
::Serializer methodSerialize ::xotcl::classInfo default ""
```

#### Best Practices for Serialization

1. Always check if the serialized object exists after deserialization:
   ```tcl
   ? {::nsf::object::exists ::object} 1
   ```

2. Verify that properties and relationships are preserved:
   ```tcl
   ? {::nsf::method::property object method property} value
   ? {::nsf::var::get object::slot property} value
   ```

3. For renaming/remapping objects, use the `-map` option with the `-target` option as needed

4. Use `-ignore` to exclude specific objects from serialization

5. Use `-ignoreVarsRE` with regular expressions to filter which variables are serialized

#### Troubleshooting Serialization

- Check if the object hierarchy is correctly serialized with `::nsf::object::exists`
- Verify slot containers are preserved in classes with `::nx::isSlotContainer`
- Test forwarder targets after serialization with `nsf::method::forward::property`

### Advanced Features

The NX/NSF system provides several advanced features for meta-programming and event handling:

#### Meta-Programming

```tcl
nx::Class create MetaExample {
    # Add methods dynamically
    :public method addMethod {name body} {
        :public method $name {} $body
    }
    
    # Introspection
    :public method listMethods {} {
        return [:info methods]
    }
}

# Usage
set obj [MetaExample new]
$obj addMethod newMethod {return "Dynamic method"}
puts [$obj listMethods]
```

#### Event Handling

```tcl
nx::Class create Observable {
    :property -incremental {observers:object,*}
    
    :method notify {event args} {
        foreach observer [:get observers] {
            $observer update $event {*}$args
        }
    }
}
```

#### Design Patterns

1. **Singleton Pattern**
   ```tcl
   nx::Class create Singleton {
       :property instance:object,0..1
       
       :public object method getInstance {} {
           if {![info exists :instance]} {
               set :instance [:new]
           }
           return ${:instance}
       }
   }
   ```

2. **Factory Pattern**
   ```tcl
   nx::Class create ShapeFactory {
       :public object method create {type args} {
           switch $type {
               "circle" {
                   return [Circle new {*}$args]
               }
               "rectangle" {
                   return [Rectangle new {*}$args]
               }
               default {
                   error "Unknown shape type: $type"
               }
           }
       }
   }
   ```

#### Advanced Meta-Programming Examples

1. **Dynamic Method Creation**
   ```tcl
   nx::Class create DynamicClass {
       :public method addMethod {name args body} {
           :public method $name $args $body
       }
       
       :public method addProperty {name defaultValue} {
           :property [list $name $defaultValue]
       }
   }
   
   # Usage
   set obj [DynamicClass new]
   $obj addMethod greet {puts "Hello, World!"}
   $obj addProperty age 0
   ```

2. **Method Wrapping**
   ```tcl
   nx::Class create MethodWrapper {
       :public method wrapMethod {obj methodName wrapper} {
           set original [::nsf::method::body $obj $methodName]
           ::nsf::method::create $obj $methodName [subst {
               $wrapper
               $original
           }]
       }
   }
   
   # Usage
   set wrapper [MethodWrapper new]
   $wrapper wrapMethod $obj methodName {
       puts "Before method call"
   }
   ```

3. **Property Observer**
   ```tcl
   nx::Class create PropertyObserver {
       :public method observeProperty {obj propertyName callback} {
           ::nsf::property::setter $obj $propertyName [subst {
               set oldValue [::nsf::property::get [self] $propertyName]
               ::nsf::property::set [self] $propertyName \$value
               $callback [self] $propertyName \$oldValue \$value
           }]
       }
   }
   
   # Usage
   set observer [PropertyObserver new]
   $observer observeProperty $obj value {
       puts "Property changed from $oldValue to $newValue"
   }
   ```

4. **Class Mixin Manager**
   ```tcl
   nx::Class create MixinManager {
       :public method addMixin {obj mixin} {
           ::nsf::object::mixin add $obj $mixin
       }
       
       :public method removeMixin {obj mixin} {
           ::nsf::object::mixin remove $obj $mixin
       }
       
       :public method getMixins {obj} {
           ::nsf::object::mixin get $obj
       }
   }
   
   # Usage
   set manager [MixinManager new]
   $manager addMixin $obj LoggingMixin
   $manager addMixin $obj ValidationMixin
   ```

5. **Method Profiler**
    ```tcl
    nx::Class create MethodProfiler {
        :variable timings
        
        :public method profileMethod {obj methodName} {
            set original [::nsf::method::body $obj $methodName]
            ::nsf::method::create $obj $methodName [subst {
                set start [clock microseconds]
                set result [uplevel 1 $original]
                set end [clock microseconds]
                set duration [expr {$end - $start}]
                lappend :timings($methodName) $duration
                return \$result
            }]
        }
        
        :public method getStats {methodName} {
            if {![info exists :timings($methodName)]} {
                return "No data for $methodName"
            }
            set times ${:timings($methodName)}
            set avg [expr {[tcl::mathop::+ {*}$times] / [llength $times]}]
            return "Average time: ${avg}μs"
        }
    }
    
    # Usage
    set profiler [MethodProfiler new]
    $profiler profileMethod $obj expensiveMethod
    puts [$profiler getStats expensiveMethod]
    ```

### Best Practices

The NX/NSF system provides powerful features, but following best practices is essential for maintainable and efficient code:

#### 1. Object System Design

1. **Clear Hierarchy**
   ```tcl
   # Define clear class hierarchies
   nx::Class create Animal {
       :property name
       :property age
   }
   
   nx::Class create Mammal -superclass Animal {
       :property furColor
   }
   
   nx::Class create Dog -superclass Mammal {
       :property breed
   }
   ```

2. **Method Organization**
   ```tcl
   nx::Class create WellOrganized {
       # Public interface
       :public method publicMethod {} {
           :validateInput
           :processData
           :updateState
       }
       
       # Protected helpers
       :protected method validateInput {} {
           # Validation logic
       }
       
       # Private implementation
       :private method processData {} {
           # Processing logic
       }
   }
   ```

3. **Type Safety**
   ```tcl
   nx::Class create TypeSafe {
       :property {age:integer 0}
       :property {name:string}
       :property {active:boolean true}
       
       :method validateAge {age} {
           if {$age < 0 || $age > 150} {
               error "Invalid age: $age"
           }
           return $age
       }
   }
   ```

#### 2. Meta-Programming

1. **Introspection**
   ```tcl
   # Cache introspection results
   nx::Class create EfficientClass {
       :variable methodCache
       
       :method getMethods {} {
           if {![info exists :methodCache]} {
               set :methodCache [:info methods]
           }
           return ${:methodCache}
       }
   }
   ```

2. **Dynamic Features**
   ```tcl
   nx::Class create DynamicFeatures {
       :variable generatedMethods
       
       :method addDynamicMethod {name body} {
           if {[info exists :generatedMethods($name)]} {
               error "Method $name already exists"
           }
           :public method $name {} $body
           set :generatedMethods($name) 1
       }
   }
   ```

3. **Aspect-Oriented**
   ```tcl
   nx::Class create AspectOriented {
       :method addLogging {methodName} {
           set original [::nsf::method::body [self] $methodName]
           ::nsf::method::create [self] $methodName [subst {
               puts "Entering $methodName"
               set result [uplevel 1 $original]
               puts "Exiting $methodName"
               return \$result
           }]
       }
   }
   ```

#### 3. Error Handling

1. **Error Prevention**
   ```tcl
   nx::Class create SafeClass {
       :method configure {args} {
           if {[catch {next} result]} {
               error "Configuration failed: $result"
           }
           return $result
       }
   }
   ```

2. **Error Recovery**
   ```tcl
   nx::Class create ResilientClass {
       :method performOperation {} {
           try {
               :validateState
               :executeOperation
           } finally {
               :cleanup
           }
       }
   }
   ```

3. **Error Reporting**
   ```tcl
   nx::Class create InformativeClass {
       :method handleError {operation error} {
           puts "Error in $operation: $error"
           puts "Stack trace: [info stacktrace]"
           error $error
       }
   }
   ```

#### 4. Performance Optimization

1. **Method Caching**
   ```tcl
   nx::Class create CachedClass {
       :variable cache
       
       :method expensiveOperation {args} {
           set key [join $args ","]
           if {[info exists :cache($key)]} {
               return ${:cache($key)}
           }
           set result [next]
           set :cache($key) $result
           return $result
       }
   }
   ```

2. **Resource Management**
   ```tcl
   nx::Class create ResourceManager {
       :variable resources
       
       :method acquire {resource} {
           if {![info exists :resources($resource)]} {
               set :resources($resource) [::resource::create $resource]
           }
           return ${:resources($resource)}
       }
       
       :method release {resource} {
           if {[info exists :resources($resource)]} {
               ::resource::destroy ${:resources($resource)}
               unset :resources($resource)
           }
       }
   }
   ```

3. **Memory Management**
   ```tcl
   nx::Class create MemoryEfficient {
       :method cleanup {} {
           foreach var [info vars :*] {
               if {[info exists $var]} {
                   unset $var
               }
           }
       }
   }
   ```

## NSF Core Architecture

### Foundation Components

The NSF system is built on three fundamental components that work together to provide a robust object-oriented programming environment:

1. **NsfObject**
   - Core object representation
   - Contains command name, namespace, and class references
   - Manages instance variables and method dispatch

2. **NsfClass**
   - Class representation
   - Manages superclass/subclass relationships
   - Handles method resolution order
   - Controls instance creation and initialization

3. **NsfObjectSystem**
   - Container for classes and objects
   - Manages root class and meta-class
   - Controls object system lifecycle

### Plain Object Method Package

The `nx::plain-object-method` package provides a convenience layer for Next Scripting Framework (NX) that enables object-oriented functionality directly on plain objects. This package is essential for working with plain objects in NX.

#### Loading and Configuration

```tcl
# Load the package
package require nx::plain-object-method

# Configure warnings
nx::configure plain-object-method-warning on  # Enable warnings
nx::configure plain-object-method-warning off # Disable warnings
```

#### Object Creation and Methods

```tcl
# Create a basic object
nx::Object create ::o {
    # Define methods, properties, and variables here
}

# Define methods with different protection levels
nx::Object create ::o {
    # Public method
    :public method foo {} {return foo}
    
    # Protected method
    :protected method pm1 args {return pm1}
    
    # Private method
    :private method priv args {return priv}
    
    # Default method (protected)
    :method pm2 args {return pm2}
    
    # Object method
    :public object method f args {next}
}
```

#### Method Aliases and Forwarding

```tcl
nx::Object create ::o {
    # Create an alias to another method
    :public alias a ::o::pm1
    
    # Create a forwarding method
    :public forward fwd %self pm1
}
```

#### Properties and Variables

```tcl
nx::Object create ::o {
    # Property with public accessor
    :property -accessor public p
    
    # Simple variable
    :variable v1 1
    
    # Incremental variable with type constraint
    :variable -incremental v2:integer 1
}
```

#### Mixins and Filters

```tcl
# Create a mixin class
nx::Class create M1

# Set a mixin
o mixins set M1

# Check mixins
o info mixins

# Clear mixins
o mixins set ""

# Set a filter
o filters set f

# Check filters
o info filters

# Clear filters
o filters set ""
```

#### Information Retrieval

```tcl
# List all methods
o info methods

# List methods with specific protection level
o info methods -callprotection protected
o info methods -callprotection private

# List object methods
o info object methods

# List all variables
o info variables

# List object variables
o info object variables

# List all slots (variables and properties)
o info slots
```

#### Method and Property Management

```tcl
# Delete a method
o delete method foo

# Delete a property
o delete property p

# Delete a variable
o delete variable v1
```

#### Advanced Features

```tcl
# Provide a method implementation
nsf::method::provide set {::nsf::method::alias set -frame object ::set}

# Require a method in an object
nx::Object create ::o {
    :require method set
}
```

#### Behavior Without Plain-Object-Method

Without loading the `nx::plain-object-method` package, the following operations fail:
- `o public method foo {}`
- `o mixins set M1`
- `o filters set f`

After loading the package, these operations become available to plain objects.

### Runtime Assertion Checking (RAC)

Runtime Assertion Checking (RAC) is a powerful feature in NX that allows for runtime validation of correctness conditions, based on the conceptual baseline of the Eiffel specification (ECMA Standard 367, 2nd edition, 2006).

#### Basic Concepts

RAC in NX implements several key assertion types:
- **Class invariants**: Conditions that must hold true for all instances of a class
- **Object invariants**: Conditions that must hold true for a specific object
- **Preconditions**: Conditions that must be true before a method executes
- **Postconditions**: Conditions that must be true after a method executes

#### Assertion Types and Syntax

1. **Class Invariants**
```tcl
nx::Class create MyClass -invariant {
  {# invariant_name: }
  {${:property1} >= ${:property2}}
} {
  # class definition...
}
```

2. **Object Invariants**
```tcl
MyObject configure -object-invariant {
  {${:property} > 0}
}
```

3. **Method Preconditions and Postconditions**
```tcl
MyClass public method myMethod {} {
  # method body
} -precondition {
  {# pre_condition_name: }
  {${:property} > 0}
} -postcondition {
  {# post_condition_name: }
  {${:property} > ${:anotherProperty}}
}
```

#### Setting Up Assertions

1. **Class Invariants**
```tcl
# Direct interface
::nsf::method::assertion MyClass class-invar $invariantList

# Object interface
MyClass configure -invariant $invariantList
```

2. **Object Invariants**
```tcl
# Direct interface
::nsf::method::assertion myObject object-invar $invariantList

# Object interface
myObject configure -object-invariant $invariantList
```

3. **Reading Invariants**
```tcl
# Get class invariant
MyClass cget -invariant

# Get object invariant
myObject cget -object-invariant
```

#### Activating/Deactivating Assertions

Assertions can be selectively activated or deactivated:

```tcl
# Activate all assertions for an object
::nsf::method::assertion myObject check all

# Activate only preconditions
::nsf::method::assertion myObject check pre

# Activate only postconditions
::nsf::method::assertion myObject check post

# Activate only class invariants
::nsf::method::assertion myObject check class-invar

# Deactivate all assertions for an object
::nsf::method::assertion myObject check {}
```

#### Assertion Evaluation Order

The actual evaluation order in NX:
```
Entry -> PRE -> INVAR -> (METHOD BODY) -> POST -> INVAR -> Exit
```

Expected order according to ECMA-367 §8.23.26:
```
Entry -> INVAR -> PRE -> (METHOD BODY) -> INVAR -> POST -> Exit
```

#### Inheritance and Assertions

1. **Invariants**
- Child class invariants include parent invariants
- Invariants are joined with logical AND
- Parent clauses take precedence in reverse linearization order

2. **Preconditions**
- Preconditions should weaken in subclasses
- Preconditions are joined with logical OR
- Parent clauses take precedence in reverse linearization order
- The rule for preconditions is "require else" (OR joining)

3. **Postconditions**
- Postconditions should strengthen in subclasses
- Postconditions are joined with logical AND
- Parent clauses take precedence in reverse linearization order
- The rule for postconditions is "ensure then" (AND joining)

4. **Shadowing Methods**
- Using `next` ensures proper execution of parent assertions
- Without `next`, parent assertions may not be properly executed

#### Limitations and Issues

1. Error reporting does not clearly distinguish between assertion failures and underlying errors
2. When invariant assertions fail, the object state might still be modified effectively
3. Class invariants are not evaluated after instance creation by default
4. The order of resolution for class invariants in the inheritance hierarchy is not always correct
5. Class invariants are not checked before preconditions as expected by the Eiffel specification
6. Proper access to method arguments in assertion expressions is needed
7. Parameter type checks should be performed before precondition and invariant checks
8. Error messages can be misleading ("in proc 'v'" for invariant failures)

#### Usage Examples

1. **Basic Class with Invariant**
```tcl
nx::Class create Account -invariant {
  {# sufficient_balance: }
  {${:balance} >= ${:minimumBalance}}
} {
  :property -accessor public balance:integer
  :property -accessor public minimumBalance:integer
}
```

2. **Method with Preconditions and Postconditions**
```tcl
Account public method deposit {sum:integer} {
  incr :depositTransactions
  incr :balance $sum
} -precondition {
  {# deposit_positive: }
  {$sum > 0}
} -postcondition {
  {# balance_increased: }
  {${:balance} > 0}
}
```

3. **Inheritance Example**
```tcl
nx::Class create SavingsAccount -superclass Account -invariant {
  {# minimum_deposit: }
  {${:minimumBalance} > 100}
}
```

#### References

- ECMA Standard 367, 2nd edition (2006): https://www.ecma-international.org/publications/files/ECMA-ST/ECMA-367.pdf

### The nxsh Shell and Testing Framework

The nxsh shell is a Tcl shell with Next Scripting Framework extensions, providing a command-line interface for NX/NSF development and testing.

#### Environment Requirements

- Non-Windows platforms (tests skip on Windows environments without bash-like shells)
- NSF compiled without memcount (tests skip when `$::nsf::config(memcount) == 1`)

#### Shell Initialization

```tcl
set rootDir [file join {*}[lrange [file split [file normalize [info script]]] 0 end-2]]
set nxsh [file join $rootDir nxsh]
```

#### Command Line Usage Patterns

1. **Interactive Mode**
   ```tcl
   nxsh  # Launches interactive shell
   # Test: exec $nxsh << "$run; exit" produces expected output
   ```

2. **Script Execution**
   ```tcl
   nxsh script.tcl  # Executes a Tcl script with nxsh
   nxsh script.tcl arg1 arg2 ...  # Passes arguments to script
   # Script access to args: $argc (count), $argv (list of arguments)
   ```

3. **Command Execution (-c option)**
   ```tcl
   nxsh -c "command"  # Executes a single command
   nxsh -c "command" arg1 arg2 ...  # Executes command with arguments
   nxsh -c << "command"  # Executes command from stdin
   ```

#### Test Framework

The nxsh shell testing framework is implemented using the `nx::test` framework and consists of a single test case called `nxsh`.

##### Test Cases

1. **File Operations**
   - Verifies nxsh executable exists and is executable
   - Tests temporary file creation and execution
   - Tests error handling for non-existent files

2. **Command Line Arguments**
   - Checks argument passing and handling
   - Tests `$argc` and `$argv` handling

3. **Exit Code Handling**
   ```tcl
   exit 0  # Normal exit, no error
   exit 1  # Abnormal exit, error reported
   exit 2  # Abnormal exit, error reported
   ```

4. **Error Handling**
   - Tests try/catch behavior with exit codes
   - Tests error handling within nx::Object contexts
   - Tests finally block execution

##### Utility Functions

```tcl
# Extract first line of command output
proc getFirstLine {cmd} {
  catch [list uplevel 1 $cmd] res opts
  set lines [split $res \n]
  return [string trim [lindex $lines 0]]
}
```

##### Test Syntax

- `?` command is used for assertions
- Format: `? [test-command] expected-result`

##### Platform-Specific Notes

- Compatible with Tcl 8.6 or newer for certain features
- Uses shell I/O redirection (`<<`) to provide input to nxsh
- Special handling for stderr with `-ignorestderr` option

##### Common Test Patterns

1. **Error Testing**
   ```tcl
   ? [list exec $nxsh -c "exit 1"] "child process exited abnormally"
   ```

2. **Command Execution Testing**
   ```tcl
   ? [list exec $nxsh -c $run a b c] "3-a-b-c"
   ```

3. **File Existence**
   ```tcl
   ? [list file exists $nxsh] 1
   ```

##### Error Code Extraction

```tcl
? [list catch [list exec $nxsh -c "exit 5"] ::res ::opts] "1"
? {set ::res} "child process exited abnormally"
? {lindex [dict get $::opts -errorcode] end} "5"
```

### Submethods

Submethods in NX (Next Scripting Framework) are hierarchical method structures that allow creating command ensembles with multiple levels of dispatch. This section covers the key concepts, syntax, and behaviors of submethods.

#### Basic Syntax

```tcl
# Define a submethod with space-separated path components
:object method "string length" x {return [current method]}
:object method "foo a x" {} {return [current method]}

# For class methods
:method "bar m1" {a:integer -flag} {;}
:method "baz a m1" {x:integer -y:boolean} {return m1}
```

#### Calling Submethods

```tcl
# Standard submethod call
obj foo a x

# Using colon notation for object-local calls
obj eval { :foo a x }

# Using colon prefix (alternative syntax)
obj eval { : foo a x }

# Local call with -local flag (for private methods)
obj eval { : -local foo a x }
```

#### Error Handling and Discovery

When a submethod cannot be found, NX provides helpful error messages:

```
unable to dispatch sub-method "z" of ::obj foo a; valid are: foo a defaultmethod, foo a subcmdName, foo a unknown, foo a x, foo a y
```

To list available submethods:

```tcl
# Returns: "valid submethods of ::obj string: info length tolower"
obj string

# Use lsort to get an alphabetical list of available submethods
lsort [obj info has]
```

#### Introspection in Submethods

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

# Get the calling class
[current callingclass]

# Get the calling object
[current callingobject]

# Get the calling method
[current callingmethod]

# Get the next method in the chain
[current nextmethod]

# Check if current call is from next
[current isnextcall]

# Get the method that was called
[current calledmethod]

# Get the class of the called method
[current calledclass]
```

#### Using `next` with Submethods

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

A "leaf next" is a next call at the end of the method resolution chain:

```tcl
:public object method "FOO bar" {} {
  incr :x; next;  # a "leaf next" - won't trigger unknown handling
}
```

#### Method Protection and Visibility

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

#### Variable Access in Ensemble Methods

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

#### Method Forwarding with Submethods

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

#### Object Properties Affecting Submethod Behavior

##### keepcallerself

Controls whether `[self]` refers to the caller or the called object in forwarded calls:

```tcl
# Set keepcallerself
::nsf::object::property ::some_obj keepcallerself true

# When true: the self in called methods is the caller
# When false: the self in called methods is the invoked object
```

##### perobjectdispatch

Controls whether instance methods are accessible via object-specific forwarding:

```tcl
# Set perobjectdispatch
::nsf::object::property ::some_obj perobjectdispatch true

# When true: instance methods are not accessible via object forwarding
# When false: instance methods are accessible via object forwarding
```

#### Best Practices for Submethods

1. Use submethods to create logical hierarchies of commands
2. Use the `:` prefix with `-local` for calling private submethods: `: -local private_method`
3. Be aware of `keepcallerself` and `perobjectdispatch` settings when forwarding methods
4. Use `[current methodpath]` to get the full path of the current method
5. Leverage error messages to provide information about available submethods
6. Use `:upvar` instead of `upvar` when accessing variables across ensemble boundaries
7. Consider using private submethods as internal helpers to maintain clean interfaces
8. Be careful with method names that might conflict with Tcl commands or ensemble internals
9. Standardize your ensemble hierarchies for consistency across your codebase

#### Common Pitfalls

1. Cannot overwrite a simple method with a submethod (or vice versa)
2. Submethods are sensitive to protection modifiers (public, private, protected)
3. When using `next` in submethods, be aware of the method resolution path
4. Ensure proper handling of arguments when forwarding to submethods
5. Regular `upvar` doesn't work across ensemble boundaries - use `:upvar` instead
6. Method path reporting in error messages may be confusing at first
7. `keepcallerself` without `perobjectdispatch` can lead to unexpected behavior
8. Namespace conflicts between child objects and methods with the same name
```

#### Apply Function

The NX/NSF system provides powerful support for the apply function, enabling functional programming patterns:

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

#### Command Resolution and Namespaces

The NX/NSF system provides sophisticated command resolution mechanisms, especially when dealing with special characters and namespaces:

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

##### Understanding Command Types
```tcl
proc getType {x} {dict get [::nsf::__db_get_obj @] type}

# Types can be empty, cmdName or bytecode depending on context
getType @   # May show "", "cmdName", or "bytecode"

# Command resolution transformation
namespace origin @  # Converts from bytecode to cmdName
```

##### Interpreter Aliases
```tcl
proc ::@@ {} {return ::@@}
proc ::nx::@ {} {return ::nx::@}

interp alias {} ::nx::@ {} ::@@

# After aliasing, resolution follows the alias
::nx::@  # Returns ::@@
```

#### Testing Framework

The NX/NSF system includes a powerful testing framework that enables systematic testing of NX applications and components.

##### NX Test Case Structure
```tcl
nx::test case case-name {
  # Setup code
  
  # Tests with '?' operator
  ? {expression} expected-result
  
  # Cleanup code
}
```

##### Test Assert Operator
The `?` operator evaluates an expression and compares it against the expected result:

```tcl
? {set a 5} 5  # Pass
? {expr {2+2}} 4  # Pass
? {some-command} expected-output  # Pass if output matches
```

##### Version-Specific Testing
```tcl
# Skip tests if requirement not met
if {![package vsatisfies [package req Tcl] 8.6.7]} {return}

# Version-specific test branches
set tcl87 [package vsatisfies [package req Tcl] 8.7-]
if {!$::tcl87} {
    # Tcl 8.6-specific tests
}
```

### Method Visibility Control

The NX/NSF system provides mechanisms to control method visibility and accessibility through `export` and `unexport` features. This section explains their behavior and usage patterns.

#### Key Concepts

1. **Export**
   - Makes methods visible and accessible from outside the object/class
   - Adds the PUBLIC_METHOD flag to a method's C-level representation
   - Methods become callable directly on an object without using self-sends

2. **Unexport**
   - Makes methods invisible and inaccessible from outside the object/class
   - Removes the PUBLIC_METHOD flag from a method's C-level representation
   - Methods become callable only through self-sends (using `my` command)

#### Basic Usage

```tcl
# Export an object method
$object export methodName

# Unexport an object method
$object unexport methodName

# Export a class method
$class export methodName

# Unexport a class method
$class unexport methodName
```

#### Export Behaviors

1. **Exporting Existing Methods**
   ```tcl
   # Create an object with a protected method
   set o [nx::Object new]
   $o object method Foo {} { return [::nsf::current method] }
   
   # Method is not accessible directly
   $o Foo        # Error: unable to dispatch method
   $o eval {:Foo}  # Works: Self-send succeeds
   
   # After export, method becomes accessible
   $o export Foo
   $o Foo        # Now works
   ```

2. **Preemptive Export**
   ```tcl
   # Export a non-existent method
   $o export bar
   
   # Still fails because no implementation exists
   $o bar        # Error: unable to dispatch method
   ```

3. **Per-Class Method Export**
   ```tcl
   # From an instance
   $instance export methodName  # Makes method accessible on this instance
   
   # From the class
   $class export methodName     # Makes method accessible on all instances
   
   # From a subclass
   $subclass export methodName  # Makes method accessible on subclass instances
   ```

#### Unexport Behaviors

1. **Unexporting Existing Methods**
   ```tcl
   # Create object with public method
   set o [nx::Object new]
   $o public object method foo {} { return [::nsf::current method] }
   
   # Method is accessible
   $o foo        # Works
   
   # After unexport, method is protected
   $o unexport foo
   $o foo        # Error: unable to dispatch method
   $o eval {:foo}  # Still works through self-send
   ```

2. **Unexporting Inherited Methods**
   ```tcl
   # Create class with public method
   Class create C {
     :public method foo {} {return ok}
   }
   
   # Create instance
   set c [C new]
   $c foo        # Works
   
   # After unexport, method is inaccessible
   $c unexport foo
   $c foo        # Error: unable to dispatch method
   ```

#### Advanced Use Cases

1. **Abstract Classes**
   ```tcl
   # Create abstract class by unexporting instance creation methods
   nx::Class create AbstractQueue {
     :method enqueue item {
       error "not implemented"
     }
     :method dequeue {} {
       error "not implemented"
     }
     
     :class unexport create new  # Prevent direct instantiation
   }
   
   # Cannot create instances directly
   AbstractQueue new           # Error: method unknown
   AbstractQueue create aQueue # Error: method unknown
   ```

2. **Selective Method Exposure**
   ```tcl
   Class create ChildClass -superclass ParentClass {
     :export parentProtectedMethod  # Expose inherited protected method
   }
   ```

#### Common Patterns

1. **Protected Methods by Default**
   ```tcl
   Class create MyClass {
     :method protectedMethod {} { return "protected" }
     :public method publicMethod {} { return "public" }
   }
   ```

2. **Creating Abstract Classes**
   ```tcl
   Class create AbstractClass {
     :class unexport new create  # Prevent direct instantiation
   }
   ```

### Traits

Traits provide a mechanism for code reuse in the NX framework, allowing classes to inherit methods from multiple traits. This is similar to mixins or interfaces in other languages, but with added capabilities.

#### Basic Concepts

```tcl
# Create a trait
nx::Trait create <trait_name> {
    # trait definition
}

# Define methods in a trait
nx::Trait create <trait_name> {
    :public method <method_name> {args} {
        # method implementation
    }
}

# Specify required methods
nx::Trait create <trait_name> {
    :requiredMethods <method1> <method2> ...
}

# Apply traits to classes
<class_name> require trait <trait_name>
```

#### Method Resolution

1. When a class incorporates multiple traits that define the same method, the method from the last trait applied takes precedence.
2. Original class methods remain unless overridden by a trait.
3. Within trait methods, you can reference the trait using its name:
   ```tcl
   return <trait_name>.[current method]  # Returns the method name
   return <trait_name>.[current methodpath]  # Returns the full method path
   ```

#### Code Examples

1. **Basic Trait Creation and Usage**
```tcl
# Create a trait
nx::Trait create t1 {
    :public method t1m1 {} {return t1.[current method]}
    :public method t1m2 {} {return t1.[current method]}
    
    # Require the class to implement "foo" method
    :requiredMethods foo
}

# Create a class with required method
nx::Class create C {
    :public method foo {} {return [current method]}
}

# Apply the trait
C require trait t1

# Now class C has methods: foo, t1m1, t1m2
```

2. **Method Conflict Resolution**
```tcl
# Create multiple traits
nx::Trait create t2 {
    :public method "bar x" {} {return t2.[current methodpath]}
    :public method "bar y" {} {return t2.[current methodpath]}
}

nx::Trait create t3 {
    :public method "bar y" {} {return t3.[current methodpath]}
    :public method "bar z" {} {return t3.[current methodpath]}
}

# Apply traits in sequence
C require trait t2
C require trait t3

# Method resolution:
# "bar x" comes from t2
# "bar y" comes from t3 (overrides t2's version)
# "bar z" comes from t3
```

3. **Trait Dependencies**
```tcl
# Create traits with dependencies
nx::Trait create t1 {
    :public method t1m1 {} {return t1.[current method]}
    :requiredMethods foo
}

nx::Trait create t2 {
    :public method foo {} {return t2.[current methodpath]}
    :requiredMethods t1m1  # Requires a method provided by t1
}

# This will fail if t1 is not applied first:
# C require trait t2  # Error: trait t2 requires t1m1

# Correct approach:
C require trait t1
C require trait t2  # Now succeeds
```

#### Querying Trait Information

```tcl
# List methods in a class
lsort [C info methods]  # Lists all methods
lsort [C info methods -path]  # Lists all methods with full paths
```

#### Common Patterns

1. **Required Methods Pattern**: Use `:requiredMethods` to enforce an interface contract.
2. **Method Override Pattern**: Apply traits in a specific order to control which implementations take precedence.
3. **Self-Reference Pattern**: Use `<trait_name>.[current method]` to refer to the trait itself.

#### Best Practices

1. Keep traits focused on a single responsibility.
2. Document required methods clearly.
3. Be mindful of trait application order when method conflicts exist.
4. Use descriptive method names to avoid unintended method conflicts.
5. Check for required methods before applying traits to avoid runtime errors.

### Variable Access Methods

The NX/NSF system provides comprehensive methods for accessing and manipulating variables in objects. This section covers the various ways to work with variables in NX.

#### Basic Variable Access Functions

The NX framework provides several functions in the `nsf::var` namespace for manipulating variables in objects:

| Function | Description | Syntax |
|----------|-------------|--------|
| `nsf::var::set` | Get or set a scalar variable | `nsf::var::set object varName ?value?` |
| `nsf::var::set -array` | Get or set an array variable | `nsf::var::set -array object arrayName ?keyValueList?` |
| `nsf::var::exists` | Check if a scalar variable exists | `nsf::var::exists object varName` |
| `nsf::var::exists -array` | Check if an array variable exists | `nsf::var::exists -array object arrayName` |
| `nsf::var::unset` | Unset a variable | `nsf::var::unset object varName` |
| `nsf::var::unset -nocomplain` | Unset a variable without error if not exists | `nsf::var::unset -nocomplain object varName` |
| `nsf::var::import` | Import a variable from an object | `nsf::var::import object varName` |

#### Alternative Access Methods

NX provides alternative ways to access these functions:

1. **Namespace Ensemble (`::nx::var1`)**
```tcl
namespace eval ::nx::var1 {
  namespace ensemble create -map {
    exists ::nsf::var::exists 
    import ::nsf::var::import 
    set ::nsf::var::set
  }
}

# Usage:
::nx::var1 set object varName ?value?
::nx::var1 exists object varName
::nx::var1 import object varName
```

2. **NX Object with Aliases (`::nx::var2`)**
```tcl
::nx::Object create ::nx::var2 {
  :object alias exists ::nsf::var::exists 
  :object alias import ::nsf::var::import
  :object alias set ::nsf::var::set
}

# Usage:
::nx::var2 set object varName ?value?
::nx::var2 exists object varName
::nx::var2 import object varName
```

#### Working with Scalar Variables

```tcl
# Set a scalar variable
nsf::var::set objectName varName value  # Returns the value

# Get a scalar variable value
nsf::var::set objectName varName        # Returns the current value

# Check if a scalar variable exists
nsf::var::exists objectName varName     # Returns 1 if exists, 0 if not
```

#### Working with Array Variables

```tcl
# Set an array variable
nsf::var::set -array objectName arrayName {key1 value1 key2 value2}  # Returns empty string

# Get all array elements
nsf::var::set -array objectName arrayName  # Returns "key1 value1 key2 value2..."

# Check if an array variable exists
nsf::var::exists -array objectName arrayName  # Returns 1 if exists as array, 0 if not
```

#### Object Variable Access Methods

Within object methods, you can access object variables in several ways:

1. **Using the colon prefix syntax:**
```tcl
set :varName value   # Set object variable
incr :varName        # Increment object variable
```

2. **Using `eval` on another object:**
```tcl
otherObject eval {incr :varName}  # Increment varName in otherObject's context
```

3. **Using variable import:**
```tcl
::nsf::var::import otherObject varName  # Import from other object
incr varName                           # Modify the imported variable
```

#### Information About Object Variables

```tcl
# List all variables in an object
objectName info vars  # Returns list of all variable names in the object
```

#### Performance Considerations

Different variable access methods may have performance implications when used in high-frequency operations. The test file contains benchmarks comparing these methods to help optimize your code.

### Variable Resolution

The NX/NSF system provides sophisticated variable resolution mechanisms that handle different types of variables and their scoping rules. This section covers the core concepts and behaviors of variable resolution in NX.

#### Variable Types and Notation

NX supports several types of variables with distinct notation:

- **Instance Variables**: Variables belonging to an object
  ```tcl
  :varname  # Colon prefix for instance variables
  ```
- **Global Variables**: Variables in the global namespace
  ```tcl
  ::varname  # Double colon prefix for global variables
  ```
- **Namespace Variables**: Variables in object namespaces
  ```tcl
  [current]::varname  # Fully qualified namespace variable
  [self]::varname     # Alternative for current object's namespace variables
  ```

#### Method Aliases for Variable Operations

NX provides method aliases for common Tcl commands to work with variables in object context:

```tcl
::nsf::method::alias ::nx::Object objeval -frame object ::eval
::nsf::method::alias ::nx::Object array -frame object ::array
::nsf::method::alias ::nx::Object lappend -frame object ::lappend
::nsf::method::alias ::nx::Object incr -frame object ::incr
::nsf::method::alias ::nx::Object set -frame object ::set
::nsf::method::alias ::nx::Object unset -frame object ::unset
```

#### Object Namespaces

Objects can have associated namespaces for variable management:

```tcl
nx::Object create o
o require namespace  # Create a namespace for the object

# Check namespace status
o info has namespace  # Returns 1 if namespace is required, 0 if namespace exists but wasn't required

# Direct namespace access
namespace eval ::o {set x 3}

# Object variable access (same variable)
::o set x
```

#### Evaluation Contexts

NX provides several evaluation contexts with different variable resolution behaviors:

1. **eval**: Standard evaluation with instance variable access
   ```tcl
   o eval {set :x 1}  # Evaluate in object context
   ```

2. **objeval**: All variables become instance variables
   ```tcl
   o objeval {
     set aaa 1        # Creates instance variable 'aaa'
     set :a 1         # Creates instance variable 'a'
     global g         # Access global variable
     :require namespace # Can require namespace within objscoped frame
   }
   ```

3. **softeval**: Only variables with colon prefixes become instance variables
   ```tcl
   o softeval {
     set bbb 1        # Local variable, not an instance variable
     set :b 1         # Creates instance variable 'b'
   }
   ```

4. **plain eval**: No automatic instance variable creation
   ```tcl
   o softeval2 {
     set zzz 1        # Local variable
     set :z 1         # Not an instance variable
   }
   ```

#### Variable Persistence and Caching

Variables persist between method calls and can be cached for performance:

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

#### Compiled vs Interpreted Code

NX supports both compiled and interpreted execution with some behavioral differences:

1. **Compiled Code**:
   - Creates link variables for colon-prefixed variables
   - More efficient for repeated access
   - Link variables are visible through `info vars :*`
   - Creates a sorted lookup cache for performance

2. **Interpreted Code**:
   - Resolves variables on demand
   - No link variables created
   - Behavior differs slightly from compiled code
   - May handle some edge cases differently

#### Best Practices for Variable Resolution

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

#### Common Pitfalls and Limitations

1. Mixing `variable` command with colon-prefixed variables can lead to unexpected behavior
2. `namespace which -variable :X` behaves differently than expected
3. Colon-prefixed variables with `upvar` require careful handling
4. Variable resolution caches must be refreshed when method definitions change
5. Differences between compiled and non-compiled execution can cause subtle bugs

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

### Volatile Objects

Volatile objects are a powerful feature in NX/XOTcl that provides automatic memory management. Objects marked as volatile are automatically destroyed when they go out of scope, making them ideal for temporary objects and preventing memory leaks.

#### Required Setup
```tcl
# Load required packages
package require nx::volatile
::nsf::method::require ::nx::Object volatile
```

#### Creating Volatile Objects

1. **Named Volatile Objects**
```tcl
# Create a named volatile NX object
Class create obj1 -volatile {
    :object method destroy {} {
        puts "[self] destroy"
        next
    }
}

# Create a named volatile XOTcl object
XClass create obj1 -volatile -proc destroy {} {
    puts "[self] destroy"
    next
}
```

2. **Unnamed Volatile Objects**
```tcl
# Create an unnamed volatile NX object
Class new -volatile {
    :object method destroy {} {
        puts "[self] destroy"
        next
    }
}

# Create an unnamed volatile XOTcl object
XClass new -volatile -proc destroy {} {
    puts "[self] destroy"
    next
}
```

#### Making Existing Objects Volatile

Objects can be made volatile after creation using the `volatile` method:
```tcl
# Make current object volatile within a method
:volatile

# Example usage in a method
Class instproc cleanup {} {
    :volatile
    # ... method body ...
    # Object will be destroyed after method completes
}
```

#### Best Practices

1. Use volatile objects for temporary data structures that should be automatically cleaned up
2. Always call `next` in custom destroy methods to ensure proper cleanup
3. Test proper destruction using `info command` checks:
```tcl
# Verify object destruction
if {[info command $objectName] eq ""} {
    puts "Object was properly destroyed"
}
```

4. Be cautious with volatile objects holding critical resources
5. Consider using volatile objects in procedures where temporary objects are needed

#### Implementation Notes

- Volatile objects work with both NX and XOTcl object systems
- The volatile flag ensures automatic destruction when objects go out of scope
- Custom destroy methods can be added for cleanup operations
- Compatible with other features like mixins and filters

## Method Resolution
