# Nx Interceptor and Slot Cheatsheet

This cheatsheet summarizes the key concepts and APIs from the NextScripting Framework (NX) related to interceptors (mixins and filters) and slots, as demonstrated in the test cases.

## Mixins

### Class Mixins

```tcl
# Add a mixin to a class
C mixins add M
C mixins set M           # Replaces all mixins
C mixins delete M        # Remove a specific mixin
C mixins clear           # Remove all mixins
C mixins get             # Get list of mixins

# Alternative API
::nsf::mixin C M         # Add a mixin
```

### Per-Object Mixins

```tcl
# Add a mixin to an object
obj object mixins add M
obj object mixins set M     # Replaces all mixins
obj object mixins delete M  # Remove a specific mixin
obj object mixins clear     # Remove all mixins
obj object mixins get       # Get list of mixins

# Create with mixins
Class create obj -object-mixins M

# Using relation API
::nsf::relation::set obj object-mixin M
::nsf::relation::get obj object-mixin
```

### Mixin Introspection

```tcl
# Class mixin introspection
C info mixins              # List class mixins
C info lookup method mixins

# Object mixin introspection
obj info object mixins     # List object mixins
obj info precedence        # Full precedence order
obj info lookup mixins     # All applicable mixins
obj info lookup mixins -guards  # Show mixins with guards
```

## Filters

### Class Filters

```tcl
# Add a filter to a class
C filters add filterName
C filters set filterName     # Replace all filters
C filters delete filterName  # Remove specific filter
C filters clear              # Remove all filters

# Using relation API
::nsf::relation::set C class-filter filterName
::nsf::relation::get C class-filter
```

### Per-Object Filters

```tcl
# Add a filter to an object
obj object filters add filterName
obj object filters set filterName    # Replace all filters
obj object filters delete filterName # Remove specific filter
obj object filters clear             # Remove all filters

# Create with filters
Class create obj -object-filters filterName

# Using relation API
::nsf::relation::set obj object-filter filterName
::nsf::relation::get obj object-filter
```

### Filter Guards

```tcl
# Add a filter with a guard (condition)
C filters add {filterName -guard {condition}}

# Add a guard to an existing filter
C filters guard filterName {condition}

# Filter guard example
C filters guard loggingFilter {[current calledmethod] in {enter leave}}
```

### Filter Introspection

```tcl
# Class filter introspection
C info filters           # List class filters

# Object filter introspection
obj info object filters  # List object filters
obj info lookup filters  # All applicable filters
obj info lookup filters -guards  # Show filters with guards
```

## Method Dispatch & Handles

```tcl
# Get method handles
C info method definitionhandle methodName

# Dispatch using handles
obj [C info method definitionhandle methodName]

# Explicit dispatch
nsf::dispatch obj methodName
nsf::dispatch obj -intrinsic methodName  # Skip mixins

# Context-aware dispatch
nsf:: :-local methodName    # Dispatch in current context
nsf:: :-intrinsic methodName  # Skip mixins in current context
```

## Method Implementation Patterns

```tcl
# Next-path traversal (inheritance)
:method foo {} {
    # Do something
    return "[self] [next]"  # Call next method in chain
}

# Current context
:method myMethod {} {
    set m [current calledmethod]  # Method being called
    set c [current class]         # Class context
}

# Self reference
:method myMethod {} {
    set s [self]  # Current object
    set p [self proc]  # Current method
}
```

## Special Cases

### Classes with Spaces in Names

```tcl
# Create a class with a space in its name
nx::Class create "Class Name" {}

# Use with mixins
C mixins add "Class Name"
```

### Filter application to unknown methods

When calling unknown methods through a filter chain, the filter is applied even for methods that don't exist, allowing for interception of method dispatch failures. 
