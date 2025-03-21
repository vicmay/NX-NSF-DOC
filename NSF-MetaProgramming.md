# Next Scripting Framework (NSF) Meta-Programming Guide

## Introduction

The Next Scripting Framework (NSF) is a powerful meta-system that allows you to create custom object-oriented programming languages and systems. This guide focuses on the meta-programming capabilities of NSF, providing detailed explanations, API coverage, and practical examples.

## Core Concepts

### Object System Architecture

NSF provides a foundation for creating custom object systems with these key components:

```tcl
namespace eval ::myobjsys {
    namespace eval ::nsf {}            # NSF integration
    namespace eval ::nsf::object {}    # Object management
    namespace eval ::nsf::parameter {} # Parameter handling
}
```

### Basic Object System Creation

```tcl
::nsf::objectsystem::create ::myobjsys::Object ::myobjsys::Class {
    -class.alloc {__alloc ::nsf::methods::class::alloc 1}
    -class.create create
    -class.dealloc {__dealloc ::nsf::methods::class::dealloc 1}
    -object.configure __configure
    -object.destroy destroy
}
```

## Method Management System

### Method Registration and Creation

```tcl
# Basic method creation
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

### Method Properties and Attributes

```tcl
# Setting method properties
::nsf::method::property $class $method protection public
::nsf::method::property $class $method type scripted
::nsf::method::property $class $method deprecated 1
```

### Method Inheritance System

```tcl
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

## Custom Method Types

### Creating New Method Types

```tcl
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
        after 1000
        return "Operation complete"
    }
}
```

### Custom Property Types

```tcl
::nsf::type::create email {
    -validate {value} {
        if {![regexp {^[^@]+@[^@]+\.[^@]+$} $value]} {
            error "Invalid email format: $value"
        }
        return $value
    }
}

# Usage
::myobjsys::Class create Person {
    :property -type email userEmail
}
```

## Meta-Class System

### Creating Meta-Classes

```tcl
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

## Aspect-Oriented Programming

### Method Advice System

```tcl
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

## NSF API Reference

### Object System Creation

1. `::nsf::objectsystem::create`
   - Creates a new object system
   - Parameters:
     - Object class name
     - Class class name
     - Configuration options
   - Example:
     ```tcl
     ::nsf::objectsystem::create ::myapp::Object ::myapp::Class {
         -class.alloc {__alloc ::nsf::methods::class::alloc 1}
         -class.create create
         -object.destroy destroy
     }
     ```

### Method Management

1. `::nsf::method::create`
   - Creates a new method
   - Parameters:
     - Target (class or object)
     - Method name
     - Arguments
     - Body
   ```tcl
   ::nsf::method::create $class $name $arglist $body
   ```

2. `::nsf::method::property`
   - Sets/gets method properties
   - Parameters:
     - Target
     - Method name
     - Property name
     - Value (optional)
   ```tcl
   ::nsf::method::property $class $method protection public
   ```

3. `::nsf::method::delete`
   - Deletes a method
   - Parameters:
     - Target
     - Method name
   ```tcl
   ::nsf::method::delete $class $method
   ```

### Type System

1. `::nsf::type::create`
   - Creates a new type
   - Parameters:
     - Type name
     - Options and handlers
   ```tcl
   ::nsf::type::create typename {
       -validate {value} {
           # Validation logic
       }
   }
   ```

2. `::nsf::type::delete`
   - Deletes a type
   - Parameters:
     - Type name
   ```tcl
   ::nsf::type::delete typename
   ```

### Method Types

1. `::nsf::methodtype::create`
   - Creates a new method type
   - Parameters:
     - Type name
     - Creation handler
   ```tcl
   ::nsf::methodtype::create typename {
       -createCmd {name argList body} {
           # Method creation logic
       }
   }
   ```

## Advanced Examples

### Dynamic Class Generation

```tcl
::myobjsys::Class create ClassGenerator {
    :public method generateClass {name properties methods} {
        # Create the class
        ::myobjsys::Class create $name
        
        # Add properties
        foreach prop $properties {
            lassign $prop name type default
            $name eval [list :property "\{$name:$type $default\}"]
        }
        
        # Add methods
        foreach method $methods {
            lassign $method name args body
            $name eval [list :public method $name $args $body]
        }
    }
}

# Usage
ClassGenerator create generator
generator generateClass Person {
    {name string ""}
    {age integer 0}
} {
    {greet {} {
        return "Hello, I'm [:get name]"
    }}
    {birthday {} {
        incr :age
    }}
}
```

### Custom Object System Example

```tcl
# Create a persistent object system
namespace eval ::persys {
    ::nsf::objectsystem::create ::persys::Object ::persys::Class {
        -class.create create
        -object.configure configure
        -object.destroy destroy
    }
    
    ::persys::Class create PersistentObject {
        :property filename
        
        :public method save {} {
            set data [list]
            foreach var [:info vars] {
                if {[string match :* $var]} {
                    lappend data $var [set $var]
                }
            }
            set f [open ${:filename} w]
            puts $f $data
            close $f
        }
        
        :public method load {} {
            if {[file exists ${:filename}]} {
                set f [open ${:filename} r]
                array set vars [read $f]
                close $f
                foreach {name value} [array get vars] {
                    set $name $value
                }
            }
        }
    }
}
``` 