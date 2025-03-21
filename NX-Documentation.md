# NX: The Next Scripting Language
## Comprehensive Documentation

### Introduction

NX (Next Scripting Language) is a highly flexible object-oriented scripting language built on top of Tcl. It is part of the Next Scripting Framework (NSF) and represents a modern evolution in Tcl-based object-oriented programming.

#### Historical Context

While NX has predecessors in the Tcl ecosystem (XOTcl and XOTcl2), it is a distinct and improved language with its own features and design philosophy. Key points about NX's position in the Tcl ecosystem:

- **Foundation**: Built on Tcl (requires Tcl 8.5 or newer)
- **Framework**: Part of the Next Scripting Framework (NSF)
- **Design Goals**: 
  - Easier learning curve for novices
  - Improved maintainability
  - Better structured programs
  - Enhanced support for large projects
  - Language-oriented programming support

#### Key Differentiators

NX differs from its predecessors in several important ways:
- More mainstream terminology
- Higher orthogonality of methods
- Fewer predefined methods
- Strong focus on maintainability
- Built-in support for interfaces
- Language-oriented programming capabilities

### Core Concepts

#### 1. Object System Basics

NX provides a dynamic object system with the following fundamental elements:

- **Objects**: Basic units of encapsulation
- **Classes**: Templates for creating objects
- **Methods**: Functions associated with objects/classes
- **Properties**: Configurable instance variables
- **Variables**: Non-configurable instance state

#### 2. Method Types

Methods in NX can be:
- **Instance Methods**: Associated with class instances
- **Class Methods**: Associated with the class itself
- **Object Methods**: Specific to individual objects
- **Ensemble Methods**: Hierarchical method groupings

### Basic Syntax

```tcl
# Creating a class
nx::Class create ClassName {
    :property propertyName:required
    :variable internalVar {}
    
    :public method methodName {args} {
        # method body
    }
}

# Creating an object
ClassName create objectName
``` 

### Variables and Properties

#### Variable Scoping

NX provides three distinct variable scopes, identified by colon prefixes:

1. **Method-scoped Variables** (no colon)
   ```tcl
   set localVar "value"  # Only exists during method execution
   ```

2. **Instance Variables** (single colon)
   ```tcl
   set :instanceVar "value"  # Belongs to the object instance
   ```

3. **Global Variables** (double colon)
   ```tcl
   set ::globalVar "value"  # Global/namespace scope
   ```

#### Properties

Properties are configurable instance variables that provide a powerful way to define object attributes. They offer:

- Configuration at object creation
- Runtime value modification
- Automatic accessor methods
- Value constraints and validation

##### Property Definition Syntax

```tcl
nx::Class create Person {
    :property name:required          # Required property
    :property {age:integer 0}        # Typed property with default
    :property {active:boolean true}  # Boolean property with default
}
```

##### Property Features

1. **Required Properties**
   - Must be provided during object creation
   - Enforced at runtime
   ```tcl
   Person create person1 -name "John"  # Valid
   Person create person2               # Error: -name required
   ```

2. **Type Constraints**
   - `:integer` - Integer values
   - `:boolean` - Boolean values
   - `:double` - Floating point numbers
   - Custom validators possible

3. **Accessor Methods**
   - `cget` - Get property value
   - `configure` - Set property value
   ```tcl
   person1 cget -name           # Get name
   person1 configure -age 25    # Set age
   ```

#### Non-configurable Variables

For internal state that shouldn't be configurable, use the `:variable` declaration:

```tcl
nx::Class create Counter {
    :variable count 0    # Internal state
    
    :public method increment {} {
        incr :count
    }
}
```

Key differences from properties:
- No automatic accessors
- No configuration at creation time
- No built-in validation
- Simpler syntax for defaults 

### Methods and Method Combinations

#### Method Types and Definitions

1. **Instance Methods**
   ```tcl
   nx::Class create MyClass {
       :public method instanceMethod {args} {
           # Available to instances of MyClass
       }
   }
   ```

2. **Class Methods**
   ```tcl
   nx::Class create MyClass {
       :public object method classMethod {args} {
           # Only available to the class itself
       }
   }
   ```

3. **Object Methods**
   ```tcl
   MyClass create obj1 {
       :public object method objectMethod {args} {
           # Only available to obj1
       }
   }
   ```

#### Method Visibility

NX supports three levels of method visibility:

1. **Public Methods** (`:public`)
   - Accessible from anywhere
   - Default interface for the class/object

2. **Protected Methods** (`:protected`)
   - Accessible only from within the class hierarchy
   - Useful for internal class operations

3. **Private Methods** (`:private`)
   - Accessible only from within the defining class/object
   - Highest level of encapsulation

