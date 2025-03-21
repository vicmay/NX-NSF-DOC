# NX Framework Object Destruction Cheatsheet

## Basic Concepts

- In NX framework, object destruction is managed through the `destroy` method
- The destruction process can be customized by overriding the `destroy` method
- Destruction propagates up the inheritance chain using `next`
- Objects can block their own destruction by not calling `next` in their `destroy` method

## Destruction States

The destroy.test file demonstrates several key state variables:
- `::ObjectDestroy` - Tracks when the parent class's destroy method is called
- `::firstDestroy` - Tracks when a child class's destroy method is called

## Destruction Behaviors

### Simple Object Destruction

```tcl
# Standard destruction with propagation
C method destroy {} {incr ::firstDestroy; next}
C create c1
c1 destroy
# => Object is fully destroyed (::nsf::object::exists c1 returns 0)
```

### Blocking Destruction

```tcl
# Destruction that doesn't propagate
C method destroy {} {incr ::firstDestroy} # No next call
C create c1
c1 destroy
# => Object still exists (::nsf::object::exists c1 returns 1)
```

### Object Recreation

```tcl
# An object can recreate itself in its own destroy method
C method foo {} {
  [:info class] create [current]
  # => The object continues to exist
}
```

## Destruction Triggers

Objects can be destroyed in several ways:

1. **Direct destruction**: Calling the `destroy` method explicitly
2. **Rename to empty**: Using `rename [current] ""` triggers destruction
3. **Namespace deletion**: Deleting a parent namespace can trigger destruction
4. **Parent object deletion**: When a parent object is destroyed, its children are also destroyed
5. **Redefining as a proc**: Creating a proc with the same name as an object destroys the object

## Namespace and Object Relationship

- Deleting a namespace that contains objects will eventually destroy those objects
- TCL delays namespace deletion until the namespace is not active anymore
- Objects in a deleted namespace may continue to function briefly during method execution

## Special Cases

### Aliased Methods

```tcl
# Object alias mechanisms
::nsf::method::alias o x o3
o destroy
# => Aliased object (o3) survives when the parent object is destroyed
```

### Cyclical Dependencies

The framework can handle:
- Cyclical class dependencies (a class depending on itself)
- Cyclical superclass relationships

```tcl
# Example of cyclical dependency
nx::Object create o1
nx::Class create o1::C
nsf::relation::set o1 class o1::C
o1 destroy
# => Framework properly handles the cycle
```

### Destruction During Initialization

Objects can destroy themselves during initialization:

```tcl
Foo create f1 { :bar; :baz; :destroy }
# => Object is created and immediately destroyed
```

### Volatile Objects

With the `nx::volatile` package, objects can be made temporary:

```tcl
# Create an object that will be automatically destroyed
set x [nx::Class new {
  :volatile
  # Object will be automatically destroyed when no longer referenced
}]
```

## Unset Traces and Object Variables

- Variable unset traces can be triggered during object destruction
- Care must be taken with unset traces that try to recreate variables or destroy objects

```tcl
# Example of unset trace during cleanup
::trace add variable :x unset "[list set ::X ${:x}];#"
```

## Advanced Destruction Patterns

### Ordered Composite Destruction

The test demonstrates complex hierarchical object structures with controlled destruction order:

```tcl
nx::Class create C {
  :property os
  :public method destroy {} {
    foreach o ${:os} {
      if {[::nsf::object::exists $o]} {
        $o destroy
      }
      next
    }
  }
}
```

### Method Caching Considerations

When renaming commands that are used as methods, caching must be considered:

```tcl
# Renaming cached methods requires invalidating the cache
rename ::A::new ""
# Ensures the original method works again
```

## Troubleshooting Destruction Issues

Common problems demonstrated in the tests:
- Objects not fully destroyed due to missing `next` calls
- Accessing objects during their destruction process
- Cyclical dependencies preventing clean destruction
- Namespace deletion timing issues affecting object lifetime 