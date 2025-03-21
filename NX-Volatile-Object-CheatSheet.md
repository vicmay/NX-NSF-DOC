# NX/XOTcl Volatile Objects Cheatsheet

## Overview
This cheatsheet covers the usage of volatile objects in NX and XOTcl frameworks based on the `volatile.test` test suite. Volatile objects are automatically destroyed when they go out of scope, providing automatic memory management.

## Required Packages

```tcl
# Load the required packages
package prefer latest
package req nx::test
package req XOTcl 2.0
package req nx::volatile

# Enable volatile functionality for nx::Object
::nsf::method::require ::nx::Object volatile
```

## Creating Volatile Objects

### NX Objects

```tcl
# Create a named volatile NX object with custom destroy method
C create c1 -volatile {:object method destroy {} {puts "[self] destroy"; next}}

# Create an unnamed volatile NX object with custom destroy method
C new -volatile {:object method destroy {} {puts "[self] destroy"; next}}
```

### XOTcl Objects

```tcl
# Create a named volatile XOTcl object directly
XC c1 -volatile -proc destroy {} {puts "[self] destroy"; next}

# Create a named volatile XOTcl object with 'create'
XC create c1 -volatile -proc destroy {} {puts "[self] destroy"; next}

# Create an unnamed volatile XOTcl object
XC new -volatile -proc destroy {} {puts "[self] destroy"; next}
```

## Making an Existing Object Volatile

```tcl
# Make current object volatile within a method
:volatile

# Example usage in a method
C instproc destroy-after-run {} {
  :volatile
  # ...code...
  # Object will be destroyed after method completes
}
```

## Testing Volatile Objects

```tcl
# Check if object is destroyed (should return empty string)
info command $objectName
```

## Mixing Volatile with Other Features

```tcl
# Create volatile object with mixins
xotcl::Object instmixin ::SomeMixin
set obj [xotcl::Object new -volatile]
```

## Common Patterns

### Volatile Objects in Procedures
Objects created in a procedure with the `-volatile` flag are automatically destroyed when the procedure completes.

### Volatile Objects in Methods
Objects marked as volatile within methods using `:volatile` are automatically destroyed when the method returns.

### Testing for Proper Destruction
Use the pattern below to verify objects are destroyed as expected:

```tcl
? [list info command $objectName] "" "Error message if object not destroyed"
```

## Implementation Notes

1. The volatile flag ensures objects are automatically destroyed when they go out of scope
2. Works with both NX and XOTcl object systems
3. Can be applied at creation time with `-volatile` flag or later with `:volatile`
4. Compatible with custom destroy methods through either:
   - `:object method destroy {}` (NX)
   - `-proc destroy {}` (XOTcl)

## Differences Between NX and XOTcl Volatile Objects

Both frameworks support volatile objects, but with slightly different syntax:

| Feature | NX | XOTcl |
|---------|-------|-------|
| Creation flag | `-volatile` | `-volatile` |
| Custom destroy | `:object method destroy {}` | `-proc destroy {}` |
| Making existing object volatile | `:volatile` | `my volatile` |

## Best Practices

1. Use volatile objects for temporary objects that should be automatically cleaned up
2. Test proper destruction with `info command` checks
3. When implementing custom destroy methods, always call `next` to ensure proper cleanup 