```tcl
nx::Class create Example {
    :public method publicMethod {} {
        # Accessible from anywhere
    }
    
    :protected method protectedMethod {} {
        # Only accessible within class hierarchy
    }
    
    :private method privateMethod {} {
        # Only accessible within this class
    }
}
```

#### Method Combination with `next`

NX provides powerful method combination through the `next` primitive:

```tcl
nx::Class create Animal {
    :public method speak {} {
        return "Animal sound"
    }
}

nx::Class create Dog -superclass Animal {
    :public method speak {} {
        return "Woof! [next]"
    }
}

nx::Class create Puppy -superclass Dog {
    :public method speak {} {
        return "Yip! [next]"
    }
}
```

The `next` primitive:
- Calls the next method in the inheritance chain
- Combines results from multiple method implementations
- Works with multiple inheritance
- Supports mixin methods

#### Ensemble Methods

Ensemble methods provide hierarchical command organization:

```tcl
nx::Class create FileManager {
    :public method "file open" {filename} {
        # Handle file opening
    }
    
    :public method "file close" {handle} {
        # Handle file closing
    }
    
    :public method "file read" {handle} {
        # Handle file reading
    }
}
```

Usage:
```tcl
FileManager create fm
fm file open "example.txt"
fm file read $handle
fm file close $handle
```

Benefits of ensembles:
- Logical grouping of related methods
- Namespace-like organization
- Extensible command structure
- Better code organization 

### Inheritance and Mixins

#### Class Inheritance

NX supports single and multiple inheritance:

```tcl
# Single inheritance
nx::Class create Animal {
    :public method move {} {
        return "Moving"
    }
}

nx::Class create Bird -superclass Animal {
    :public method move {} {
        return "Flying! [next]"
    }
}

# Multiple inheritance
nx::Class create Pet {
    :public method play {} {
        return "Playing"
    }
}

nx::Class create Parrot -superclass {Bird Pet} {
    :public method speak {} {
        return "Hello!"
    }
}
```

Key inheritance features:
- Method inheritance
- Property inheritance
- Variable inheritance
- Configurable parameters inheritance

#### Mixin Classes

Mixins provide a flexible way to extend functionality:

1. **Per-Class Mixins**
   ```tcl
   # Define a mixin class
   nx::Class create Logger {
       :public method log {msg} {
           puts "Log: $msg"
       }
   }
   
   # Apply mixin to a class
   nx::Class create MyClass {
       :property {mixins Logger}
   }
   ```

2. **Per-Object Mixins**
   ```tcl
   # Define behavior
   nx::Class create Timestamped {
       :public method getTimestamp {} {
           return [clock seconds]
       }
   }
   
   # Create object with mixin
   MyClass create obj1 -mixins Timestamped
   ```

#### Mixin Features

1. **Dynamic Application**
   ```tcl
   # Add mixin at runtime
   obj1 configure -mixins {Timestamped Logger}
   
   # Remove mixin
   obj1 configure -mixins {}
   ```

2. **Method Precedence**
   - Mixin methods take precedence over class methods
   - Multiple mixins follow left-to-right precedence
   - `next` can call shadowed methods

3. **Transitive Mixins**
   ```tcl
   nx::Class create TransitiveMixin {
       :property {mixinof ""}
   }
   ```

#### Filters

Filters provide aspect-oriented programming capabilities:

```tcl
nx::Class create Trace {
    :public method trace args {
        puts "Entering [self]: $args"
        set result [next]
        puts "Leaving [self]: $result"
        return $result
    }
}

# Apply filter
MyClass create obj2 -filters Trace
```

Filter features:
- Pre/post method execution hooks
- Method argument inspection
- Return value modification
- Stack trace capabilities 

### Advanced Features and Best Practices

#### Introspection

NX provides rich introspection capabilities:

```tcl
# Class information
MyClass info methods          # List all methods
MyClass info instances        # List all instances
MyClass info superclass      # Get superclass
MyClass info mixins          # List mixins

# Object information
obj1 info class             # Get object's class
obj1 info methods          # List object's methods
obj1 info vars            # List instance variables
obj1 info filters         # List applied filters
```

#### Meta-Programming

1. **Dynamic Method Creation**
   ```tcl
   nx::Class create DynamicClass {
       :public object method addMethod {name body} {
           :public method $name {} $body
       }
   }
   
   DynamicClass addMethod greet {
       return "Hello!"
   }
   ```

2. **Method Aliases**
   ```tcl
   nx::Class create Example {
       :public method original {} {
           return "Original method"
       }
       :alias alias original
   }
   ```

#### Best Practices

1. **Naming Conventions**
   - Use CamelCase for class names
   - Use lowercase for instance names
   - Use descriptive method names
   ```tcl
   nx::Class create BankAccount {
       :public method depositAmount {amount} { ... }
       :public method withdrawAmount {amount} { ... }
   }
   ```

