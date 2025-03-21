# NX Method Return Values Cheatsheet

## Overview

This cheatsheet documents the return value checking and typing system in the NX Tcl extension, as evidenced in the `returns.test` test suite. The system allows for type checking and conversion of method return values.

## Basic Configuration

```tcl
# Enable return value checking globally
::nsf::configure checkresult true

# Disable return value checking globally
::nsf::configure checkresults false
```

## Setting Return Types

### For Existing Methods

```tcl
# Set return type for a method
::nsf::method::property ClassName methodName returns typeName

# Set return type with additional arguments
::nsf::method::property ClassName methodName returns typeName,arg=value

# Enable value conversion for return values
::nsf::method::property ClassName methodName returns typeName,convert

# Remove return type checking
::nsf::method::property ClassName methodName returns ""
```

### During Method Declaration

```tcl
# Method with return type
:method methodName {param1 param2} -returns typeName {
    # method body
}

# Alias with return type
:alias aliasName -returns typeName -frame object ::someCommand

# Forward with return type
:forward forwardName -returns typeName ::someCommand

# Object method with complex return type (object with cardinality)
:public object method methodName {} -returns object,1..n {
    # method body
}
```

## Querying Return Types

```tcl
# Get the return type of a method
::nsf::method::property ClassName methodName returns
```

## Built-in Return Types

- `integer`: Checks if return value is an integer
- `object`: Checks if return value is a valid object
- `object,1..n`: Checks if return value is one or more valid objects

## Custom Return Types

### Creating a Custom Return Type

```tcl
::nx::methodParameterSlot object method type=typeName {name value args} {
    # Validation logic
    if {!valid} {
        error "Error message"
    }
    return $value  # Return original or modified value
}
```

### Example: Range Type

```tcl
::nx::methodParameterSlot object method type=range {name value arg} {
    lassign [split $arg -] min max
    if {$value < $min || $value > $max} {
        error "Value '$value' of parameter $name not between $min and $max"
    }
    return $value
}

# Usage:
::nsf::method::property ClassName methodName returns range,arg=1-30
```

### Example: Value Conversion Type

```tcl
::nx::methodParameterSlot object method type=sex {name value args} {
    switch -glob $value {
        m* {return m}
        f* {return f}
        default {error "expected sex but got $value"}
    }
}

# Usage with conversion:
::nsf::method::property ClassName methodName returns sex,convert
# Now "male" returns as "m", "female" as "f"
```

## Behavior with Check Results Enabled/Disabled

### With `checkresult true`:

- Methods with return type constraints will validate return values
- Return value errors are raised when constraints aren't met
- Converters with `convert` flag still function

### With `checkresult false`:

- Type checking is disabled (no errors for invalid return values)
- Converters with `convert` flag still function (conversion still happens)

## Method Types Supporting Return Values

- Regular methods (`:method`)
- Object methods (`:object method`)
- Aliases (`:alias`)
- Forwards (`:forward`)

## Common Error Messages

- `expected integer but got "x" as return value`
- `Value 'x' of parameter return-value not between min and max`
- `expected sex but got x`

## Testing Return Values

```tcl
# In NX test cases:
? {objectName methodName args} expectedResult
```

## Notes on Empty Parameter Definitions

- Return value specifications work even with methods that have no parameters
- Setting a return type does not affect the parameter definitions

## Examples

### Basic Integer Return Checking
```tcl
::nsf::method::property C method1 returns integer
C method1  # Will error if return value is not an integer
```

### Custom Range Return Checking
```tcl
::nsf::method::property C method1 returns range,arg=1-100
C method1  # Will error if return value is not between 1 and 100
```

### Return Value Conversion
```tcl
::nsf::method::property C method1 returns sex,convert
C method1  # Will convert "male" to "m", "female" to "f"
``` 