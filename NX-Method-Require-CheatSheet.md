# NSF/NX Method Require Cheatsheet

## Method Provision

```tcl
# Basic method provision
nsf::method::provide method_name {implementation}

# Alias to a Tcl command
nsf::method::provide append {::nsf::method::alias append -frame object ::append}

# Create a custom method
nsf::method::provide foo {::nsf::method::create foo {x y} {return x=$x,y=$y}}

# Provide a method using a mixin
nsf::method::provide x {::get_mixin ::MIX x} {
  ::nx::Class create ::MIX {:public method x {} {return x}}
}
```

## Method Requirement

```tcl
# Require a method in a class definition
nx::Class create C {
  :require method set
  :require method exists
}

# Require a method with different name than registered name
C require method tcl::set

# Require object methods
C require object method lappend

# Public vs. Protected methods
C require public method lappend
C require protected method lappend

# Require methods directly on objects
Object create o1
o1 require object method set
o1 require public object method lappend
o1 require protected object method lappend
```

## Method Properties

```tcl
# Check if a method is protected
::nsf::method::property C lappend call-protected
```

## Parent/Namespace Requirements

The NX framework creates parent namespaces automatically when needed:

```tcl
# Creating objects in nested namespaces
C create ::o::o        # Creates ::o namespace and ::o::o object
C create ::1::2::3::4  # Creates all parent namespaces and the object
```

## Method Redefinition Protection

```tcl
# Protected methods cannot be redefined as public
nx::Class public method __alloc arg {return 1}  # Will fail
```

## Method Scope Restrictions

```tcl
# Class-specific methods cannot be called on objects
::nsf::method::require object __alloc  # Will fail when called
``` 