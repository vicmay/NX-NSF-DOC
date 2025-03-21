# NSF (Next Scripting Framework) Examples

This document provides comprehensive examples of using the Next Scripting Framework (NSF) and its NX object system.

## Table of Contents
1. [Basic Object Creation](#basic-object-creation)
2. [Class Definition](#class-definition)
3. [Methods and Properties](#methods-and-properties)
4. [Object Relationships](#object-relationships)
5. [Slots and Parameters](#slots-and-parameters)
6. [Method Protection and Visibility](#method-protection-and-visibility)
7. [Ensemble Objects](#ensemble-objects)
8. [Object Copying](#object-copying)

## Basic Object Creation

### Creating Objects

```tcl
# Create a basic object
nx::Object create myObject

# Create an object with initialization
nx::Object create myObject {
    :property name
    :property age 0
}

# Create an object in a specific namespace
nx::Object create ::app::myObject
```

## Class Definition

### Creating Classes

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

### Inheritance

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

## Methods and Properties

### Method Definition and Usage

```tcl
nx::Class create Example {
    # Public method
    :public method sayHello {name} {
        return "Hello, $name!"
    }
    
    # Protected method
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

### Properties

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

## Object Relationships

### Using Relations

```tcl
nx::Class create Department {
    :property name
    
    # Define a relationship to Employee objects
    :property -incremental {employees:object,*}
}

nx::Class create Employee {
    :property name
    
    # Define inverse relationship
    :property {department:object,0..1}
}

# Using relationships
set dept [Department new -name "Engineering"]
set emp1 [Employee new -name "John"]
set emp2 [Employee new -name "Jane"]

$dept employees add $emp1
$dept employees add $emp2
```

## Slots and Parameters

### Parameter Slots

```tcl
nx::Class create Widget {
    :property {width 100}
    :property {height 100}
    
    # Define parameter slot
    ::nx::ObjectParameterSlot create ${:slotObjs}::size \
        -multiplicity 2 \
        -type integer \
        -default {100 100}
}

# Using parameter slots
Widget create myWidget -size {200 150}
```

## Method Protection and Visibility

```tcl
nx::Class create SecureClass {
    # Public interface
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

## Ensemble Objects

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

## Object Copying

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

## Advanced Features

### Meta-Programming

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

### Event Handling

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

## Best Practices

1. Always use `:` prefix for method calls within object context
2. Use proper visibility modifiers (public, protected, private)
3. Leverage the type system for properties and parameters
4. Use `next` for proper method chaining in inheritance
5. Properly document classes and methods
6. Use meaningful names for classes, methods, and properties

## Common Patterns

### Singleton Pattern

```tcl
nx::Class create Singleton {
    :property instance:object,0..1
    
    :public object method getInstance {} {
        if {![info exists :instance]} {
            set :instance [my new]
        }
        return ${:instance}
    }
}
```

### Factory Pattern

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

For more detailed information and advanced usage, please refer to the NSF documentation and source code.
