# Next Scripting Framework (NSF) Comprehensive Guide

## Introduction

The Next Scripting Framework (NSF) is a powerful meta-system for creating object-oriented programming languages in Tcl. This guide provides a detailed look at NSF's architecture, meta-programming capabilities, and how NX (Next Scripting Language) is implemented using NSF.

## Core Architecture

### Object System Components

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

### Method Dispatch System

1. **Method Resolution**
   ```tcl
   ::nsf::method::create Object __resolve_method_path {
       -per-object:switch
       -verbose:switch
       path
   } {
       # Method path resolution logic
       # Handles ensemble objects and method hierarchies
   }
   ```

2. **Method Types**
   - Scripted methods
   - Built-in methods
   - Alias methods
   - Forwarder methods
   - Object methods
   - Setter methods
   - NSF procedures

3. **Method Properties**
   ```tcl
   ::nsf::method::property $class $method protection public|protected|private
   ::nsf::method::property $class $method type scripted|builtin|alias|forwarder
   ::nsf::method::property $class $method deprecated 1|0
   ```

## Meta-Programming Features

### 1. Object System Creation

```tcl
::nsf::objectsystem::create ::myobjsys::Object ::myobjsys::Class {
    -class.alloc {__alloc ::nsf::methods::class::alloc 1}
    -class.create create
    -class.dealloc {__dealloc ::nsf::methods::class::dealloc 1}
    -object.configure __configure
    -object.destroy destroy
}
```

### 2. Dynamic Method Creation

```tcl
::nsf::method::create $class $name {
    name 
    {protection public} 
    {type scripted} 
    body
} {
    # Method implementation
}
```

### 3. Custom Method Types

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
```

### 4. Parameter Handling

1. **Parameter Types**
   ```tcl
   ::nsf::type::create email {
       -validate {value} {
           if {![regexp {^[^@]+@[^@]+\.[^@]+$} $value]} {
               error "Invalid email format: $value"
           }
           return $value
       }
   }
   ```

2. **Parameter Constraints**
   ```tcl
   :public method setAge {age:integer} {
       if {$age < 0 || $age > 150} {
           error "Age must be between 0 and 150"
       }
   }
   ```

### 5. Method Introspection

```tcl
::nsf::method::info $class $method {
    args        # Get method arguments
    body        # Get method body
    definition  # Get full method definition
    exists      # Check if method exists
    protection  # Get method protection level
    type        # Get method type
}
```

## NX Implementation

### 1. Core Class Hierarchy

```tcl
# Create the NX object system
::nsf::objectsystem::create ::nx::Object ::nx::Class {
    -class.alloc {__alloc ::nsf::methods::class::alloc 1}
    -class.create create
    -class.dealloc {__dealloc ::nsf::methods::class::dealloc 1}
    -object.configure __configure
    -object.destroy destroy
}
```

### 2. Method Management

1. **Method Registration**
   ```tcl
   ::nsf::method::create Class method {
       -debug:switch 
       -deprecated:switch
       name 
       arguments:parameter,0..* 
       -checkalways:switch 
       -returns 
       body
   } {
       # Method registration implementation
   }
   ```

2. **Method Protection**
   ```tcl
   foreach cmd {uplevel upvar} {
       ::nsf::method::property Object $cmd call-protected 1
   }
   ```

### 3. Ensemble Objects

```tcl
nx::Class create Calculator {
    :public object method math.add {a b} {
        return [expr {$a + $b}]
    }
    
    :public object method math.subtract {a b} {
        return [expr {$a - b}]
    }
}
```

### 4. Meta-Class System

```tcl
nx::Class create MetaClass {
    :property {instances {}}
    
    :public method new {args} {
        set instance [next {*}$args]
        lappend :instances $instance
        return $instance
    }
}
```

## Advanced Features

### 1. Aspect-Oriented Programming

```tcl
nx::Class create Aspect {
    :public method beforeAdvice {class method body} {
        set original [$class info method definition $method]
        
        $class eval {
            :public method $method args {
                uplevel 1 $body
                uplevel 1 $original {*}$args
            }
        }
    }
}
```

### 2. Dynamic Class Generation

```tcl
nx::Class create ClassGenerator {
    :public method generateClass {name properties methods} {
        nx::Class create $name
        
        foreach prop $properties {
            lassign $prop name type default
            $name eval [list :property "\{$name:$type $default\}"]
        }
        
        foreach method $methods {
            lassign $method name args body
            $name eval [list :public method $name $args $body]
        }
    }
}
```

### 3. Object Persistence

```tcl
nx::Class create PersistentObject {
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
}
```

## Best Practices

1. **Method Protection**
   - Use appropriate protection levels (public, protected, private)
   - Protect critical methods from redefinition
   - Use call-protected for internal methods

2. **Parameter Validation**
   - Define custom types for complex validations
   - Use built-in type checkers where possible
   - Implement parameter constraints

3. **Meta-Programming**
   - Create reusable meta-classes for common patterns
   - Use aspect-oriented programming for cross-cutting concerns
   - Leverage dynamic class generation for factory patterns

4. **Error Handling**
   - Provide meaningful error messages
   - Use assertions for invariants
   - Implement proper cleanup in destructors

## Common Patterns

### 1. Singleton Pattern

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

### 2. Factory Pattern

```tcl
nx::Class create Factory {
    :public object method create {type args} {
        switch $type {
            "worker" {
                return [Worker new {*}$args]
            }
            "manager" {
                return [Manager new {*}$args]
            }
            default {
                error "Unknown type: $type"
            }
        }
    }
}
```

### 3. Observer Pattern

```tcl
nx::Class create Observable {
    :property -incremental {observers:object,*}
    
    :public method notify {event args} {
        foreach observer [:get observers] {
            $observer update $event {*}$args
        }
    }
}
```

## Debugging and Testing

### 1. Method Tracing

```tcl
nx::Class create DebugSupport {
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
```

### 2. Assertions

```tcl
nx::Class create TestCase {
    :public method assert {condition {message ""}} {
        if {![uplevel 1 [list expr $condition]]} {
            error "Assertion failed: $message"
        }
    }
    
    :public method assertEquals {expected actual {message ""}} {
        :assert {$expected eq $actual} \
            "$message (expected '$expected', got '$actual')"
    }
}
``` 
