# NX Plain Object Method Cheatsheet

## Overview
The `nx::plain-object-method` is a convenience layer for Next Scripting Framework (NX) that enables object-oriented functionality directly on plain objects.

## Basic Usage

### Loading the Package
```tcl
package require nx::plain-object-method
```

### Configure Warnings
```tcl
# Enable warnings
nx::configure plain-object-method-warning on

# Disable warnings
nx::configure plain-object-method-warning off
```

## Object Creation and Methods

### Creating Objects
```tcl
nx::Object create ::o {
    # Define methods, properties, and variables here
}
```

### Method Types
```tcl
nx::Object create ::o {
    # Public method
    :public method foo {} {return foo}
    
    # Protected method
    :protected method pm1 args {return pm1}
    
    # Private method
    :private method priv args {return priv}
    
    # Default method (protected)
    :method pm2 args {return pm2}
    
    # Object method
    :public object method f args {next}
}
```

### Method Aliases and Forwarding
```tcl
nx::Object create ::o {
    # Create an alias to another method
    :public alias a ::o::pm1
    
    # Create a forwarding method
    :public forward fwd %self pm1
}
```

## Properties and Variables

### Defining Properties
```tcl
nx::Object create ::o {
    # Property with public accessor
    :property -accessor public p
}
```

### Defining Variables
```tcl
nx::Object create ::o {
    # Simple variable
    :variable v1 1
    
    # Incremental variable with type constraint
    :variable -incremental v2:integer 1
}
```

## Mixins and Filters

### Setting Mixins
```tcl
# Create a mixin class
nx::Class create M1

# Set a mixin
o mixins set M1

# Check mixins
o info mixins

# Clear mixins
o mixins set ""
```

### Setting Filters
```tcl
# Set a filter
o filters set f

# Check filters
o info filters

# Clear filters
o filters set ""
```

## Information Retrieval

### Method Information
```tcl
# List all methods
o info methods

# List methods with specific protection level
o info methods -callprotection protected
o info methods -callprotection private

# List object methods
o info object methods
```

### Variable Information
```tcl
# List all variables
o info variables

# List object variables
o info object variables

# List all slots (variables and properties)
o info slots
```

### General Information
```tcl
# List all available info submethods
o info
```

## Method and Property Management

### Deleting Methods, Properties, and Variables
```tcl
# Delete a method
o delete method foo

# Delete a property
o delete property p

# Delete a variable
o delete variable v1
```

## Advanced Features

### Requiring External Methods
```tcl
# Provide a method implementation
nsf::method::provide set {::nsf::method::alias set -frame object ::set}

# Require a method in an object
nx::Object create ::o {
    :require method set
}
```

## Behavior Without Plain-Object-Method

Without loading the `nx::plain-object-method` package, the following operations fail:
- `o public method foo {}`
- `o mixins set M1`
- `o filters set f`

After loading the package, these operations become available to plain objects. 