2. **Error Handling**
   ```tcl
   nx::Class create SafeOperation {
       :public method execute {cmd} {
           if {[catch {eval $cmd} result]} {
               :handleError $result
           }
           return $result
       }
       
       :protected method handleError {msg} {
           puts "Error: $msg"
       }
   }
   ```

3. **Documentation**
   ```tcl
   nx::Class create DocumentedClass {
       # Class description in comments
       
       :property {name:required}  ;# Required user name
       :property {age:integer 0}  ;# User age, defaults to 0
       
       :public method "user create" {
           # Creates a new user
           # Returns: user ID
       } {
           # Implementation
       }
   }
   ```

4. **Interface Design**
   - Use properties for configurable attributes
   - Keep internal state private
   - Provide clear public interfaces
   ```tcl
   nx::Class create Stack {
       :variable items {}        ;# Private state
       :public method push {item} { ... }
       :public method pop {} { ... }
       :public method isEmpty {} { ... }
   }
   ```

5. **Testing Practices**
   ```tcl
   nx::Class create TestCase {
       :public method assert {condition {msg ""}} {
           if {![expr $condition]} {
               error "Assertion failed: $msg"
           }
       }
       
       :public method setUp {} { }
       :public method tearDown {} { }
   }
   ```

#### Performance Considerations

1. **Object Creation**
   - Reuse objects when possible
   - Use object pools for frequent creation/destruction
   ```tcl
   nx::Class create ObjectPool {
       :variable pool {}
       :public method acquire {} { ... }
       :public method release {obj} { ... }
   }
   ```

2. **Method Calls**
   - Cache frequently used method results
   - Use ensemble methods for related operations
   - Avoid unnecessary method calls in loops

3. **Memory Management**
   - Explicitly destroy unused objects
   - Use weak references when appropriate
   - Monitor object lifecycle 

## API Reference

### Core Commands and Methods

#### Class Creation and Management

1. **nx::Class create** *className* ?*options*? ?*body*?
   - Creates a new class
   - Options:
     - `-superclass` *className*: Specify parent class
     - `-mixins` *classList*: Add mixin classes
     - `-filters` *filterList*: Add filters
   - Body: Class definition block

2. **nx::Object create** *objectName* ?*options*? ?*body*?
   - Creates a new object
   - Options:
     - `-class` *className*: Specify object's class
     - `-mixins` *mixinList*: Add object mixins
     - `-filters` *filterList*: Add object filters

#### Method Definition Commands

1. **:method** *name* *args* *body*
   - Defines an instance method
   - Modifiers:
     - `:public`
     - `:protected`
     - `:private`
   - Arguments:
     - Positional: `arg1 arg2`
     - Optional: `?arg?`
     - Variable: `args`
     - Defaults: `{arg default}`

2. **:object method** *name* *args* *body*
   - Defines an object-specific method
   - Same modifiers and argument options as `:method`

3. **:alias** *newName* *existingName*
   - Creates a method alias

#### Property and Variable Commands

1. **:property** *name* ?*options*?
   - Defines a configurable instance variable
   - Options:
     - `:required`
     - `:readonly`
     - `:type` *type*
     - `:default` *value*
     - `:convert` *converter*
     - `:validate` *validator*

2. **:variable** *name* ?*value*?
   - Defines a non-configurable instance variable

#### Introspection Commands

1. **info** *subcommand* ?*args*?
   - Subcommands:
     - `methods`: List all methods
     - `vars`: List instance variables
     - `class`: Get object's class
     - `superclass`: Get superclass
     - `mixins`: List mixins
     - `filters`: List filters
     - `precedence`: Show method resolution order

### Method Parameters

#### Parameter Types
1. Positional Parameters
   - Position determines meaning
   - Default is required
   - Syntax: `method name {x y}`
   - Example:
     ```tcl
     :public method foo {x y} {
       puts "x=$x y=$y"
     }
     # Call: obj foo 1 2
     ```

2. Non-Positional Parameters
   - Named parameters with `-` prefix
   - Default is optional
   - Order independent
   - Syntax: `method name {-x -y}`
   - Example:
     ```tcl
     :public method bar {-x -y} {
       puts "x=$x y=$y"
     }
     # Call: obj bar -y 3 -x 1
     ```

3. Mixed Parameters
   - Combine positional and non-positional
   - Non-positional must come first in call
   - Use `--` to end non-positional section
   - Example:
     ```tcl
     :public method baz {-x -y a} {
       puts "x=$x y=$y a=$a"
     }
     # Call: obj baz -x 1 100
     # Call: obj baz -- -y
     ```

