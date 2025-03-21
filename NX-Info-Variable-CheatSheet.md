# NX Info Variable and Parameter Cheatsheet

## Class Information Commands

### Parameter Information
```tcl
# Get list of parameters for class creation
/cls/ info configure parameters ?pattern?

# Get syntax output for class creation
/cls/ info configure syntax

# Get method parameters
/cls/ info method parameters /methodname/ ?/pattern/?

# Get method syntax
/cls/ info method syntax /methodname/

# Get variable handles
/cls/ info variables ?/pattern/?
```

### Object Information
```tcl
# Get object method parameters
/obj/ info object method parameters /methodname/ ?/pattern/?

# Get object method syntax
/obj/ info object method syntax /methodname/

# Get object variable handles
/obj/ info object variables ?/pattern/?
```

### Lookup Information
```tcl
# Get parameters from class hierarchy
/obj/ info lookup configure parameters ?/pattern/?

# Get syntax from class hierarchy
/obj/ info lookup configure syntax

# Get variable handles from class hierarchy
/obj/ info lookup variables ?/pattern/?
```

### Context-free Operations
```tcl
# Work on any object (does not need object)
/obj/ info parameter list|name|syntax /param/
/obj/ info variable definition|name|parameter /handle/
```

## Parameter Handling with `nsf::parameter::info`

### Basic Commands
```tcl
# Get parameter syntax representation
nsf::parameter::info syntax parameter_definition

# Get parameter name
nsf::parameter::info name parameter_definition

# Check if parameter has default value
nsf::parameter::info default parameter_definition ?varname?

# Get parameter type
nsf::parameter::info type parameter_definition
```

### Examples
```tcl
nsf::parameter::info syntax age:integer         # Returns: "/age/"
nsf::parameter::info syntax -force:switch       # Returns: "?-force?"
nsf::parameter::info name "a b"                 # Returns: "a"
nsf::parameter::info default "b:integer 123"    # Returns: 1 (has default)
nsf::parameter::info type "age:integer"         # Returns: "integer"
```

## Variable and Property Definition Examples

### Class Level Properties and Variables
```tcl
# Basic property
:property name

# Typed property
:property age:integer

# Property with default value
:property {b:integer 123}

# Variable with default value
:variable c 456

# Typed variable with default
:variable d:lower abc

# Public accessor
:variable -accessor public e:lower efg

# Private accessor
:property -accessor private {p 19}

# Protected accessor
:property -accessor protected q

# Incremental property
:property -incremental i
```

### Object Level Properties and Variables
```tcl
# Object property
:object property oa:integer

# Object property with default
:object property {ob:integer 123}

# Object variable
:object variable oc 456

# Object variable with type
:object variable od:lower abc

# Public object variable
:object variable -accessor public oe:lower efg

# Incremental object property
:object property -incremental oi

# Private object property
:object property -accessor private {op 19}

# Protected object property
:object property -accessor protected oq
```

## Slot and Variable Information

### Getting Slot Information
```tcl
# List all slots
::Foo info slots

# Get specific slot
::Foo info slots p

# Get slot definition
::Foo::slot::b definition
```

### Getting Variable Information
```tcl
# List all variables
::Foo info variables

# List specific variable
::Foo info variables p

# Get variable definition
::Foo info variable definition handle

# Get variable parameter
::Foo info variable parameter handle

# Get variable name
::Foo info variable name handle
```

### Lookup Variables
```tcl
# Get count of lookup variables
llength [::f1 info lookup variables]

# List all lookup variables (includes inherited)
::f1 info lookup variables

# Search for specific lookup variables
::f1 info lookup variables p
```

## Accessor Usage Patterns

### Private and Protected Access
```tcl
# Private property access via method
:public method m {} {: -local p get}

# Object-level private property access
:public object method om {} {: -local p}
```

## Variable Naming Notes

- Private properties are prefixed with `____ClassName` in slot names
- Per-object variables use `per-object-slot` namespace
- Private properties in name output appear as `__private(namespace,name)` 