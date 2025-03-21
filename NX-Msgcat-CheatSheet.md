# Tcl Msgcat Package Cheatsheet for Next Scripting Framework

## Basic Usage

### Loading the Package
```tcl
package req msgcat
```

### Setting Messages
```tcl
# Set a message in the current locale
::msgcat::mcset [::msgcat::mclocale] message_key "message text"

# Example with namespace context in message
::msgcat::mcset [::msgcat::mclocale] m1 "[namespace current] message1"
```

### Accessing Messages
```tcl
# Import mc command for easier access
namespace import ::msgcat::mc

# Retrieve a message
mc message_key
```

## Namespace Behavior

The `msgcat` package respects Tcl namespaces when looking up messages:

1. Messages are first looked up in the current namespace
2. If not found, msgcat looks in parent namespaces
3. Finally falls back to the global namespace

### Example Namespace Structure:
```
::              (global)
  ↓
::foo           (child namespace)
  ↓
::foo::bar      (grandchild namespace)
```

## Integration with Next Scripting Framework

### Within nx::Class Definitions
```tcl
nx::Class create ClassName {
  :require namespace
  
  # Using mc in class definition
  ? [list set _ [mc message_key]] $expected_value
  
  # Using mc in instance methods
  :public method methodName {} {
    return [mc message_key]
  }
  
  # Using mc in object methods
  :public object method methodName {} {
    return [mc message_key]
  }
  
  # Using mc in property accessors
  :property propName {
    :public object method value=get {args} {
      return [namespace current]-[mc message_key]
    }
  }
}
```

### Custom Property Behavior with Msgcat
```tcl
:property -accessor public propName {
  :public object method value=set {obj prop value} {
    ::msgcat::mcset [::msgcat::mclocale] $value "new message"
    next
  }
  
  :public object method value=get {args} {
    mc [next]
  }
}
```

### Testing Message Resolution
```tcl
# Test instance method result
? {[::Namespace::ClassName new] methodName} $expected_value

# Test object method result
? {::Namespace::ClassName methodName} $expected_value

# Test property access
? {[::Namespace::ClassName new] cget -propName} $expected_value
```

## Key Concepts

1. **Namespace Awareness**: Messages are bound to their defining namespace
2. **Locale Management**: `::msgcat::mclocale` returns or sets the current locale
3. **Message Setting**: `::msgcat::mcset` associates a key with a message in a locale
4. **Message Retrieval**: `::msgcat::mc` (or imported `mc`) retrieves messages based on context
5. **Inheritance**: Messages cascade from child to parent namespaces 