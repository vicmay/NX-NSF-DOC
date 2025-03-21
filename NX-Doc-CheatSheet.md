# NX Documentation System Cheatsheet

## Overview

The NX documentation system (`nx::doc`) provides tools for documenting NX-based Tcl code using comments. It supports parsing comments in various formats and extracting structured documentation.

## Basic Comment Formats

```tcl
# @tag content        # Standard tag format
#@tag content         # Also valid (no space after #)
### # # # @tag content # # # # # # #  # Comments with multiple # are also recognized
```

## Documentation Levels

The documentation system processes comments at different parsing levels:
- **Level 0**: Top-level comments (outside of any code block)
- **Level 1**: Init block comments (inside class/object definition blocks)
- **Level 2**: Method body and property implementation comments

## Main Tags

### Entity Tags

```tcl
# @class ::ClassName         # Document a class
# @object ::ObjectName       # Document an object
# @command ::CommandName     # Document a command
```

### Property Tags

```tcl
# @property propertyName     # Document a property
# @class-property propertyName  # Document a class property 
# @class-object-property propertyName  # Document a per-object property
```

### Method Tags

```tcl
# @method methodName         # Document a method
# @class-method methodName   # Document a per-class method
# @object-method methodName  # Document a per-object method
# @sub-method subMethodName  # Document a sub-method
```

### Parameter Tags

```tcl
# @parameter paramName Description text   # Document a method parameter
```

### Relationship Tags

```tcl
# @see EntityReference      # Reference another entity
# @author email@address.com  # Specify an author
```

### Special Property Tags

```tcl
# @deprecated               # Mark as deprecated
# @stashed                  # Mark as hidden from documentation
# @c-implemented            # Mark as implemented in C
# @syshook                  # Mark as a system hook
```

## Hierarchical Documentation

The documentation system supports hierarchical notation to document nested entities:

```tcl
# @class.property {::ClassName propertyName}   # Document a property of a class
# @class.method {::ClassName methodName}       # Document a method of a class
# @class.object.property {::ClassName objectName propertyName}  # Document a property of an object owned by a class
```

## In-situ Documentation (within code)

When documenting from within a class or object definition:

```tcl
Class create MyClass {
  # Class description here
  
  # @.property propertyName  # The dot prefix is relative to current context
  # Property description     # (equivalent to @class-property)
  :property propertyName
  
  # @.method methodName
  # Method description
  # @parameter param1 Parameter description
  :method methodName {param1} {
    # Method body documentation
    # @parameter param1 More specific parameter description
  }
}
```

## Documentation Block Structure

A valid documentation block follows this structure:
1. Must start with a tag line
2. Empty line
3. Description lines (optional)
4. Empty line (if there are parts to follow)
5. Part tags (like @parameter, @see, etc.)

Example:
```tcl
# @method myMethod
#
# This is the method description.
# It can span multiple lines.
#
# @parameter param1 Description of first parameter
# @parameter param2 Description of second parameter
# @see ::SomeOtherEntity
```

## Status Codes

The documentation parser can return various status codes:
- `COMPLETED`: Documentation successfully parsed
- `STYLEVIOLATION`: Documentation style issues
- `INVALIDTAG`: Invalid tag used
- `LEVELMISMATCH`: Parsing level mismatch

## Processing Documentation

The system processes documentation in several phases:
1. Scanning: Identify comment blocks in the code
2. Parsing: Parse the comment blocks into structured data
3. Processing: Process the documentation at each level

## Retrieving Documentation

Once processed, documentation can be accessed through the document entities:

```tcl
set entity [@class id ::ClassName]  # Get class documentation entity
$entity as_text                    # Get class description
$entity @author                    # Get author information
$entity @property                  # Get property documentation
``` 