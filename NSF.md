# Next Scripting Framework (NSF) - Creating Custom Object Systems

The Next Scripting Framework (NSF) is a powerful meta-system that allows you to create custom object-oriented programming languages and systems. This guide explains how to use NSF to create your own object systems.

## Table of Contents
1. [Core Concepts](#core-concepts)
2. [Creating an Object System](#creating-an-object-system)
3. [Method Management](#method-management)
4. [Object System Customization](#object-system-customization)
5. [Advanced Features](#advanced-features)
6. [Real-World Examples](#real-world-examples)

## Core Concepts

NSF provides a foundation for creating object systems with these key components:

- Object System: The root framework that defines how objects and classes behave
- Method Management: System for handling method dispatch and inheritance
- Slots: Property and parameter management
- Method Protection: Access control mechanisms
- Object Lifecycle: Creation, initialization, and destruction

### Basic Architecture

```tcl
# Basic structure of an NSF-based object system
namespace eval ::myobjsys {
    namespace eval ::nsf {}            ;# NSF integration
    namespace eval ::nsf::object {}    ;# Object management
    namespace eval ::nsf::parameter {} ;# Parameter handling
}
```

## Creating an Object System

### Basic Object System Creation

```tcl
# Create a minimal object system with a root object and class
::nsf::objectsystem::create ::myobjsys::Object ::myobjsys::Class {
    -class.alloc {__alloc ::nsf::methods::class::alloc 1}
    -class.create create
    -class.dealloc {__dealloc ::nsf::methods::class::dealloc 1}
    -object.configure __configure
    -object.destroy destroy
}
```

### Customizing Object Creation

```tcl
# Define custom object creation behavior
::nsf::method::create ::myobjsys::Class create {name args} {
    # Pre-creation hooks
    :preCreate $name
    
    # Create the object
    set obj [::nsf::methods::class::create $name {*}$args]
    
    # Post-creation initialization
    :postCreate $obj
    
    return $obj
}
```

### Method Dispatch System

```tcl
# Define custom method dispatch
::nsf::method::create ::myobjsys::Object __dispatch {method args} {
    # Method lookup
    set methodImpl [:lookupMethod $method]
    
    if {$methodImpl eq ""} {
        # Handle unknown method
        return [:unknown $method {*}$args]
    }
    
    # Execute method
    return [uplevel 1 $methodImpl $args]
}
```

## Method Management

### Method Registration

```tcl
# Register methods with custom attributes
::nsf::method::create ::myobjsys::Class registerMethod {
    name 
    {protection public} 
    {type scripted} 
    body
} {
    # Validate method name
    if {![regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $name]} {
        error "Invalid method name: $name"
    }
    
    # Register method implementation
    ::nsf::method::create [self] $name $body
    
    # Set method properties
    ::nsf::method::property [self] $name protection $protection
    ::nsf::method::property [self] $name type $type
}
```

### Method Inheritance

```tcl
# Implement method inheritance
::nsf::method::create ::myobjsys::Class inheritMethods {superclass} {
    # Get all methods from superclass
    set methods [$superclass info methods]
    
    foreach method $methods {
        # Skip if method already exists
        if {[:info methods -exact $method] ne ""} continue
        
        # Get method implementation and properties
        set impl [$superclass info method definition $method]
        set props [$superclass info method properties $method]
        
        # Create inherited method
        ::nsf::method::create [self] $method $impl
        
        # Copy method properties
        foreach {prop value} $props {
            ::nsf::method::property [self] $method $prop $value
        }
    }
}
```

## Object System Customization

### Custom Method Types

```tcl
# Define a new method type
::nsf::methodtype::create async {
    -createCmd {name argList body} {
        set wrapper [string map [list %body% $body %name% $name] {
            coroutine %name%_cor apply {{name body} {
                yield
                uplevel 1 $body
            }} %name% %body%
        }]
        return $wrapper
    }
}

# Usage example
::myobjsys::Class create AsyncExample {
    :method -type async longOperation {} {
        # Async operation implementation
        after 1000
        return "Operation complete"
    }
}
```

### Custom Property Types

```tcl
# Define custom property type
::nsf::type::create email {
    -validate {value} {
        if {![regexp {^[^@]+@[^@]+\.[^@]+$} $value]} {
            error "Invalid email format: $value"
        }
        return $value
    }
}

# Usage in object system
::myobjsys::Class create Person {
    :property -type email userEmail
}
```

## Advanced Features

### Meta-Class System

```tcl
# Create a meta-class system
::myobjsys::Class create MetaClass {
    :property {instances {}}
    
    :public method new {args} {
        set instance [next {*}$args]
        lappend :instances $instance
        return $instance
    }
    
    :public method allInstances {} {
        return ${:instances}
    }
}

# Usage
::myobjsys::Class create CustomClass -metaclass MetaClass {
    # Class definition
}
```

### Aspect-Oriented Programming

```tcl
# Implement aspect-oriented features
::myobjsys::Class create Aspect {
    :public method beforeAdvice {class method body} {
        set original [$class info method definition $method]
        
        $class eval {
            :public method $method args {
                uplevel 1 $body
                uplevel 1 $original {*}$args
            }
        }
    }
    
    :public method afterAdvice {class method body} {
        set original [$class info method definition $method]
        
        $class eval {
            :public method $method args {
                set result [uplevel 1 $original {*}$args]
                uplevel 1 $body
                return $result
            }
        }
    }
}
```

## Real-World Examples

### Database Object System

```tcl
# Create a database-backed object system
::nsf::objectsystem::create ::dbsys::Object ::dbsys::Class {
    -class.create create
    -object.configure configure
    -object.destroy destroy
}

::dbsys::Class create DBObject {
    :property table
    :property primaryKey
    
    :public method save {} {
        # Save object state to database
        set values [:serialize]
        db eval "INSERT OR REPLACE INTO ${:table} $values"
    }
    
    :public method load {id} {
        # Load object state from database
        set data [db eval "SELECT * FROM ${:table} WHERE ${:primaryKey}=$id"]
        :deserialize $data
    }
}
```

### GUI Widget System

```tcl
# Create a widget-based object system
::nsf::objectsystem::create ::widget::Object ::widget::Class {
    -class.create create
    -object.configure configure
    -object.destroy destroy
}

::widget::Class create Widget {
    :property parent
    :property {x 0}
    :property {y 0}
    :property {width 100}
    :property {height 100}
    
    :public method draw {} {
        # Widget drawing implementation
    }
    
    :public method handleEvent {event} {
        # Event handling implementation
    }
}

::widget::Class create Button -superclass Widget {
    :property text
    :property command
    
    :public method draw {} {
        next
        # Additional button-specific drawing
    }
}
```

### Protocol-Oriented System

```tcl
# Create a protocol-based object system
::nsf::objectsystem::create ::proto::Object ::proto::Protocol {
    -class.create create
    -object.configure configure
    -object.destroy destroy
}

::proto::Protocol create Enumerable {
    :public method each {script} {
        error "Protocol method 'each' must be implemented"
    }
    
    :public method map {script} {
        set result {}
        :each [list lappend result [uplevel 1 $script]]
        return $result
    }
}

::proto::Protocol create Collection -protocols Enumerable {
    :property items
    
    :public method each {script} {
        foreach item ${:items} {
            uplevel 1 [list apply $script $item]
        }
    }
}
```

## Best Practices

1. **Namespace Organization**
   - Keep related classes and objects in dedicated namespaces
   - Use consistent naming conventions
   - Separate interface from implementation

2. **Method Management**
   - Use appropriate protection levels
   - Implement proper method lookup chains
   - Handle unknown methods gracefully

3. **Property Handling**
   - Define clear property semantics
   - Implement proper validation
   - Use appropriate property types

4. **Error Handling**
   - Provide meaningful error messages
   - Implement proper exception handling
   - Use assertions for invariants

5. **Documentation**
   - Document system architecture
   - Provide usage examples
   - Document method contracts

## Common Pitfalls

1. **Circular Dependencies**
   - Avoid circular inheritance
   - Use composition over inheritance when appropriate
   - Break complex dependencies into smaller components

2. **Performance**
   - Cache method lookups
   - Minimize dynamic method creation
   - Use appropriate data structures

3. **Memory Management**
   - Clean up resources properly
   - Handle object lifecycle correctly
   - Implement proper destruction chains

## Debugging and Testing

```tcl
# Implement debugging support
::myobjsys::Class create DebugSupport {
    :public method trace {method} {
        set original [:info method definition $method]
        
        :public method $method args {
            puts "Entering $method with args: $args"
            set result [uplevel 1 $original {*}$args]
            puts "Leaving $method with result: $result"
            return $result
        }
    }
}

# Testing framework integration
::myobjsys::Class create TestCase {
    :public method assert {condition {message ""}} {
        if {![uplevel 1 [list expr $condition]]} {
            error "Assertion failed: $message"
        }
    }
    
    :public method assertEquals {expected actual {message ""}} {
        :assert {$expected eq $actual} "$message (expected '$expected', got '$actual')"
    }
}
```

This documentation provides a comprehensive guide to creating custom object systems using NSF. For more specific examples or detailed explanations of particular features, please refer to the NSF source code and API documentation.