#### Parameter Options
1. Required Parameters
   - Must be provided
   - Syntax: `param:required`
   - Example:
     ```tcl
     :public method foo {x:required y} {...}
     ```

2. Optional Parameters
   - Can be omitted
   - Syntax: `param:optional`
   - Example:
     ```tcl
     :public method foo {x y:optional} {...}
     ```

3. Default Values
   - For optional parameters
   - Positional syntax: `{param default_value}`
   - Non-positional syntax: `{-param default_value}`
   - Example:
     ```tcl
     :public method foo {{x 1} {y 2}} {...}
     :public method bar {{-x 10} {-y 20}} {...}
     ```

4. Type Constraints
   - Validate parameter values
   - Syntax: `param:type`
   - Common types: integer, double, boolean, string
   - Example:
     ```tcl
     :public method push {thing:integer} {...}
     ```

5. Multiple Options
   - Combine with commas
   - Example:
     ```tcl
     :public method foo {x:required,integer y:optional,double} {...}
     ```

#### Parameter Handling
1. Argument Checking
   - Automatic validation of required parameters
   - Type checking if specified
   - Default value assignment

2. Variable Scope
   - Parameters become local variables in method
   - Accessible by name without `-` prefix
   - Example:
     ```tcl
     :public method foo {-x -y} {
       puts "$x $y"  # Access without -
     }
     ```

3. Special Cases
   - Variable arguments: `args` parameter
   - End non-positional section: `--`
   - Access all parameters: `info args`

### Method Modifiers

1. **Visibility**
   - `:public`
   - `:protected`
   - `:private`

2. **Scope**
   - `:object`
   - No modifier (instance)

3. **Special**
   - `:abstract`
   - `:final`
   - `:virtual`

### Filter Commands

1. **:filter** *name* ?*options*?
   - Options:
     - `-order` *pre|post*
     - `-per-object`
     - `-per-class`

2. **:filters** *filterList*
   - Apply multiple filters

### Mixin Commands

1. **:mixin** *className*
   - Add a single mixin

2. **:mixins** *classList*
   - Add multiple mixins

3. **:object-mixin** *className*
   - Add per-object mixin

### Ensemble Methods

1. **Method Naming**
   ```tcl
   :public method "category action" {args} { ... }
   ```

2. **Submethod Access**
   ```tcl
   obj category action args
   ```

### Error Handling

1. **catch**
   ```tcl
   if {[catch {command} result]} {
       :handleError $result
   }
   ```

2. **error**
   ```tcl
   error "Error message"
   ```

### Object Lifecycle

1. **Creation**
   - `create`
   - `new`
   - `alloc`

2. **Initialization**
   - `init`
   - `configure`

3. **Destruction**
   - `destroy`
   - `cleanup`

### Method Resolution

1. **next**
   - Call next method in chain
   - Returns empty if no next method

2. **self**
   - Reference to current object

3. **my**
   - Call method on self 

### Variable and Property Commands

#### Variable Scopes
- No prefix (e.g., `set a 1`): Method-scoped variable
  - Created during method invocation
  - Deleted when method ends
  - Local to the method context

- Single colon prefix (e.g., `set :b 1`): Instance variable
  - Part of the object
  - Persists for object lifetime
  - Deleted when object is destroyed

- Double colon prefix (e.g., `set ::c 1`): Global variable
  - Global scope
  - Persists until explicitly unset or script termination
  - Can be placed in Tcl namespaces

#### Property Definition Commands
- `:property name:required`
  - Defines a required property that must be set during object creation
  - Accessible via `-name` configure parameter

- `:property {name:type default_value}`
  - Defines a property with type constraint and default value
  - Example: `:property {oncampus:boolean true}`

#### Property Access Commands
- `object cget -propertyname`
  - Gets the current value of a property
  - Example: `s1 cget -name`

- `object configure -propertyname value`
  - Sets a new value for a property
  - Validates against any type constraints
  - Example: `s1 configure -name "NewName"`

#### Property Type Constraints
- `:boolean` - Boolean values (true/false)
- `:integer` - Integer values
- `:double` - Floating-point values
- `:string` - String values
- `:required` - Property must be set during object creation

#### Property Options
- `default value` - Sets default value for property
- `readonly` - Property cannot be modified after initialization
- `private` - Property only accessible within the class
- `protected` - Property accessible by class and subclasses
- `public` - Property accessible from anywhere (default) 

### Method Definition Commands

#### Basic Method Definition
- `:method name {args} {body}`
  - Defines a method with given name, arguments, and body
  - Default visibility is package private

#### Method Visibility Modifiers
- `:public method name {args} {body}`
  - Method accessible from anywhere
- `:protected method name {args} {body}`
  - Method accessible only by class and subclasses
