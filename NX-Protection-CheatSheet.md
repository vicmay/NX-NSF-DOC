# NX Protection Mechanisms Cheatsheet

## Access Modifiers

### Method Declaration with Access Modifiers

```tcl
# Public method (default)
:public method methodName {args} {body}

# Protected method
:protected method methodName {args} {body}

# Private method
:private method methodName {args} {body}

# Per-object methods
:public object method methodName {args} {body}
:protected object method methodName {args} {body}
:private object method methodName {args} {body}
```

### Property Declaration with Access Modifiers

```tcl
# Public property
:property -accessor public {propertyName defaultValue}

# Protected property
:property -accessor protected {propertyName defaultValue}

# Private property 
:property -accessor private {propertyName defaultValue}

# Property with value constraint
:property -accessor private {propertyName:type defaultValue}

# Per-object properties
:object property -accessor public {propertyName defaultValue}
:object property -accessor protected {propertyName defaultValue}
:object property -accessor private {propertyName defaultValue}
```

## Method Property Handling

### Setting and Checking Protection Flags

```tcl
# Check if a method is protected
::nsf::method::property ClassName methodName call-protected
# Returns 1 if protected, 0 if not

# Set a method as protected
::nsf::method::property ClassName methodName call-protected true

# Remove protected flag
::nsf::method::property ClassName methodName call-protected false

# Check if a method is private
::nsf::method::property ClassName methodName call-private
# Returns 1 if private, 0 if not

# Set a method as private
::nsf::method::property ClassName methodName call-private true

# Remove private flag
::nsf::method::property ClassName methodName call-private false
```

### Method Redefinition Protection

```tcl
# Prevent a method from being redefined
::nsf::method::property ClassName methodName redefine-protected true

# Check if a method is protected from redefinition
::nsf::method::property ClassName methodName redefine-protected
```

## Calling Protected and Private Methods

### Local Method Access (Within the same class)

```tcl
# Call a private/protected method from within the same class
: -local privateMethodName arg1 arg2

# Call a private/protected property accessor from within the same class
: -local propertyName get
: -local propertyName set newValue
```

### Using Method Handles

```tcl
# Get a method handle
set handle [ClassName info method registrationhandle methodName]

# Call a private method via handle
: $handle arg1 arg2

# Alternative syntax
: [ClassName info method registrationhandle methodName] arg1 arg2
```

### Using Dispatch

```tcl
# Call a private method via dispatch 
dispatch [self] [ClassName info method registrationhandle methodName] arg1 arg2

# Calling protected methods with nx::dispatch
nx::dispatch objectName methodName args
```

### System Flag for Bypassing Overloaded Methods

```tcl
# Bypass an overloaded system method
nx::dispatch objectName -system methodName args
```

## Introspection

### Method Introspection

```tcl
# List all methods (public only)
ClassName info methods

# List methods with specific call protection
ClassName info methods -callprotection all      # All methods
ClassName info methods -callprotection public   # Public methods only
ClassName info methods -callprotection protected # Protected methods only
ClassName info methods -callprotection private  # Private methods only

# Get method definition
ClassName info method definition methodName
```

### Property/Variable Introspection

```tcl
# List all variables (doesn't show private property internal names)
objectName info vars

# Access private property storage from within object
objectName eval {lsort [array names :__private]}
```

## Protection Behavior with Inheritance

1. A public method in a subclass can access all public methods from superclasses
2. A private method in a subclass can only be called via `-local` or method handles
3. Private methods do not participate in the `next` chain - they're skipped
4. Protected methods are not callable from outside but are callable from subclasses
5. Private properties in different classes don't conflict, even with the same name

## Protection with Mixins and Filters

1. Private methods in mixins are invisible to method calls but can be called by other methods in the same mixin
2. Protected and private methods can be used as filters
3. Mixin methods can call protected/private methods from the class they're mixed into
4. Filters run on all methods, including when accessing private methods via `-local`

## Practical Use Cases

1. **Private helper methods**: Hide implementation details in classes or mixins
2. **Protected methods**: Share implementation with subclasses but hide from external calls
3. **Private properties**: Store internal state not meant for external access
4. **Redefine protection**: Prevent critical methods from being overwritten
5. **Method handles**: Access private methods in complex scenarios

## Common Patterns

### Pattern: Private Helper Methods in Mixins

```tcl
nx::Class create MyMixin {
  :public method publicAPI {} {: -local privateHelper}
  :private method privateHelper {} {
    # Implementation details hidden from users
    return "result"
  }
}
```

### Pattern: Protected Class Hierarchy Methods

```tcl
nx::Class create Base {
  :protected method implementation {} {
    # Shared with subclasses but not with external callers
    return "base implementation"
  }
  :public method publicAPI {} {: -local implementation}
}

nx::Class create Sub -superclass Base {
  :protected method implementation {} {
    return "Sub [next]"  # Can call protected method in superclass
  }
}
```

### Pattern: Private Object State

```tcl
nx::Object create obj {
  :object property -accessor private {state initial}
  :public object method getState {} {: -local state get}
  :public object method setState {newValue} {: -local state set $newValue}
}
```

### Pattern: System Method Override with Dispatch

```tcl
nx::Object create obj {
  :public object method info {} {
    # Custom info implementation
    return "Custom info"
  }
  
  :public object method realInfo {} {
    # Access the actual system info method
    return [nx::dispatch [self] -system info]
  }
}
``` 