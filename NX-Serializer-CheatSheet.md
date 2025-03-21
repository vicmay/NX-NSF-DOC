# NX Serializer Cheatsheet

This cheatsheet provides a comprehensive overview of the nx::serializer package based on test cases from the NextScripting Framework.

## Basic Serialization

### Object Serialization

```tcl
# Serialize an object
set script [object serialize]

# Eval the script to recreate the object
eval $script
```

### Target Mapping

```tcl
# Serialize an object with a target mapping (different name/namespace)
set script [object serialize -target NewObjectName]

# The serialized object will be created with the new target name
eval $script
```

## Deep Serialization

### Basic Deep Serialization

```tcl
# Serialize an object and all its children
set script [::Serializer deepSerialize object]

# Recreate the object hierarchy
eval $script
```

### Name Mapping

```tcl
# Remap object names during serialization
set script [::Serializer deepSerialize -map {::old::name ::new::name} object]

# Example with multiple mappings
set script [::Serializer deepSerialize -map {::a::b ::x::y ::a ::x} ::a]
```

### Filtering Variables

```tcl
# Ignore no variables (serialize all)
set script [::Serializer deepSerialize -ignoreVarsRE "" object]

# Ignore variables matching a pattern
set script [::Serializer deepSerialize -ignoreVarsRE "pattern" object]

# Ignore all variables
set script [::Serializer deepSerialize -ignoreVarsRE "." object]

# Specific variable filtering examples:
# Ignore variables ending with 'a'
set script [::Serializer deepSerialize -ignoreVarsRE {::a$} object]

# Exclude specific slot names
set names {}
foreach s [Class info slots] {
  lappend names [$s cget -name]
}
set script [::Serializer deepSerialize -ignoreVarsRE [join $names |] object]
```

### Ignoring Objects

```tcl
# Serialize a parent object but exclude a specific child
set script [::Serializer deepSerialize -ignore ::parent::child ::parent]
```

## Slot Container Handling

Serialization preserves slot containers and their relationships:

```tcl
# Class with properties
nx::Class create C {
  :object property x
  :property a
}

# Serializing preserves slot containers
set script [C serialize]
```

## Object Properties Preservation

Serialization preserves important object properties:

```tcl
# Set object properties
::nsf::object::property ::object keepcallerself 1
::nsf::object::property ::object perobjectdispatch 1

# Properties are preserved after serialization
set script [object serialize]
```

## Method Properties Preservation

Method properties like `-debug` and `-deprecated` are preserved:

```tcl
# Define methods with properties
nx::Object create o {
  :public object method -deprecated method1 {} {return 1}
  :public object method -debug method2 {} {return 1}
  :public alias -deprecated -debug aliasName ::command
}

# Properties are preserved after serialization
set script [o serialize]
```

## Specific Serialization Functions

### Method Serialization

```tcl
# Serialize a specific method
set script [::Serializer methodSerialize object methodName ""]
```

## Integration with XOTcl

```tcl
# XOTcl compatibility
package require XOTcl
package require xotcl::serializer

# Serialize XOTcl class info
::Serializer methodSerialize ::xotcl::classInfo default ""
```

## Common Patterns and Best Practices

1. Always check if the serialized object exists after deserialization:
   ```tcl
   ? {::nsf::object::exists ::object} 1
   ```

2. Verify that properties and relationships are preserved:
   ```tcl
   ? {::nsf::method::property object method property} value
   ? {::nsf::var::get object::slot property} value
   ```

3. For renaming/remapping objects, use the `-map` option with the `-target` option as needed

4. Use `-ignore` to exclude specific objects from serialization

5. Use `-ignoreVarsRE` with regular expressions to filter which variables are serialized

## Troubleshooting

- Check if the object hierarchy is correctly serialized with `::nsf::object::exists`
- Verify slot containers are preserved in classes with `::nx::isSlotContainer`
- Test forwarder targets after serialization with `nsf::method::forward::property` 