- `:private method name {args} {body}`
  - Method accessible only within the class

#### Object-Specific Methods
- `:public object method name {args} {body}`
  - Defines a method specific to the class object (class method)
  - Example: `Stack2 available_stacks`

#### Method Types
1. Scripted Methods
   - Defined with Tcl code in the method body
   - Example:
     ```tcl
     :public method bark {} {
       puts "[self] Bark, bark, bark."
     }
     ```

2. C-implemented Methods
   - Built-in methods implemented in C
   - Examples: `create`, `destroy`, `info`

3. Accessor Methods
   - Auto-generated for properties with `-accessor` option
   - Getter syntax: `object property get`
   - Setter syntax: `object property set value`
   - Example:
     ```tcl
     :property -accessor public {length:double 5}
     # Usage:
     # obj length get
     # obj length set 10
     ```

4. Forwarder Methods
   - Forward method calls to another object
   - Syntax: `:public object forward method_name target method`
   - Example:
     ```tcl
     :public object forward wag [self]::tail wag
     ```

#### Method Arguments
1. Required Arguments
   - Must be provided in the correct order
   - Example: `method push {thing}`

2. Type-Constrained Arguments
   - Arguments with type checking
   - Example: `method push {thing:integer}`

3. Optional Arguments
   - Arguments with default values
   - Example: `method create {name {options {}}}`

4. Variable Arguments
   - Accepts variable number of arguments
   - Example: `method process {args}`

#### Object Lifecycle Methods
1. Constructor
   - Method name: `init`
   - Called automatically when object is created
   - Example:
     ```tcl
     :method init {} {
       set :x 1
       next
     }
     ```

2. Destructor
   - Method name: `destroy`
   - Called automatically when object is destroyed
   - Example:
     ```tcl
     :method destroy {} {
       # cleanup code
       next
     }
     ```

### Method Protection and Applicability

#### Method Protection Levels
1. Public Methods
   - Accessible from any context
   - Syntax: `:public method name {args} {body}`
   - Define the public interface of a class/object

2. Protected Methods (Default)
   - Accessible only from the same object
   - Syntax: `:protected method name {args} {body}` or `:method name {args} {body}`
   - Intended for implementation details used by the class and subclasses

3. Private Methods
   - Accessible only from methods defined on the same entity (class/object)
   - Must be called with `-local` flag
   - Syntax: `:private method name {args} {body}`
   - Example:
     ```tcl
     :private method helper {a b} {expr {$a + $b}}
     :public method foo {a b} {: -local helper $a $b}
     ```

#### Method Invocation
1. Standard Invocation
   - `object method args`
   - Follows standard method resolution order

2. Local Invocation
   - `object : -local method args`
   - Only invokes local method definition
   - Required for private methods
   - Bypasses filters, mixins, and inheritance

#### Method Applicability
1. Instance Methods
   - Defined on a class
   - Applicable to instances of the class
   - Example:
     ```tcl
     nx::Class create C {
       :public method foo {} {return 1}
     }
     C create c1
     c1 foo  # Valid call
     ```

2. Object-Specific Methods
   - Defined on a specific object
   - Only applicable to that object
   - Example:
     ```tcl
     C create c1
     c1 public object method bar {} {return 2}
     ```

3. Class Methods
   - Defined on the class object
   - Applicable to the class itself
   - Example:
     ```tcl
     nx::Class create C {
       :public object method count {} {
         return [llength [:info instances]]
       }
     }
     ```

#### Method Aliases
- Register existing methods under new names
- Zero overhead for C-implemented methods
- Syntax: `:public alias new_name method_handle`
- Example:
  ```tcl
  :public alias warn [:info method handle bark]
  ```

#### Method Forwarding
- Redirect method calls to other objects/methods
- Supports argument reordering and pattern substitution
- Syntax: `:public object forward method_name target method`
- Example:
  ```tcl
  :public object forward wag [self]::tail wag
  ``` 

### Inheritance and Method Resolution

#### Class Inheritance
- Defined using `-superclass` option
- Syntax: `nx::Class create ClassName -superclass SuperClass`
- Inherits methods, properties, and variables
- Example:
  ```tcl
  nx::Class create Base {
    :public method foo {} {return 1}
  }
  nx::Class create Derived -superclass Base {
    :public method bar {} {return 2}
  }
  ```

#### Mixin Classes
1. Per-Object Mixins
   - Added to specific objects
   - Highest precedence in method resolution
   - Syntax: `object object mixins add MixinClass`
   - Example:
     ```tcl
     obj object mixins add M1
     ```

2. Per-Class Mixins
   - Added to classes
   - Applied to all instances
   - Syntax: `Class mixins add MixinClass`
   - Example:
     ```tcl
     C mixins add M2
     ```

