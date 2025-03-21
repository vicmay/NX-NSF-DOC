# NX Contains Test Cheatsheet

## Overview
This cheatsheet summarizes key concepts and examples from the NX contains test file, which demonstrates various features of the NX Tcl extension, particularly focusing on object containment and namespace handling.

## Key Concepts

### Class Creation and Properties
```tcl
Class create Tree {
  :property label
  :property contains:alias
  :property foo:alias
  :public method foo {arg} {set :x $arg}
}
```

### Object Creation with Contains
- Objects can be created with `-contains` flag to define nested structure
- Inside contains block:
  - `self` refers to current object
  - `namespace current` gives current namespace

### Example Patterns

#### Basic Object Creation
```tcl
Tree create 1 -label 1 -contains {
  Tree create 1.1 -label 1.1
}
```

#### Nested Object Creation
```tcl
Tree create t -contains {
  Tree create branch    # Creates ::t::branch
  Tree new             # Creates ::t::__#1 (automatic naming)
}
```

### Error Handling
- Error codes propagate properly from within contains blocks
- Example:
```tcl
catch {
  Arbre create root {
    :contains {
      return -code error -errorcode MYERR
    }
  }
}
```

### Important Notes

1. **Namespace Handling**
   - Contains blocks create proper namespace hierarchies
   - Objects created within contains blocks are properly namespaced

2. **Method Resolution**
   - `next` command works without explicit namespace imports
   - Method name paths are properly computed

3. **Object System Compatibility**
   - Cannot mix different object systems (e.g., XOTcl and NX) in class hierarchies
   - Error will be thrown if attempting to mix object systems

4. **Error Propagation**
   - Error codes and messages properly propagate from contains blocks
   - Maintains proper error stack traces

## Best Practices

1. Use proper namespace paths when creating nested objects
2. Handle errors appropriately in contains blocks
3. Be aware of object system compatibility when extending classes
4. Use proper method creation syntax (`:public method` etc.)

## Common Patterns

### Creating Nested Structures
```tcl
ParentClass create parent -contains {
  ChildClass create child1
  ChildClass create child2 -contains {
    ChildClass create grandchild
  }
}
```

### Property and Method Definition
```tcl
Class create MyClass {
  :property myProperty
  :property myAlias:alias
  :public method myMethod {arg} {
    # method implementation
  }
}
```

---
*Note: This cheatsheet is based on the contains.test file from the NX Tcl extension tests.* 