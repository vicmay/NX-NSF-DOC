# NX Properties Cheatsheet

## Basic Concepts

NX is a Tcl-based object-oriented framework with comprehensive property support. This cheatsheet covers the key aspects of working with properties in NX.

## Property Declaration Syntax

### Class Level Properties

```tcl
# Basic property
:property {name defaultValue}

# Property with accessor
:property -accessor public|protected|private|none {name defaultValue}

# Incremental property (for collections)
:property -incremental {name defaultValue}

# Property with type and multiplicity
:property -incremental name:type,multiplicity

# Non-configurable property
:property -accessor none -configurable false {name defaultValue}
```

### Object Level Properties

```tcl
# Object property
:object property {name defaultValue}

# Object property with accessor
:object property -accessor public|protected|private|none {name defaultValue}

# Incremental object property
:object property -incremental {name defaultValue}
```

### Variables vs Properties

```tcl
# Variables (similar to properties but with different semantics)
:variable name defaultValue
:variable -accessor public|protected|private|none name defaultValue
:variable -incremental name defaultValue

# Object variables
:object variable name defaultValue
:object variable -accessor public|protected|private|none name defaultValue
:object variable -incremental name defaultValue
```

## Accessor Visibility

* **public**: Accessible from anywhere
* **protected**: Accessible only from methods in the class and its subclasses
* **private**: Accessible only from methods within the class
* **none**: No accessor method is created

## Incremental Properties

The `-incremental` flag changes property behavior:

* Creates an accessor even when not explicitly requested
* Enables collection operations (add, delete)
* Makes properties multivalued by default

## Property Operations

### Standard Property Access

```tcl
# Configure a property (requires property to be public or using configure interface)
object configure -propertyName value

# Get property value
object cget -propertyName

# Using accessor methods (if available)
object propertyName get
object propertyName set newValue
```

### Incremental Property Operations

```tcl
# Add value to collection
object propertyName add value

# Set entire collection
object propertyName set {value1 value2 value3}

# Delete value from collection
object propertyName delete value

# Delete with no error if value not found
object propertyName delete -nocomplain value

# Check if property exists
object propertyName exists

# Unset property
object propertyName unset
```

### Protected and Private Access

Access to protected and private properties is controlled:

```tcl
# From within a method in the same class
: -local propertyName get
: -local propertyName set value
: -local propertyName add value
```

## Introspection

```tcl
# List available configure options
object info lookup syntax configure

# Check if a property method exists
object info lookup method propertyName

# Get all slots in a class
Class info slots

# Get slot definition
::Class::slot::propertyName definition

# Check property protection level
nsf::method::property Class propertyName call-protected
nsf::method::property Class propertyName call-private

# Check instance variables
object info vars

# Get object slot
object info object slots propertyName

# Get multiplicity of a property
[object info object slots propertyName] eval {set :multiplicity}

# Get variable definition
object info variable definition [object info object variables propertyName]
```

## Property Multiplicity

* **0..n**: Zero or more values (default for incremental properties)
* **1..n**: One or more values (non-empty)
* **0..1**: Zero or one value (optional)
* **1..1**: Exactly one value (required)

## Private Storage

Private properties are stored in the `__private` array:

```tcl
# Access the private storage (from within a method)
array get :__private
```

## Property Inheritance

* Properties defined in a superclass are inherited by subclasses
* Properties from mixins are also available
* Adding a property to a superclass or mixin makes it available to all dependent classes

## Common Patterns and Best Practices

1. Use `-accessor none` when you just need storage without accessors
2. Use `-incremental` for collection properties
3. Use public accessors for properties that need external access
4. Use protected and private for implementation details
5. Use proper type and multiplicity constraints to validate property values
6. Check property existence before access with `exists`
7. Default accessors can be configured globally with `nx::configure defaultAccessor` 