#### Method Resolution Order
1. Search Sequence (highest to lowest precedence):
   - Per-object Mixins
   - Per-class Mixins
   - Object-specific Methods
   - Intrinsic Class Hierarchy

2. Method Chaining
   - Use `next` to call shadowed methods
   - Example:
     ```tcl
     :public method foo {} {
       return "Current foo: [next]"
     }
     ```

3. Introspection
   - Query precedence order: `object info precedence`
   - Query method origin: `object info method origin methodname`

#### Ensemble Methods
- Hierarchical method organization
- Container methods with sub-methods
- First argument is sub-method selector
- Syntax: `:public method "container submethod" {args} {body}`
- Example:
  ```tcl
  :public method "string length" {x} {return [string length $x]}
  :public method "string tolower" {x} {return [string tolower $x]}
  ```

#### Method Shadowing
1. Object Methods Shadow Class Methods
   - Object-specific methods take precedence
   - Can access shadowed methods via `next`

2. Mixin Methods Shadow Object Methods
   - Mixin methods have highest precedence
   - Can be chained with `next`

3. Class Hierarchy Resolution
   - Most specific class methods first
   - Base class methods last
   - `nx::Object` is implicit base class 

### Value Constraints and Validation

#### Built-in Value Constraints
1. Native Checkers
   - `integer` - Integer values
   - `boolean` - Boolean values
   - `double` - Floating-point values
   - `object` - Object references
   - `class` - Class objects
   - `metaclass` - Metaclass objects
   - `baseclass` - Base class objects

2. Type-Specific Constraints
   - Object type checking
   - Syntax: `param:object,type=ClassName`
   - Example:
     ```tcl
     :public method work {-person:object,type=Person} {...}
     ```

3. Tcl String Checkers
   - All `string is` checks
   - Examples: alnum, alpha, ascii, control, digit, graph, lower, print, punct, space, upper, xdigit

#### Custom Value Constraints
1. Defining Custom Checkers
   - Define on `nx::Slot`
   - Method name format: `type=checkername`
   - Can be scripted in Tcl
   - Example:
     ```tcl
     ::nx::Slot method type=groupsize {name value} {
       if {$value < 1 || $value > 6} {
         error "Value '$value' of parameter $name is not between 1 and 6"
       }
     }
     ```

2. Scripted Parameter Constraints
   - Can be defined inline with method/property
   - Use `-checkers` option for custom validation
   - Example:
     ```tcl
     :public method setAge {age} -checkers {
       if {$age < 0 || $age > 150} {
         error "Age must be between 0 and 150"
       }
     }
     
     :property {temperature:double} -checkers {
       if {$temperature < -273.15} {
         error "Temperature cannot be below absolute zero"
       }
     }
     ```

3. Parameterized Checkers
   - Accept additional arguments
   - Syntax: `param:checker,arg=value`
   - Can combine multiple constraints
   - Example:
     ```tcl
     ::nx::Slot method type=choice {name value arg} {
       if {$value ni [split $arg |]} {
         error "Value not in permissible values $arg"
       }
     }
     :public method color {c:choice,arg=red|green|blue} {...}
     
     ::nx::Slot method type=range {name value min max} {
       if {$value < $min || $value > $max} {
         error "Value must be between $min and $max"
       }
     }
     :property {score:integer,range,arg=0|100} {...}
     ```

4. Combining Constraints
   - Multiple constraints can be applied
   - Separated by commas
   - All constraints must pass
   - Example:
     ```tcl
     :public method process {
       value:integer,range,arg=1|10,choice,arg=1|3|5|7|9
     } {...}
     ```

#### Value Multiplicity
1. Multiplicity Specification
   - Format: `lower..upper`
   - Lower bound: 0 or 1
   - Upper bound: 1 or n (*)
   - Default: 1..1 (exactly one value)

2. Common Patterns
   - `0..1` - Optional single value
   - `1..1` - Required single value (default)
   - `0..n` - Optional multiple values
   - `1..n` - Required multiple values

3. Usage Examples
   ```tcl
   :public method example {
     values:integer,1..n          # At least one integer
     -optional:boolean,0..1       # Optional boolean
     -list:string,0..n           # Any number of strings
   } {...}
   ```

#### Validation Control
1. Global Settings
   - Enable/disable all checking
   - Performance vs. safety trade-off

2. Per-Usage Control
   - Selective validation
   - Method-level control
   - Example:
     ```tcl
     :public method foo {x:integer} -checkers false {...}
     ```

3. Error Handling
   - Automatic error messages
   - Type-specific error reporting
   - Custom error messages in checkers

### Configure Parameters and Object Initialization

