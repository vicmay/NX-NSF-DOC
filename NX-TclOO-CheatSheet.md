# TclOO Cheatsheet: Export and Unexport Method Features

## Overview

TclOO provides mechanisms to control method visibility and accessibility through `export` and `unexport` features. This cheatsheet explains their behavior and usage patterns based on the implementation in NSF/Nx.

## Key Concepts

### Export
- **Purpose**: Makes methods visible and accessible from outside the object/class
- **Mechanism**: Adds the PUBLIC_METHOD flag to a method's C-level representation
- **Effect**: Methods become callable directly on an object without using self-sends

### Unexport
- **Purpose**: Makes methods invisible and inaccessible from outside the object/class
- **Mechanism**: Removes the PUBLIC_METHOD flag from a method's C-level representation
- **Effect**: Methods become callable only through self-sends (using `my` command)

## Implementation Details

1. **Method Stubs**: Both export/unexport can create "method stubs" - placeholders that don't contain actual implementations
2. **Method Dispatch**: 
   - Exported methods are part of the public interface
   - Unexported methods require self-sends (the `my` command)
   - Unimplemented exported/unexported methods are treated as unknowns

## Usage Patterns

### Object Method Export/Unexport

```tcl
# Export an object method
$object export methodName

# Unexport an object method
$object unexport methodName
```

### Class Method Export/Unexport

```tcl
# Export a class method
$class export methodName

# Unexport a class method
$class unexport methodName
```

## Export Behaviors

1. **Exporting Existing Methods**
   ```tcl
   # Create an object with a protected method
   set o [nx::Object new]
   $o object method Foo {} { return [::nsf::current method] }
   
   # Method is not accessible directly
   $o Foo        # Error: unable to dispatch method
   $o eval {:Foo}  # Works: Self-send succeeds
   
   # After export, method becomes accessible
   $o export Foo
   $o Foo        # Now works
   ```

2. **Preemptive Export** (without implementation)
   ```tcl
   # Export a non-existent method
   $o export bar
   
   # Still fails because no implementation exists
   $o bar        # Error: unable to dispatch method
   ```

3. **Per-Class Method Export**
   ```tcl
   # From an instance
   $instance export methodName  # Makes method accessible on this instance
   
   # From the class
   $class export methodName     # Makes method accessible on all instances
   
   # From a subclass
   $subclass export methodName  # Makes method accessible on subclass instances
   ```

4. **Replacing Exported Methods**
   ```tcl
   nx::Object create obj {
     :export foo              # Declare intent to export
     :public object method foo {} {return ok}  # Provide implementation
   }
   ```

## Unexport Behaviors

1. **Unexporting Existing Methods**
   ```tcl
   # Create object with public method
   set o [nx::Object new]
   $o public object method foo {} { return [::nsf::current method] }
   
   # Method is accessible
   $o foo        # Works
   
   # After unexport, method is protected
   $o unexport foo
   $o foo        # Error: unable to dispatch method
   $o eval {:foo}  # Still works through self-send
   ```

2. **Unexporting Inherited Methods**
   ```tcl
   # Create class with public method
   Class create C {
     :public method foo {} {return ok}
   }
   
   # Create instance
   set c [C new]
   $c foo        # Works
   
   # After unexport, method is inaccessible
   $c unexport foo
   $c foo        # Error: unable to dispatch method
   ```

3. **Class-Level Unexport**
   ```tcl
   # Unexport at class level affects all instances
   C unexport bar
   
   # Method is inaccessible on all instances
   $c bar        # Error: unable to dispatch method
   ```

4. **Replacing Unexported Methods**
   ```tcl
   Class create testClass2 {
     :unexport foo            # Unexport first
     :public method foo {} {return ok}  # Then implement as public
   }
   # Method is accessible despite earlier unexport
   [testClass2 new] foo      # Works
   ```

## Advanced Use Case: Abstract Classes

```tcl
# Create abstract class by unexporting instance creation methods
nx::Class create AbstractQueue {
  :method enqueue item {
    error "not implemented"
  }
  :method dequeue {} {
    error "not implemented"
  }
  
  :class unexport create new  # Prevent direct instantiation
}

# Cannot create instances directly
AbstractQueue new           # Error: method unknown
AbstractQueue create aQueue # Error: method unknown
```

## Internal Implementation

The export/unexport functionality in NSF/Nx is implemented using:
- Method call protection
- Selective next forwarding
- Method property manipulation

The core implementation uses `methodExport` which:
1. Determines the scope (object or class)
2. Finds or creates method handles
3. Sets the appropriate call-protection property

## Common Patterns

1. **Protected Methods by Default**:
   ```tcl
   Class create MyClass {
     :method protectedMethod {} { return "protected" }
     :public method publicMethod {} { return "public" }
   }
   ```

2. **Selectively Exposing Inherited Methods**:
   ```tcl
   Class create ChildClass -superclass ParentClass {
     :export parentProtectedMethod  # Expose inherited protected method
   }
   ```

3. **Creating Abstract Classes**:
   ```tcl
   Class create AbstractClass {
     :class unexport new create  # Prevent direct instantiation
   }
   ``` 