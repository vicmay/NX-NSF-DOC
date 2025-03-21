# NX Aliases Cheatsheet

## Basic Alias Usage

### Creating Aliases
```tcl
# Basic alias syntax
::nx::Object public alias set ::set

# Alias with frame specification
::nx::Object public alias set -frame method ::set
::nx::Object public alias set -frame object ::set

# Creating per-object alias
::nsf::method::alias ::object -per-object ALIAS_NAME TARGET_METHOD

# Creating class-level alias
::nsf::method::alias ::Class ALIAS_NAME TARGET_METHOD

# Creating alias to a method handle
:public alias alias_name [:info method registrationhandle method_name]
```

## Key Characteristics

1. **Types of Aliases**
   - Per-object aliases (specific to an object instance)
   - Class-level aliases (available to all instances)
   - Direct aliases (to C-implemented Tcl commands)
   - Method aliases (to other methods)
   - Protected aliases (using protected keyword)

2. **Frame Handling**
   - Cannot use `-frame object|method` for scripted commands
   - Default frame behavior available for all commands
   - Frame specification affects variable resolution context

3. **Alias Store**
   - Internal structure: `<object>,<alias_name>,<per_object> -> <aliased_cmd>`
   - Used for introspection of aliases
   - Particularly important for direct aliases to C-implemented commands
   - Accessible via `::nsf::alias` array

## Variable Handling

1. **Colon Variables**
   ```tcl
   # In method context
   set :var value    # Sets instance variable
   ${:var}          # Retrieves instance variable
   ```

2. **Variable Resolution**
   - Argument variables take precedence over instance variables
   - Variable scope depends on calling context
   - Upvar behavior preserved in alias calls

3. **Bytecode Compilation**
   ```tcl
   # Different behavior based on context:
   # Outside object context
   foo 1 2          # :vars are arguments
   
   # Inside object context
   obj foo 1 2      # :vars are instance variables
   ```

## Namespace Handling

1. **Resolution Rules**
   ```tcl
   # Global namespace
   ::nsf::method::alias T FOO ::global::proc
   
   # Namespaced proc
   ::nsf::method::alias T BAR ::ns1::proc
   
   # Method from another object
   ::nsf::method::alias T ZAP ::other::object::method
   ```

2. **Namespace Preservation**
   - Target method's namespace context is preserved
   - Defining namespace takes precedence
   - Namespace imports affect resolution

## Reference Counting

1. **Object References**
   ```tcl
   # Creating alias increments refcount
   ::nsf::method::alias ::o X ::target
   
   # Recreating alias updates refcount
   ::nsf::method::alias ::o X ::new_target
   ```

2. **Cleanup Behavior**
   - Destroying target object doesn't immediately invalidate alias
   - Reference counts properly managed on alias recreation
   - Namespace deletion handled gracefully

## Error Handling

1. **Common Errors**
   ```tcl
   # Circular reference
   set handle [:public object method foo {} {return 1}]
   :public object alias foo $handle   # Runtime error
   
   # Missing target
   :public object alias foo ::non_existent::proc  # Error at call time
   ```

2. **Target Deletion**
   - Aliases to deleted targets remain but fail at runtime
   - Proper error messages for missing targets
   - Cleanup strategies needed for maintenance

## Advanced Features

1. **Mixin Interaction**
   ```tcl
   # Mixin methods can affect alias behavior
   object mixins add SomeMixin
   ```

2. **Pre-compiled Proc Handling**
   ```tcl
   # Force bytecode compilation
   ::foo 1
   
   # Then create alias
   ::nsf::method::alias ::Class foo ::foo
   ```

3. **Dynamic Target Updates**
   ```tcl
   # Target proc can be redefined
   proc target {} {return 1}
   proc target {} {return 2}  # Alias will use new definition
   ```

## Best Practices

1. **Alias Management**
   - Keep alias chains short and simple
   - Document alias relationships
   - Consider namespace implications
   - Handle cleanup properly

2. **Performance Considerations**
   - Be aware of bytecode compilation effects
   - Consider pre-compilation impacts
   - Monitor reference counting in complex scenarios

3. **Error Prevention**
   - Verify target existence before creating aliases
   - Avoid circular references
   - Plan for target deletion scenarios
   - Use proper namespace qualifications

## Introspection

```tcl
# Get all alias methods
Object info methods -type alias

# Get alias definition
Object info method definition ALIAS_NAME

# Check if method is an alias
Object info method type ALIAS_NAME
```

## Behavior Notes

1. **Namespace Handling**
   - Aliases preserve the namespace context of their target methods
   - Target method's defining namespace takes precedence

2. **Variable Scope**
   - Aliases maintain proper variable scoping
   - Upvar and variable access work as expected within method context

3. **Reference Counting**
   - Objects referenced by aliases are properly reference counted
   - Destroying target objects doesn't immediately break aliases

## Common Patterns & Best Practices

1. **Alias Chain Management**
   - Avoid circular aliases
   - Be cautious with alias chains (alias pointing to another alias)

2. **Error Handling**
   - Check for target existence before creating aliases
   - Handle cases where target methods might disappear

3. **Namespace Considerations**
   - Consider namespace implications when creating aliases
   - Be explicit about namespace paths when needed

## Limitations & Warnings

1. **Circular References**
   - Avoid creating circular alias references
   - Runtime exceptions will occur with circular aliases

2. **Target Deletion**
   - Deleting target methods may leave aliases pointing to non-existent targets
   - Consider cleanup strategies for such cases

3. **Compilation Context**
   - Be aware of bytecode compilation context differences
   - Pre-compiled procs may behave differently when aliased

## Examples

```tcl
# Basic object alias
nx::Object create obj {
    :public object alias myAlias ::some::proc
}

# Class-level alias
nx::Class create MyClass {
    :public alias classAlias ::some::method
}

# Method aliasing
nx::Class create MyClass {
    :public method originalMethod {} { return "Hello" }
    :public alias aliasMethod [:info method registrationhandle originalMethod]
}
``` 