#### Configure Parameters
1. Property-Based Parameters
   - Created from property definitions
   - Non-positional parameters with `-` prefix
   - Example:
     ```tcl
     nx::Class create Person {
       :property name:required
       :property birthday
     }
     Person create p1 -name Bob
     ```

2. Inheritance of Parameters
   - Parameters inherited from superclasses
   - Combined with local parameters
   - Example:
     ```tcl
     nx::Class create Student -superclass Person {
       :property matnr:required
       :property {oncampus:boolean true}
     }
     Student create s1 -name Susan -matnr 4711
     ```

3. Built-in Configure Parameters
   - Available for all NX objects
   - Defined by `nx::Object`
   - Common parameters:
     - `-object-mixins` - Per-object mixins
     - `-class` - Object's class
     - `-object-filters` - Per-object filters
     - `__initblock` - Initialization script (positional)

#### Parameter Default Substitution
1. Basic Substitution
   - Use `substdefault` option
   - Performs Tcl substitution on default values
   - Example:
     ```tcl
     :property {d:object,type=::D,substdefault {[::D new]}}
     ```

2. Substitution Control
   - Bit mask controls substitution types
   - Values:
     - `0b111` - All substitutions (default)
     - `0b100` - Backslashes only
     - `0b010` - Variables only
     - `0b001` - Commands only
     - `0b000` - No substitution

#### Object Configuration Methods
1. At Creation
   - Via `create` or `new`
   - Example:
     ```tcl
     Class create obj -param1 value1 -param2 value2
     ```

2. After Creation
   - `configure` - Set parameter values
   - `cget` - Get parameter values
   - Example:
     ```tcl
     obj configure -param1 newvalue
     obj cget -param1
     ```

3. Introspection
   - Query available parameters
   - Syntax information
   - Example:
     ```tcl
     obj info lookup parameters configure
     obj info lookup syntax configure
     ```

#### Parameter Validation
1. Property-Based Validation
   - Type checking
   - Required parameters
   - Default values
   - Example:
     ```tcl
     :property {age:integer 0}
     :property name:required
     ```

2. Dynamic Validation
   - Custom validation methods
   - Pre/post configuration hooks
   - Example:
     ```tcl
     :public method validate_age {value} {
       if {$value < 0} {error "Age cannot be negative"}
     }
     ```

3. Error Handling
   - Automatic error messages
   - Configuration rollback
   - Custom error handling

### Unknown Handlers and Dynamic Creation

#### Method Unknown Handlers
1. Basic Unknown Method Handling
   - Catches calls to undefined methods
   - Provides opportunity for dynamic method handling
   - Example:
     ```tcl
     nx::Class create DynamicClass {
       :public method unknown {method args} {
         switch $method {
           "get*" {
             # Handle getter methods
             set property [string range $method 3 end]
             return [: cget -$property]
           }
           "set*" {
             # Handle setter methods
             set property [string range $method 3 end]
             : configure -$property [lindex $args 0]
           }
           default {
             error "Unknown method '$method'"
           }
         }
       }
     }
     
     DynamicClass create obj
     obj setName "John"    # Dynamically handled
     puts [obj getName]    # Returns "John"
     ```

2. Method Forwarding
   - Forward unknown methods to other objects
   - Example:
     ```tcl
     nx::Class create Wrapper {
       :property target
       
       :public method unknown {method args} {
         if {[${:target} info methods $method] ne ""} {
           return [${:target} $method {*}$args]
         }
         next
       }
     }
     ```

3. Method Generation
   - Create methods on demand
   - Cache generated methods for future use
   - Example:
     ```tcl
     nx::Class create AutoMethods {
       :public method unknown {method args} {
         if {[string match "compute*" $method]} {
           # Create method dynamically
           :public method $method {x y} {
             expr {$x * $y}
           }
           # Call the newly created method
           return [: $method {*}$args]
         }
         next
       }
     }
     
     AutoMethods create calc
     puts [calc computeProduct 5 3]  # First call creates method
     puts [calc computeProduct 2 4]  # Uses cached method
     ```

#### Object/Class Unknown Handlers
1. Class Creation Handlers
   - Handle references to undefined classes
   - Support lazy loading of classes
   - Example:
     ```tcl
     # Define a handler for loading classes from files
     ::nx::Class public object method __unknown {name} {
       set filename [string tolower $name].tcl
       if {[file exists $filename]} {
         source $filename
         if {[::nx::Class info instances $name] ne ""} {
           return $name
         }
       }
       error "Cannot load class '$name'"
     }
     
     # Register the handler
     ::nsf::object::unknown::add loader {::nx::Class __unknown}
     ```

