# NX Framework Info Method Cheatsheet

## Basic Info Commands

### Superclasses
```tcl
obj info superclasses                   # Get direct superclasses
obj info superclasses -closure          # Get all superclasses (including indirect)
obj info superclasses pattern           # Get superclasses matching pattern
obj info superclasses -closure pattern  # Get all superclasses matching pattern
```

### Heritage and Precedence
```tcl
obj info heritage                       # Get class inheritance path
obj info precedence                     # Get method dispatch order
obj info precedence pattern             # Get method dispatch order matching pattern
```

### Methods
```tcl
obj info methods                        # List methods
obj info methods -callprotection all    # List all methods (including protected)
obj info methods -type scripted         # List only scripted methods
obj info methods -path                  # List methods as path names
obj info methods -closure pattern       # List all methods (including inherited) matching pattern
obj info methods -source application    # List only application-defined methods
obj info methods -source system         # List only system methods
```

### Lookup Methods
```tcl
obj info lookup method name             # Get actual method to be called for name
obj info lookup methods pattern         # List available methods matching pattern
obj info lookup methods -path pattern   # List methods with ensemble paths
obj info lookup methods -source all     # List all available methods
```

### Method Information
```tcl
obj info method definition name         # Get method definition
obj info method returns name            # Get return type constraint
obj info method parameters name         # Get parameter definitions
obj info method syntax name             # Get syntax documentation
obj info method exists name             # Check if method exists
obj info method type name               # Get method type
obj info method registrationhandle name # Get method registration handle
obj info method definitionhandle name   # Get method definition handle
```

### Object Methods
```tcl
obj info object methods                 # List object methods
obj info object method definition name  # Get object method definition
obj info object method parameters name  # Get object method parameters
obj info object method returns name     # Get object method return type
obj info object method submethods name  # List submethods of ensemble
obj info object method registrationhandle name # Get object method registration handle
```

## Mixins and Filters

### Mixins
```tcl
obj info mixins                         # List direct mixins
obj info mixins -closure                # List all transitive mixins
obj info mixins -heritage               # List explicit and implicit mixins
obj info object mixins                  # List object mixins
obj info object mixins -guards          # List object mixins with guards
obj info object mixins -guards name     # Get guard for specific mixin
```

### Filters
```tcl
obj info filters                        # List filters
obj info filters -guards                # List filters with their guards
obj info object filters                 # List object filters
obj info object filters -guards         # List object filters with guards
```

## Slots (Properties)

### Slots
```tcl
obj info slots                          # List slots
obj info slots -closure                 # List all slots (including inherited)
obj info slots -closure -source application # List application-defined slots
obj info slots pattern                  # List slots matching pattern
obj info object slots                   # List object-specific slots
```

### Lookup Slots
```tcl
obj info lookup slots                   # List all available slots
obj info lookup slots pattern           # List available slots matching pattern
```

## Ensemble Methods

### Submethod Access
```tcl
obj info method submethods ensemble     # List submethods of ensemble
obj info method exists "ensemble submethod" # Check if submethod exists
obj info method parameters "ensemble submethod" # Get parameters of submethod
obj info method definition "ensemble submethod" # Get definition of submethod
```

## Syntax and Parameters

### Parameter Information
```tcl
obj info lookup parameters methodName   # Get parameter information for method
obj info lookup syntax methodName       # Get syntax documentation
```

## Method Types

NX supports several method types:
- `scripted`: Regular Tcl methods
- `alias`: Aliases to Tcl commands
- `forward`: Forwarding to other methods
- `object`: Object-specific methods
- `setter`: Property setter methods
- `builtin`: Built-in methods

## Return Type Constraints

Return types can be specified with `-returns` and queried:
```tcl
obj info method returns methodName      # Get return type constraint

# Common return types:
# integer - Integer values
# object - Object references
# object,1..n - One or more object references
```

## Examples

### Define and Query Methods
```tcl
nx::Class create C {
    :method foo {a b} -returns integer {return 1}
    :object method bar {} -returns object {return [self]}
}

C info method definition foo    # Get method definition
C info method parameters foo    # Get "a b"
C info method returns foo       # Get "integer"
C info object method returns bar # Get "object"
```

### Work with Ensemble Methods
```tcl
nx::Class create C {
    :method "string length" {s} {return [string length $s]}
    :method "string reverse" {s} {return [string reverse $s]}
}

C info method submethods string   # Get "length reverse"
C info method definition "string length" # Get definition
C info lookup method "string length" # Get method handle
```

### Inspect Inheritance
```tcl
nx::Class create A
nx::Class create B -superclass A
nx::Class create C -superclass B

C info superclasses         # Get "::B"
C info superclasses -closure # Get "::B ::A ::nx::Object"
C info heritage             # Get "::B ::A ::nx::Object"
``` 