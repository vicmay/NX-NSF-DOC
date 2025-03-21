# NX Class Method Cheatsheet

## Basic Class Method Syntax

### Class Method Declaration
```tcl
:public class method methodName {} {return value}
:protected class method methodName args {return value}
:private class method methodName args {return value}
:class method methodName args {return value}  # Default protection
```

### Class Method Access Modifiers
- `:public` - Accessible from anywhere
- `:protected` - Accessible from class and subclasses
- `:private` - Only accessible within the class
- No modifier (`:class`) - Default protection level

## Special Method Types

### Class Alias
```tcl
:public class alias aliasName ::ClassName::methodName
```

### Class Forward
```tcl
:public class forward forwardName %self methodName
```

## Class Properties and Variables

### Class Property
```tcl
:class property -accessor public propertyName
```

### Class Variables
```tcl
:class variable variableName value
:class variable -incremental variableName:type value
```

## Information Retrieval

### Method Information
```tcl
ClassName info object methods                    # List all public methods
ClassName info object methods -callprotection protected  # List protected methods
ClassName info object methods -callprotection private    # List private methods
ClassName class info methods                     # Same as above but using class syntax
```

### Variable and Slot Information
```tcl
ClassName class info variables    # List class variables
ClassName info object variables   # List object variables
ClassName class info slots        # List class slots
```

## Mixins and Filters

### Mixin Management
```tcl
ClassName class mixins set MixinClass    # Set mixin
ClassName class info mixins              # Get mixins
ClassName class mixins set ""            # Clear mixins
```

### Filter Management
```tcl
ClassName class filters set filterName    # Set filter
ClassName class info filters              # Get filters
ClassName class filters set ""            # Clear filters
```

## Method Management

### Delete Operations
```tcl
ClassName class delete method methodName     # Delete a class method
ClassName class delete property propertyName # Delete a class property
ClassName class delete variable variableName # Delete a class variable
```

## Method Requirements

### Require Method
```tcl
:require class method methodName    # Require a specific class method
```

## Package Usage
```tcl
package require nx::class-method           # Load class method package
nx::configure class-method-warning on      # Enable verbose warnings
```

## Notes
- Class methods are instance-independent methods that operate at the class level
- The `class` keyword in method definitions creates class-level functionality
- Methods can be chained using `next` for inheritance
- Property accessors can be automatically generated using `-accessor` flag
- Variables can be typed using the type suffix (e.g., `:integer`) 