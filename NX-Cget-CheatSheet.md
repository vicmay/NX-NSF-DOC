# NX Framework cget/configure Cheatsheet

## Basic Usage

### cget Command
- Used to get property values from objects
- Basic syntax: `object cget -propertyName`
- Always requires `-` before parameter names

### configure Command
- Used to set property values on objects
- Basic syntax: `object configure -propertyName value`
- Can set multiple properties: `object configure -prop1 val1 -prop2 val2`

## Property Types

### Basic Properties
```tcl
:property famnam:required              # Required property
:property {age:integer,required 0}     # Required integer with default 0
:property {friends:0..n ""}           # Multi-value property with empty default
:property sex                         # Simple property
```

### Property Accessors
```tcl
:property -accessor public {age:integer,required 0}  # Creates public accessor methods
```

### Property with Custom Get/Set Methods
```tcl
:property propertyName {
    :public object method value=get { object property } {
        # Custom getter logic
    }
    :public object method value=set { object property value } {
        # Custom setter logic
    }
}
```

## Special Properties

### Built-in Properties
- `-class`: Returns the class of an object
- `-superclasses`: List of superclasses
- `-superclass`: Direct superclass
- `-object-mixin`: Object-level mixins
- `-mixin`: Class-level mixins
- `-filter`: Filters
- `-volatile`: Volatility flag

### Property Flags
- `:required` - Property must be set
- `:integer` - Value must be an integer
- `:0..n` - Allows multiple values
- `:alias` - Creates method alias
- `:forward` - Forwards method calls

## Error Handling

### Common Errors
- Wrong number of arguments: `wrong # of arguments: should be "cget /name/"`
- Unknown parameter: `cget: unknown configure parameter -paramName`
- Invalid parameter format: `cget: parameter must start with a '-'`
- Unset property: `can't read "propertyName": no such variable`

## Property Tracing

### Class-level Trace
```tcl
Class property -trace set propertyName {
    :public object method value=set {obj var value} {
        # Trace logic here
    }
}
```

### Object-level Trace
```tcl
object property -trace set propertyName {
    :public object method value=set {obj var value} {
        # Trace logic here
    }
}
```

## Best Practices

1. Always use `-` prefix for property names in cget/configure
2. Set required properties during object creation
3. Use appropriate type constraints (`:integer`, etc.)
4. Implement custom get/set methods for complex property behavior
5. Use property tracing for monitoring/modifying property changes

## Examples

### Basic Object Creation and Configuration
```tcl
nx::Class create Person {
    :property famnam:required
    :property {age:integer,required 0}
}

Person create p1 -famnam hugo -age 25
p1 cget -age          # Returns: 25
p1 configure -age 27  # Changes age to 27
```

### Property with Custom Behavior
```tcl
:property bar {
    :public object method value=get { object property } {
        nsf::var::set $object $property
    }
    :public object method value=set { object property value } {
        nsf::var::set $object $property $value
    }
}
```

### Property with Trace
```tcl
property -trace set propertyName {
    :public object method value=set {obj var value} {
        nsf::var::set -notrace $obj $var [expr {$value + 1}]
    }
}
``` 