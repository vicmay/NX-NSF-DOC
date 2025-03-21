# NX Traits Cheatsheet

## Overview
NX Traits provides a mechanism for code reuse in the NX framework, allowing classes to inherit methods from multiple traits. This is similar to mixins or interfaces in other languages, but with added capabilities.

## Basic Concepts

### Creating a Trait
```tcl
nx::Trait create <trait_name> {
    # trait definition
}
```

### Defining Methods in a Trait
```tcl
nx::Trait create <trait_name> {
    :public method <method_name> {args} {
        # method implementation
    }
}
```

### Required Methods
Traits can specify methods that must be implemented by any class that uses the trait:
```tcl
nx::Trait create <trait_name> {
    :requiredMethods <method1> <method2> ...
}
```

### Applying Traits to Classes
```tcl
<class_name> require trait <trait_name>
```

## Method Resolution

1. When a class incorporates multiple traits that define the same method, the method from the last trait applied takes precedence.
2. Original class methods remain unless overridden by a trait.
3. Within trait methods, you can reference the trait using its name:
   ```tcl
   return <trait_name>.[current method]  # Returns the method name
   return <trait_name>.[current methodpath]  # Returns the full method path
   ```

## Code Examples

### Example 1: Basic Trait Creation and Usage
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

### Example 2: Method Conflict Resolution
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

### Example 3: Trait Dependencies
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

## Querying Trait Information

### List Methods in a Class
```tcl
lsort [C info methods]  # Lists all methods
lsort [C info methods -path]  # Lists all methods with full paths
```

## Common Patterns

1. **Required Methods Pattern**: Use `:requiredMethods` to enforce an interface contract.
2. **Method Override Pattern**: Apply traits in a specific order to control which implementations take precedence.
3. **Self-Reference Pattern**: Use `<trait_name>.[current method]` to refer to the trait itself.

## Best Practices

1. Keep traits focused on a single responsibility.
2. Document required methods clearly.
3. Be mindful of trait application order when method conflicts exist.
4. Use descriptive method names to avoid unintended method conflicts.
5. Check for required methods before applying traits to avoid runtime errors. 