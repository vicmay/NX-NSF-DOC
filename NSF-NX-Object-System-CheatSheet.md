# NSF/NX Object System Cheatsheet

## Core Packages

```tcl
package require nsf     # Next Scripting Framework
package require nx      # NX object system
```

## Base Classes

- `nx::Object`: Base object class for all objects
- `nx::Class`: Metaclass for creating classes (instance of itself)

## Object Creation and Destruction

```tcl
# Create an object
nx::Object create objectName
nx::Object create objectName { 
  # initialization code
}

# Create a class
nx::Class create ClassName
nx::Class create ClassName -superclass ParentClass
nx::Class create ClassName -superclass {Parent1 Parent2} # multiple inheritance

# Create an instance of a class
ClassName create instanceName
ClassName new       # creates autonamed instance (::nsf::__#n)

# Destroy an object
objectName destroy
```

## Method Definition and Dispatch

```tcl
# Define methods
obj public object method methodName {} {
  # method body
}

# Method dispatch patterns
o foo                    # simple method dispatch
o bar1                   # normal method call
[:foo]                   # colon-methodname dispatch
[: foo]                  # colon cmd dispatch
[[self] foo]             # self dispatch
[self]::methodName       # self cmd
[:]::methodName          # colon cmd
```

## Properties

```tcl
# Define properties in a class
nx::Class create C {
  :property {propertyName defaultValue}
  :property propertyName
}

# Accessing properties at creation time
C create c1 -propertyName value
```

## Variables and Instance Variables

```tcl
# Setting instance variables
set :varName value       # Inside object context

# Checking if an instance variable exists
info exists :varName

# Accessing instance variables from outside
::nx::var set objName varName
```

## Object Introspection

```tcl
# Check if an object exists
::nsf::object::exists objectName

# Check if an object is a class or metaclass
::nsf::is class objectName
::nsf::is metaclass objectName

# Get object information
obj info class           # get the class of an object
obj info superclasses    # get superclasses
obj info baseclass       # get the base class
obj info precedence      # get the method resolution order
obj info vars            # get instance variables
obj info children        # get child objects
obj info instances       # get instances of a class
obj info instances -closure # get all instances including subclass instances
obj info lookup parameters create # get parameter info
```

## NSF Low-Level Functions

```tcl
# Method creation
nsf::method::create ::ClassName methodName {} {body}
nsf::method::create ::ClassName -per-object=true methodName {} {body}  # object method
nsf::method::create ::ClassName -per-object=false methodName {} {body} # class method

# Method aliasing
nsf::method::alias ::class methodName targetMethod

# Dispatch
::nsf::dispatch objName method args...
::nsf::directdispatch objName -frame object|method cmd args...

# Object relationships
::nsf::relation::get objName class|superclass
```

## Custom Object Systems

```tcl
# Create a minimal object system
::nsf::objectsystem::create ::baseObjectClass ::baseMetaClass

# Define methods for custom object system
::nsf::method::alias ::class methodName targetMethod
```

## Configuration

```tcl
# Enable/disable debug tracing
::nsf::configure dtrace on|off

# Keep initialization commands
::nsf::configure keepcmds 1
```

## Object Copying

```tcl
# Copy an object or class
objName copy newName
objName copy    # creates autonamed copy
```

## Safety Mechanisms

- Protection against deleting base classes (`nx::Object`, `nx::Class`)
- Protection against overwriting existing procedures with objects
- Protection against overwriting child objects with methods
- Protection against overwriting object methods with child objects

## Common Patterns

1. Diamond inheritance patterns (multiple inheritance)
2. Metaclass creation and usage
3. Object initialization patterns
4. Method dispatch patterns with colons and self
5. Property definition and access 