# NX Mixin Cheatsheet

This cheatsheet documents the mixin capabilities in NX, focusing on the `mixinof` functionality and related commands as derived from the test file.

## Basic Concepts

- **Mixin**: A class that is mixed into another class or object to provide additional functionality.
- **Per-Object Mixin**: A mixin applied to a specific object instance.
- **Per-Class Mixin**: A mixin applied to a class, affecting all instances of that class.

## Mixin Commands

### Setting Mixins

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

### Querying Mixins

```tcl
# Get mixins for an object
obj object mixins get        # Returns list of object mixins
obj info object mixins       # Alternative syntax

# Get mixins for a class
MyClass mixins get           # Returns list of class mixins
MyClass info mixins          # Alternative syntax
MyClass info mixins -guards  # Show mixins with guards
```

### Finding Where a Class is Mixed In

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

## Method Precedence

When an object has mixins, method calls use the following precedence order:

1. Per-object mixins
2. Class of the object
3. Per-class mixins of the object's class
4. Superclasses (in inheritance order)
5. nx::Object (base class)

Example precedence: `::MixinClass ::MyClass ::nx::Object`

## Mixin Inheritance Behavior

- Mixins from superclasses are inherited by subclasses (transitive)
- When a class used as a mixin has its own mixins, those are included in the precedence chain
- Destroying a mixin class removes it from all objects and classes

## Recreating Classes with Mixins

### With softrecreate = false (default)

When recreating a class that is used as a mixin:
- All mixin relationships are lost
- Subclass relationships are broken
- Objects of the old class become instances of nx::Object

### With softrecreate = true

When recreating a class that is used as a mixin:
- Mixin relationships are preserved
- Subclass relationships are maintained
- Objects remain instances of their classes

## Common Patterns and Examples

### Per-Object Mixins

```tcl
nx::Class create Logger {
    :method log {msg} {
        puts "LOG: $msg"
        next
    }
}

nx::Object create myObj -object-mixins Logger
```

### Per-Class Mixins

```tcl
nx::Class create Auditable {
    :method save {} {
        puts "Auditing save operation"
        next
    }
}

nx::Class create Document -mixin Auditable
```

### Complex Precedence Example

```tcl
nx::Class create A
nx::Class create B -mixin A
nx::Class create C -superclass B
C create c1

# c1's precedence: ::A ::C ::B ::nx::Object
``` 