2. Multiple Unknown Handlers
   - Register multiple handlers with different keys
   - Handlers tried in registration order
   - Example:
     ```tcl
     # Handler for database-stored classes
     ::nx::Class public object method loadFromDB {name} {
       if {[database hasClass $name]} {
         set def [database getClassDef $name]
         eval $def
         return $name
       }
       return ""
     }
     
     # Handler for network-stored classes
     ::nx::Class public object method loadFromNetwork {name} {
       if {[network hasClass $name]} {
         set def [network getClassDef $name]
         eval $def
         return $name
       }
       return ""
     }
     
     # Register multiple handlers
     ::nsf::object::unknown::add db {::nx::Class loadFromDB}
     ::nsf::object::unknown::add net {::nx::Class loadFromNetwork}
     ```

3. Handler Management
   - Commands for managing unknown handlers
   - Example:
     ```tcl
     # List all registered handlers
     puts [::nsf::object::unknown::keys]
     
     # Get specific handler
     set handler [::nsf::object::unknown::get db]
     
     # Remove handler
     ::nsf::object::unknown::delete db
     
     # Add new handler
     ::nsf::object::unknown::add cache {::nx::Class loadFromCache}
     ```

4. Application Examples
   - Lazy loading of components
   - Plugin architecture
   - Example:
     ```tcl
     nx::Class create PluginManager {
       :property plugins:object,type=::nx::Class
       
       :public object method __unknown {name} {
         # Check plugin directory
         set plugin_file [file join plugins ${name}.tcl]
         if {[file exists $plugin_file]} {
           source $plugin_file
           return $name
         }
         # Check plugin registry
         if {[registry hasPlugin $name]} {
           set def [registry getPluginDef $name]
           eval $def
           return $name
         }
         error "Plugin '$name' not found"
       }
       
       :public method loadPlugin {name} {
         if {[: info vars plugins] eq ""} {
           set :plugins [list]
         }
         lappend :plugins [$name new]
       }
     }
     
     # Register plugin manager's unknown handler
     ::nsf::object::unknown::add plugins {::PluginManager __unknown}
     ```

5. Best Practices
   - Use unknown handlers sparingly
   - Cache results when possible
   - Handle errors gracefully
   - Example:
     ```tcl
     nx::Class create SafeUnknown {
       :variable method_cache
       
       :public method unknown {method args} {
         if {[info exists :method_cache($method)]} {
           return [: {*}${:method_cache($method)} {*}$args]
         }
         
         if {[catch {: generateMethod $method} def]} {
           error "Cannot handle method '$method': $def"
         }
         
         set :method_cache($method) $def
         return [: {*}$def {*}$args]
       }
       
       :protected method generateMethod {method} {
         # Method generation logic here
       }
     }
     ```

### Introspection Commands

#### Object Introspection
1. Info Commands
   - `info class` - Get object's class
   - `info mixins` - List object's mixins
   - `info filters` - List object's filters
   - `info vars` - List object's variables
   - `info methods` - List object's methods

2. Method Information
   - `info method args methodname` - Get method arguments
   - `info method body methodname` - Get method body
   - `info method origin methodname` - Get method's defining class
   - `info method parameters methodname` - Get parameter info

3. Property Information
   - `info lookup parameters configure` - List configure parameters
   - `info lookup syntax configure` - Get configuration syntax
   - `cget -propertyname` - Get property value

#### Class Introspection
1. Class Structure
   - `info superclass` - Get superclass(es)
   - `info subclass` - Get subclass(es)
   - `info instances` - List class instances
   - `info precedence` - Show method resolution order

2. Class Features
   - `info properties` - List class properties
   - `info slots` - List class slots
   - `info heritage` - Show class hierarchy

3. Method Resolution
   - `info method lookup methodname` - Show method lookup path
   - `info method exists methodname` - Check method existence
   - `info method protection methodname` - Get method protection level

#### Slot Introspection
1. Slot Information
   - `info slot` - Get slot information
   - `info slot type` - Get slot type
   - `info slot options` - Get slot options

2. Parameter Types
   - `info parameter type` - Get parameter type
   - `info parameter default` - Get default value
   - `info parameter multiplicity` - Get multiplicity

#### Method Lookup and Information
1. Method Lookup
   - `info lookup methods` - List all available methods
   - `info lookup syntax methodname` - Get method syntax
   - `info lookup parameters methodname` - Get method parameters
   - `info lookup definition methodname` - Get method definition
   - `info lookup protection methodname` - Get method protection level
   - `info lookup origin methodname` - Get method's defining class

2. Method Search Paths
   - `info lookup search methodname` - Show method search path
   - `info lookup submethods methodname` - List submethods of ensemble
   - `info lookup filters methodname` - Show filters for method

3. Method Flags and Options
   - `info lookup flags methodname` - Show method flags
   - `info lookup checkers methodname` - Show value checkers
   - `info lookup returns methodname` - Show return value constraints