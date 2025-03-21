# Hacking and Extending NX: A Comprehensive Guide

## Introduction

NX (Next Scripting Language) is built on top of NSF (Next Scripting Framework), making it highly extensible. This guide shows you how to hack, modify, and extend NX using NSF's meta-programming capabilities.

## 1. Core Extension Points

### Method System Extensions

#### Custom Method Types

Method types in NX/NSF define how methods are created and executed. Each method type has its own creation command and execution semantics. The method type system allows you to extend NX with new kinds of methods.

```tcl
# Create a new method type for async methods
::nsf::methodtype::create async {
    -createCmd {name argList body} {
        set wrapper [string map [list %body% $body %name% $name] {
            coroutine %name%_cor apply {{name body} {
                yield
                uplevel 1 $body
            }} %name% %body%
        }]
        return $wrapper
    }
}
```

How it works:
1. `::nsf::methodtype::create` registers a new method type with NSF
2. The `-createCmd` option specifies how methods of this type are created
3. The command receives:
   - `name`: The method name being created
   - `argList`: The argument list for the method
   - `body`: The method implementation
4. The command must return Tcl code that will be evaluated to create the method
5. In this example:
   - Creates a coroutine for each async method
   - Uses `yield` to make the method non-blocking
   - `uplevel 1` ensures proper variable scope

Usage example with explanation:
```tcl
nx::Class create AsyncService {
    # The -type async flag tells NX to use our custom method type
    :method -type async longOperation {} {
        after 1000
        return "Operation complete"
    }
}

# When called:
set service [AsyncService new]
$service longOperation ;# Returns immediately, runs in background
```

#### Method Property Extensions

Method properties allow you to attach metadata and behavior modifiers to methods. NSF provides a flexible system for defining and handling custom method properties.

```tcl
# Add custom method properties
::nsf::method::property Object myMethod cached 1
::nsf::method::property Object myMethod timeout 5000
```

How properties work:
1. Properties are key-value pairs attached to methods
2. They can be:
   - Metadata (like deprecation flags)
   - Behavior modifiers (like access control)
   - Runtime configuration (like timeouts)
3. Properties are inherited when methods are inherited
4. Properties can trigger behavior through property handlers

Property Handler Implementation:
```tcl
nx::Class create PropertyHandler {
    :property propertyName
    :property handler:object
    
    :public method handleProperty {obj method property value} {
        switch $property {
            "cached" {
                # Implement method result caching
                set original [$obj info method definition $method]
                $obj eval {
                    :public method $method args {
                        # Check cache first
                        if {[info exists :cache($method)]} {
                            return ${:cache($method)}
                        }
                        # Execute and cache
                        set result [uplevel 1 $original {*}$args]
                        set :cache($method) $result
                        return $result
                    }
                }
            }
            "timeout" {
                # Implement method timeout
                set original [$obj info method definition $method]
                $obj eval {
                    :public method $method args {
                        # Set up timeout
                        set done 0
                        set result ""
                        after $value [list set done 1]
                        
                        # Execute with timeout
                        if {[catch {
                            set result [uplevel 1 $original {*}$args]
                        } err]} {
                            if {$done} {
                                error "Method timeout after ${value}ms"
                            }
                            error $err
                        }
                        return $result
                    }
                }
            }
        }
    }
}
```

### Type System Extensions

The NX type system is extensible, allowing you to create custom types with validation and conversion logic. Types can be used for both method parameters and object properties.

#### Custom Type Checkers

Type checkers validate and potentially convert values at runtime. They're used in method parameters and object properties.

```tcl
# Create a complex number type
::nsf::type::create complex {
    # Validation logic
    -validate {value} {
        if {![regexp {^-?\d+(\.\d+)?[+-]\d+(\.\d+)?i$} $value]} {
            error "Invalid complex number format: $value"
        }
        return $value
    }
    
    # Optional conversion logic
    -convert {value} {
        # Convert from different formats
        switch -regexp $value {
            {^\[} { # Array format [list real imag]
                lassign $value real imag
                return "$real+${imag}i"
            }
            {^polar:} { # Polar format polar:r:theta
                lassign [split $value :] _ r theta
                set real [expr {$r * cos($theta)}]
                set imag [expr {$r * sin($theta)}]
                return "$real+${imag}i"
            }
            default {
                return $value
            }
        }
    }
}
```

How type checkers work:
1. `-validate` defines validation logic
   - Receives the value to validate
   - Must return validated value or throw error
2. `-convert` (optional) defines conversion logic
   - Allows accepting different input formats
   - Must return value in canonical format
3. Types can be combined with constraints
4. Types are used in method parameters and properties

Usage in different contexts:
```tcl
nx::Class create ComplexMath {
    # Property with complex type
    :property {z:complex "0+0i"}
    
    # Method parameter with complex type
    :public method add {a:complex b:complex} {
        # Parse complex numbers
        regexp {(.+)([+-].+)i} $a -> aReal aImag
        regexp {(.+)([+-].+)i} $b -> bReal bImag
        
        # Perform addition
        set realPart [expr {$aReal + $bReal}]
        set imagPart [expr {$aImag + $bImag}]
        
        return "$realPart$imagPart"
    }
    
    # Using conversion
    :public method fromPolar {r theta} {
        set :z [complex convert "polar:$r:$theta"]
    }
}
```

#### Parameter Constraints

Constraints add additional validation rules to types. They can be combined with types and with other constraints.

```tcl
# Create a range constraint
::nsf::type::create range {
    # Validate constraint arguments
    -validatearg {min max} {
        if {!([string is double -strict $min] && 
              [string is double -strict $max] &&
              $min < $max)} {
            error "Invalid range specification: $min..$max"
        }
    }
    
    # Validate values against constraint
    -validate {value min max} {
        if {$value < $min || $value > $max} {
            error "Value $value outside range $min..$max"
        }
        return $value
    }
}
```

How constraints work:
1. `-validatearg` validates constraint parameters
   - Called when constraint is used in type specification
   - Ensures constraint is properly configured
2. `-validate` checks values against constraint
   - Receives value and constraint parameters
   - Must return validated value or throw error
3. Constraints can be combined with types and other constraints
4. Constraints can be parameterized

Example of combined constraints:
```tcl
nx::Class create Temperature {
    # Combine type and constraint
    :property {celsius:double,range,-273.15..100}
    
    # Multiple constraints
    :property {pressure:double,range,0..1000,nonzero}
    
    # Custom error handling
    :public method setCelsius {temp:double,range,-273.15..100} {
        try {
            set :celsius $temp
        } trap {INVALID RANGE} {err} {
            error "Temperature $temp°C is physically impossible!"
        }
    }
}
```

## 2. Meta-Class Extensions

Meta-classes in NX control how classes are created and behave. They provide a powerful way to modify class behavior and implement design patterns at the class level.

### Custom Meta-Classes

Meta-classes allow you to:
1. Control class instantiation
2. Add class-level behavior
3. Implement design patterns
4. Modify class creation process

```tcl
# Create a singleton meta-class
nx::Class create SingletonClass -superclass nx::Class {
    :property instance:object,0..1
    
    # Override new to implement singleton pattern
    :public method new {args} {
        if {![info exists :instance]} {
            set :instance [next {*}$args]
        }
        return ${:instance}
    }
    
    # Add class-level functionality
    :public method reset {} {
        if {[info exists :instance]} {
            ${:instance} destroy
            unset :instance
        }
    }
}
```

How meta-classes work:
1. Meta-classes are classes that create classes
2. They inherit from `nx::Class`
3. Can override methods like `new` to control instantiation
4. Can add class-level properties and methods
5. Affect all classes created with this meta-class

Usage example with explanation:
```tcl
# Create a singleton class
nx::Class create Logger -metaclass SingletonClass {
    :property logFile
    :property {level "INFO"}
    
    :public method log {msg} {
        puts "[$level] $msg"
    }
}

# Usage demonstration
set logger1 [Logger new]  ;# Creates first instance
set logger2 [Logger new]  ;# Returns same instance
expr {$logger1 eq $logger2}  ;# Returns 1 (true)

# Reset singleton state
Logger reset  ;# Destroys instance
set logger3 [Logger new]  ;# Creates new instance
```

### Aspect-Oriented Extensions

Aspect-Oriented Programming (AOP) in NX allows you to add behavior that cuts across multiple classes without modifying their code directly.

```tcl
# Create an aspect system
nx::Class create Aspect {
    :property target:object
    :property pointcut:method
    :property advice:object
    
    # Different types of advice
    :public method beforeAdvice {body} {
        set original [${:target} info method definition ${:pointcut}]
        ${:target} eval {
            :public method ${:pointcut} args {
                # Execute advice
                uplevel 1 $body
                
                # Execute original method
                uplevel 1 $original {*}$args
            }
        }
    }
    
    :public method afterAdvice {body} {
        set original [${:target} info method definition ${:pointcut}]
        ${:target} eval {
            :public method ${:pointcut} args {
                # Execute original method
                set result [uplevel 1 $original {*}$args]
                
                # Execute advice
                uplevel 1 $body
                
                return $result
            }
        }
    }
    
    :public method aroundAdvice {body} {
        set original [${:target} info method definition ${:pointcut}]
        ${:target} eval {
            :public method ${:pointcut} args {
                # Make original method available to advice
                set proceed [list uplevel 1 $original {*}$args]
                
                # Execute advice with access to proceed
                uplevel 1 [list apply {{proceed body} {
                    uplevel 1 $body
                }} $proceed $body]
            }
        }
    }
}
```

How aspects work:
1. Aspects intercept method calls
2. Types of advice:
   - Before: Runs before method
   - After: Runs after method
   - Around: Wraps method execution
3. Pointcuts define where advice applies
4. Advice defines what happens at pointcut

Example usage:
```tcl
# Create a logging aspect
nx::Class create LoggingAspect -superclass Aspect {
    :property {logLevel "INFO"}
    
    :public method applyLogging {} {
        :beforeAdvice {
            puts "\[$logLevel\] Entering [${:target}] ${:pointcut}"
        }
        :afterAdvice {
            puts "\[$logLevel\] Exiting [${:target}] ${:pointcut}"
        }
    }
}

# Apply aspect to a class
nx::Class create MyService {
    :public method processData {data} {
        # Process data
        return [string toupper $data]
    }
}

LoggingAspect create logger {
    :property target [MyService info instances]
    :property pointcut "processData"
    :applyLogging
}
```

## 3. Object System Extensions

The NX object system can be extended to customize object creation, lifecycle management, and behavior.

### Custom Object Creation

Object creation can be customized to add initialization logic, validation, and setup code.

```tcl
# Extend object creation process
nx::Class create CustomClass -superclass nx::Class {
    :property {initHooks:list {}}
    
    :public method create {name args} {
        # Pre-creation hooks
        :preCreate $name
        
        # Create instance with custom initialization
        set obj [next $name {*}$args]
        
        # Run initialization hooks
        foreach hook ${:initHooks} {
            $obj eval $hook
        }
        
        # Post-creation customization
        :postCreate $obj
        
        return $obj
    }
    
    :protected method preCreate {name} {
        # Validate class name
        if {![regexp {^[a-zA-Z][a-zA-Z0-9_]*$} $name]} {
            error "Invalid class name: $name"
        }
        
        # Setup environment
        :setupEnvironment $name
    }
    
    :protected method postCreate {obj} {
        # Initialize object state
        $obj eval {
            :initializeState
        }
        
        # Register object
        :registerObject $obj
    }
    
    :protected method setupEnvironment {name} {
        # Create necessary directories/files
        file mkdir "objects/$name"
    }
    
    :protected method registerObject {obj} {
        # Add to registry
        dict set :objectRegistry [$obj name] $obj
    }
    
    :public method addInitHook {hook} {
        lappend :initHooks $hook
    }
}
```

How custom creation works:
1. Override `create` method to customize creation
2. Add pre-creation validation and setup
3. Support initialization hooks
4. Perform post-creation tasks
5. Maintain object registry

Example usage:
```tcl
# Create a class with custom creation
nx::Class create Component -metaclass CustomClass {
    :property name
    :property state
    
    :public method initializeState {} {
        set :state "initialized"
    }
}

# Add initialization hook
Component addInitHook {
    :public method start {} {
        set :state "running"
    }
}

# Create instance
set comp [Component new -name "MyComponent"]
```

### Object Lifecycle Management

Lifecycle management allows you to control object state transitions and cleanup.

```tcl
# Add lifecycle management
nx::Class create ManagedObject {
    :property {state "new"}
    :property {stateHandlers:dict {}}
    :property {transitions:dict {
        new {initialized}
        initialized {active suspended}
        active {suspended}
        suspended {active terminated}
        terminated {}
    }}
    
    :public method init {} {
        next
        :changeState "initialized"
    }
    
    :public method activate {} {
        :changeState "active"
    }
    
    :public method suspend {} {
        :changeState "suspended"
    }
    
    :public method terminate {} {
        :changeState "terminated"
    }
    
    :protected method changeState {newState} {
        # Validate transition
        if {![:isValidTransition $newState]} {
            error "Invalid transition from ${:state} to $newState"
        }
        
        # Execute exit handler
        if {[dict exists ${:stateHandlers} ${:state} exit]} {
            uplevel 1 [dict get ${:stateHandlers} ${:state} exit]
        }
        
        set oldState ${:state}
        set :state $newState
        
        # Execute entry handler
        if {[dict exists ${:stateHandlers} $newState entry]} {
            uplevel 1 [dict get ${:stateHandlers} $newState entry]
        }
        
        :notifyStateChange $oldState $newState
    }
    
    :protected method isValidTransition {newState} {
        expr {[lsearch [dict get ${:transitions} ${:state}] $newState] >= 0}
    }
    
    :public method addStateHandler {state type script} {
        dict set :stateHandlers $state $type $script
    }
    
    :protected method notifyStateChange {old new} {
        :notifyObservers stateChanged [list old $old new $new]
    }
}
```

How lifecycle management works:
1. Define possible states and transitions
2. Add state entry/exit handlers
3. Validate state transitions
4. Notify observers of changes
5. Support cleanup and termination

Example usage:
```tcl
# Create managed service
nx::Class create Service -superclass ManagedObject {
    :property name
    :property resources:list
    
    :public method init {} {
        next
        
        # Add state handlers
        :addStateHandler active entry {
            puts "Starting service ${:name}"
            :allocateResources
        }
        
        :addStateHandler active exit {
            puts "Stopping service ${:name}"
            :releaseResources
        }
    }
    
    :protected method allocateResources {} {
        lappend :resources "database_connection"
        lappend :resources "cache_client"
    }
    
    :protected method releaseResources {} {
        foreach resource ${:resources} {
            puts "Releasing $resource"
        }
        set :resources {}
    }
}

# Usage
set svc [Service new -name "MyService"]
$svc activate   ;# Allocates resources
$svc suspend    ;# Releases resources
$svc activate   ;# Reallocates resources
$svc terminate  ;# Final cleanup
```

## 4. Advanced Extensions

### Custom Method Resolution

Method resolution in NX can be customized to implement features like method fuzzy matching, delegation, and dynamic dispatch.

```tcl
# Create a method resolution system
nx::Class create MethodResolver {
    :property class:object
    :property {cache:dict {}}
    :property {resolverRules:list {}}
    
    :public method resolveMethod {name} {
        # Check cache first
        if {[dict exists ${:cache} $name]} {
            return [dict get ${:cache} $name]
        }
        
        # Apply resolution rules
        foreach rule ${:resolverRules} {
            if {[set method [:applyRule $rule $name]] ne ""} {
                dict set :cache $name $method
                return $method
            }
        }
        
        return ""
    }
    
    :public method addRule {rule} {
        lappend :resolverRules $rule
    }
    
    :protected method applyRule {rule name} {
        switch [dict get $rule type] {
            "fuzzy" {
                # Fuzzy match against method names
                set methods [${:class} info methods]
                set matches [lsort -command [list :fuzzyCompare $name] $methods]
                return [lindex $matches 0]
            }
            "prefix" {
                # Match methods with prefix
                set prefix [dict get $rule prefix]
                set methods [${:class} info methods "${prefix}*"]
                return [lindex $methods 0]
            }
            "delegate" {
                # Delegate to another object
                set target [dict get $rule target]
                if {[$target info methods -callprotection public $name] ne ""} {
                    return [list delegate $target $name]
                }
            }
        }
        return ""
    }
    
    :protected method fuzzyCompare {target str1 str2} {
        # Simple Levenshtein distance comparison
        set dist1 [:levenshteinDistance $target $str1]
        set dist2 [:levenshteinDistance $target $str2]
        return [expr {$dist1 - $dist2}]
    }
    
    :protected method levenshteinDistance {str1 str2} {
        # Compute edit distance between strings
        # Implementation omitted for brevity
        return 0
    }
}
```

How custom method resolution works:
1. Resolution rules define how to find methods
2. Rules can include:
   - Fuzzy matching
   - Prefix matching
   - Delegation
3. Results are cached for performance
4. Can be extended with new rule types

Example usage:
```tcl
# Create a class with custom method resolution
nx::Class create FuzzyClass {
    :property resolver:object [MethodResolver new -class [self]]
    
    :public method init {} {
        next
        
        # Add resolution rules
        ${:resolver} addRule [dict create \
            type fuzzy \
            threshold 0.8
        ]
        ${:resolver} addRule [dict create \
            type prefix \
            prefix "handle"
        ]
        ${:resolver} addRule [dict create \
            type delegate \
            target [DelegateTarget new]
        ]
    }
    
    :public method unknown {name args} {
        if {[set method [${:resolver} resolveMethod $name]] ne ""} {
            if {[lindex $method 0] eq "delegate"} {
                lassign $method _ target methodName
                return [$target $methodName {*}$args]
            }
            return [:$method {*}$args]
        }
        next $name {*}$args
    }
    
    :public method handleData {data} {
        return "Handling $data"
    }
    
    :public method processRequest {req} {
        return "Processing $req"
    }
}
```

### Dynamic Feature Injection

Feature injection allows you to dynamically add functionality to objects and classes at runtime.

```tcl
# Create a feature injection system
nx::Class create FeatureInjector {
    :property {features:dict {}}
    
    :public method injectMethod {target name body {protection public}} {
        # Create method definition
        set methodDef [list :$protection method $name {} $body]
        
        # Store feature for potential removal
        dict set :features $target methods $name $methodDef
        
        # Inject method
        $target eval $methodDef
    }
    
    :public method injectProperty {target name {value ""} {spec ""}} {
        # Create property definition
        set propDef [list :property]
        if {$spec ne ""} {
            lappend propDef [list $name:$spec $value]
        } else {
            lappend propDef [list $name $value]
        }
        
        # Store feature
        dict set :features $target properties $name $propDef
        
        # Inject property
        $target eval $propDef
    }
    
    :public method injectMixin {target mixin} {
        # Add mixin
        $target mixin add $mixin
        
        # Store feature
        dict set :features $target mixins $mixin 1
    }
    
    :public method removeFeature {target type name} {
        switch $type {
            "method" {
                $target eval [list :public method $name]
                dict unset :features $target methods $name
            }
            "property" {
                $target eval [list :property -delete $name]
                dict unset :features $target properties $name
            }
            "mixin" {
                $target mixin delete $name
                dict unset :features $target mixins $name
            }
        }
    }
    
    :public method listInjectedFeatures {target} {
        if {[dict exists ${:features} $target]} {
            return [dict get ${:features} $target]
        }
        return {}
    }
}
```

How feature injection works:
1. Features can be:
   - Methods
   - Properties
   - Mixins
2. Features are tracked for removal
3. Injection is reversible
4. Supports different protection levels
5. Maintains feature registry

Example usage:
```tcl
# Create injector and target
set injector [FeatureInjector new]
nx::Class create Target {
    :property name
}

# Inject features
$injector injectMethod Target "greet" {
    return "Hello, ${:name}!"
}

$injector injectProperty Target "timestamp" \
    [clock seconds] "integer"

$injector injectMixin Target Loggable

# Use injected features
set obj [Target new -name "World"]
puts [$obj greet]  ;# Outputs: Hello, World!

# Remove features
$injector removeFeature Target method "greet"
$injector removeFeature Target property "timestamp"
```

### Custom Serialization

Serialization allows objects to be converted to and from string representations for storage or transmission.

```tcl
# Create a serialization system
nx::Class create Serializable {
    :property {serializableVars:list {}}
    :property {serializers:dict {}}
    
    :public method init {} {
        next
        
        # Register basic serializers
        :registerSerializer string {:toString :fromString}
        :registerSerializer list {:toList :fromList}
        :registerSerializer dict {:toDict :fromDict}
    }
    
    :public method registerSerializer {type methods} {
        dict set :serializers $type $methods
    }
    
    :public method addSerializableVar {name {type string}} {
        if {![dict exists ${:serializers} $type]} {
            error "Unknown serializer type: $type"
        }
        lappend :serializableVars [list $name $type]
    }
    
    :public method serialize {} {
        set data [dict create]
        
        foreach var ${:serializableVars} {
            lassign $var name type
            if {[info exists :$name]} {
                set value [set :$name]
                set toMethod [lindex [dict get ${:serializers} $type] 0]
                dict set data $name [list $type [:$toMethod $value]]
            }
        }
        
        return $data
    }
    
    :public method deserialize {data} {
        dict for {name entry} $data {
            lassign $entry type value
            if {[dict exists ${:serializers} $type]} {
                set fromMethod [lindex [dict get ${:serializers} $type] 1]
                set :$name [:$fromMethod $value]
            }
        }
    }
    
    # Basic serializers
    :protected method toString {value} {
        return $value
    }
    
    :protected method fromString {value} {
        return $value
    }
    
    :protected method toList {value} {
        return $value
    }
    
    :protected method fromList {value} {
        return $value
    }
    
    :protected method toDict {value} {
        return $value
    }
    
    :protected method fromDict {value} {
        return $value
    }
}
```

How custom serialization works:
1. Objects define serializable variables
2. Each variable has a type
3. Types have serializers
4. Serialization is extensible
5. Supports custom formats

Example usage:
```tcl
# Create a serializable class
nx::Class create Person -mixin Serializable {
    :property name:string
    :property age:integer
    :property address:dict
    :property tags:list
    
    :public method init {} {
        next
        
        # Register serializable vars
        :addSerializableVar name string
        :addSerializableVar age string
        :addSerializableVar address dict
        :addSerializableVar tags list
    }
}

# Create and serialize object
set person [Person new]
set :name "John Doe"
set :age 30
set :address [dict create street "123 Main St" city "Anytown"]
set :tags [list "employee" "manager"]

# Serialize
set data [$person serialize]

# Create new object and deserialize
set person2 [Person new]
$person2 deserialize $data

# Verify
puts [$person2 cget -name]  ;# Outputs: John Doe
```

## 5. Best Practices for NX Extensions

### Method Extensions Best Practices

1. Protection Levels
   - Use appropriate protection levels for methods
   - Make internal methods protected
   - Only expose necessary public interface
   - Consider using private for implementation details

```tcl
nx::Class create BestPracticeExample {
    # Public API methods
    :public method doSomething {arg} {
        # Validate input
        :validateInput $arg
        
        # Perform operation
        set result [:processData $arg]
        
        # Post-process
        return [:formatResult $result]
    }
    
    # Protected internal methods
    :protected method validateInput {arg} {
        if {![string is double -strict $arg]} {
            error "Invalid input: must be number"
        }
    }
    
    :protected method processData {arg} {
        # Internal processing
        return [expr {$arg * 2}]
    }
    
    # Private implementation details
    :private method formatResult {result} {
        format "%.2f" $result
    }
}
```

2. Method Documentation
   - Document method contracts clearly
   - Specify parameter types and constraints
   - Document exceptions that may be thrown
   - Include usage examples

```tcl
nx::Class create DocumentedClass {
    # Method documentation
    :public method processTransaction {
        amount:double
        -account:string
        -type:string
    } {
        # Amount: Transaction amount (positive for credit, negative for debit)
        # -account: Account identifier
        # -type: Transaction type (deposit|withdrawal|transfer)
        # Returns: Transaction ID
        # Throws: INVALID_AMOUNT, ACCOUNT_NOT_FOUND, INSUFFICIENT_FUNDS
        
        # Implementation...
    }
}
```

3. Error Handling
   - Use structured error handling
   - Create custom error types
   - Provide detailed error messages
   - Clean up resources in error cases

```tcl
nx::Class create ErrorHandling {
    :public method safeOperation {} {
        # Setup
        :acquireResources
        
        try {
            # Perform operation
            :doOperation
        } trap {OPERATION FAILED} {err} {
            # Handle specific error
            :logError $err
            :notifyAdmin $err
            error "Operation failed: $err"
        } finally {
            # Always clean up
            :releaseResources
        }
    }
}
```

### Type System Extensions Best Practices

1. Type Validation
   - Validate input thoroughly
   - Handle edge cases
   - Convert types safely
   - Maintain type consistency

```tcl
# Create a robust type
::nsf::type::create email {
    -validate {value} {
        # Thorough validation
        if {![regexp {^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$} $value]} {
            error "Invalid email format"
        }
        
        # Additional checks
        if {[string length $value] > 254} {
            error "Email too long"
        }
        
        # Normalize
        return [string tolower $value]
    }
}
```

2. Performance Considerations
   - Cache validation results
   - Optimize frequent operations
   - Use efficient data structures
   - Profile type checkers

```tcl
nx::Class create CachedTypeChecker {
    :property {cache:dict {}}
    :property {cacheSize 1000}
    
    :public method validateType {value type} {
        # Check cache
        set key "$value,$type"
        if {[dict exists ${:cache} $key]} {
            return [dict get ${:cache} $key]
        }
        
        # Perform validation
        set result [:performValidation $value $type]
        
        # Update cache
        :updateCache $key $result
        
        return $result
    }
    
    :protected method updateCache {key value} {
        # Maintain cache size
        if {[dict size ${:cache}] >= ${:cacheSize}} {
            set oldest [lindex [dict keys ${:cache}] 0]
            dict unset :cache $oldest
        }
        
        dict set :cache $key $value
    }
}
```

### Meta-Programming Best Practices

1. Code Generation
   - Generate clean, readable code
   - Include comments in generated code
   - Handle namespaces properly
   - Validate generated code

```tcl
nx::Class create CodeGenerator {
    :public method generateAccessors {class properties} {
        set code ""
        
        foreach prop $properties {
            append code "    # Accessor for $prop\n"
            append code "    :public method get[string totitle $prop] {} {\n"
            append code "        return \${:$prop}\n"
            append code "    }\n\n"
            
            append code "    # Mutator for $prop\n"
            append code "    :public method set[string totitle $prop] {value} {\n"
            append code "        set :$prop \$value\n"
            append code "    }\n\n"
        }
        
        return $code
    }
}
```

2. Resource Management
   - Clean up generated resources
   - Handle circular references
   - Manage memory efficiently
   - Use weak references when appropriate

```tcl
nx::Class create ResourceManager {
    :property {resources:dict {}}
    :property {weakRefs:dict {}}
    
    :public method trackResource {resource} {
        # Store strong reference
        dict set :resources [$resource name] $resource
        
        # Setup cleanup
        $resource public method destroy {} {
            next
            :cleanupResource [self]
        }
    }
    
    :public method weakRef {resource} {
        # Store weak reference
        dict set :weakRefs [$resource name] $resource
        trace add variable :weakRefs write [:cleanupWeakRef $resource]
    }
}
```

### Testing Extensions Best Practices

1. Test Coverage
   - Test normal cases
   - Test edge cases
   - Test error conditions
   - Test performance

```tcl
nx::Class create TestCase {
    :public method assert {condition {message ""}} {
        if {![uplevel 1 [list expr $condition]]} {
            error "Assertion failed: $message"
        }
    }
    
    :public method assertThrows {script errorCode} {
        if {[catch {uplevel 1 $script} result opts]} {
            set actualError [dict get $opts -errorcode]
            if {$actualError ne $errorCode} {
                error "Expected error $errorCode but got $actualError"
            }
        } else {
            error "Expected error $errorCode but no error occurred"
        }
    }
    
    :public method benchmark {script {iterations 1000}} {
        set start [clock microseconds]
        for {set i 0} {$i < $iterations} {incr i} {
            uplevel 1 $script
        }
        set end [clock microseconds]
        
        return [expr {($end - $start) / $iterations.0}]
    }
}

# Usage
nx::Class create MyExtensionTest -superclass TestCase {
    :public method testFeature {} {
        # Test normal case
        :assert {[MyClass new] ne ""} "Object creation"
        
        # Test edge case
        :assert {[MyClass new -value ""] ne ""} "Empty value"
        
        # Test error
        :assertThrows {
            MyClass new -invalid value
        } {INVALID PARAMETER}
        
        # Test performance
        set time [:benchmark {MyClass new}]
        :assert {$time < 1000} "Performance check"
    }
}
```

2. Test Organization
   - Group related tests
   - Use descriptive test names
   - Setup and teardown properly
   - Isolate test cases

```tcl
nx::Class create TestSuite {
    :property {tests:dict {}}
    :property {results:dict {}}
    
    :public method addTest {name script} {
        dict set :tests $name $script
    }
    
    :public method setup {} {
        # Setup test environment
    }
    
    :public method teardown {} {
        # Clean up test environment
    }
    
    :public method runTests {} {
        :setup
        
        dict for {name script} ${:tests} {
            try {
                uplevel 1 $script
                dict set :results $name "PASS"
            } trap {ASSERT FAILED} {err} {
                dict set :results $name "FAIL: $err"
            } finally {
                :teardown
            }
        }
        
        :reportResults
    }
}
```

These best practices help ensure that your NX extensions are:
- Reliable and maintainable
- Performant and efficient
- Well-tested and documented
- Easy to use and understand
- Follow consistent patterns

## 6. Slot-Based Programming

Slots are a fundamental concept in NX that provide a powerful way to define and manage object attributes and behavior. They offer more flexibility and control than traditional properties.

### Slot Basics

Slots in NX are containers for values with associated metadata and behavior. They can:
1. Hold values of any type
2. Have custom access methods
3. Trigger behavior on access/modification
4. Support validation and type checking
5. Maintain per-instance metadata

```tcl
# Create a class with slots
nx::Class create SlotExample {
    # Define a basic slot
    :slot x {
        :type integer
        :default 0
    }
    
    # Define a slot with custom accessors
    :slot y {
        :accessor public
        :writer private
        :type double
        :default 0.0
        
        # Custom getter
        :getter {
            expr {${:y} * 2}  ;# Always return double the stored value
        }
        
        # Custom setter with validation
        :setter {value} {
            if {$value < 0} {
                error "Y cannot be negative"
            }
            set :y $value
        }
    }
    
    # Slot with notifications
    :slot status {
        :type string
        :default "inactive"
        
        # Notify on changes
        :notifier {old new} {
            puts "Status changed from $old to $new"
        }
    }
}
```

How slots work:
1. Slots are defined at class creation
2. Each slot can have:
   - Type constraints
   - Default values
   - Custom accessors
   - Validation logic
   - Change notifications
3. Slots are inherited by subclasses
4. Slots can be modified at runtime

### Advanced Slot Features

#### Computed Slots

Computed slots derive their values from other slots or computations:

```tcl
nx::Class create Point {
    :slot x:double
    :slot y:double
    
    # Computed slot for radius (read-only)
    :slot radius {
        :computed
        :getter {
            expr {sqrt(${:x}*${:x} + ${:y}*${:y})}
        }
    }
    
    # Computed slot with custom setter
    :slot angle {
        :computed
        :getter {
            expr {atan2(${:y}, ${:x})}
        }
        :setter {value} {
            set r ${:radius}
            set :x [expr {$r * cos($value)}]
            set :y [expr {$r * sin($value)}]
        }
    }
}
```

#### Slot Introspection

Slots support rich introspection capabilities:

```tcl
nx::Class create IntrospectableClass {
    :slot config {
        :type dict
        :default {}
        :trace {
            :read {
                puts "Reading config"
            }
            :write {old new} {
                puts "Config changed from $old to $new"
            }
        }
    }
    
    :public method inspectSlots {} {
        # Get all slots
        set slots [list]
        foreach slot [:info slots] {
            lappend slots [list \
                $slot \
                [:info slot type $slot] \
                [:info slot default $slot] \
                [:info slot options $slot]
            ]
        }
        return $slots
    }
}
```

### Slot-Based Design Patterns

#### Observable Properties

Use slots to implement the observer pattern:

```tcl
nx::Class create Observable {
    :slot observers:list
    
    :public method addObserver {observer} {
        lappend :observers $observer
    }
    
    :public method removeObserver {observer} {
        set idx [lsearch ${:observers} $observer]
        if {$idx >= 0} {
            set :observers [lreplace ${:observers} $idx $idx]
        }
    }
    
    :protected method notifyObservers {event args} {
        foreach observer ${:observers} {
            if {[$observer info methods $event] ne ""} {
                $observer $event {*}$args
            }
        }
    }
}

nx::Class create Temperature -superclass Observable {
    :slot celsius {
        :type double
        :default 20.0
        :notifier {old new} {
            :notifyObservers temperatureChanged $old $new
        }
    }
    
    :slot fahrenheit {
        :computed
        :getter {
            expr {${:celsius} * 1.8 + 32}
        }
        :setter {value} {
            set :celsius [expr {($value - 32) / 1.8}]
        }
    }
}
```

#### Validation and Constraints

Use slots to implement complex validation:

```tcl
nx::Class create ValidatedRecord {
    # Slot with multiple constraints
    :slot age {
        :type integer
        :default 0
        :constraint {
            {value} {
                expr {$value >= 0}
            } "Age must be non-negative"
            
            {value} {
                expr {$value <= 150}
            } "Age must be reasonable"
        }
    }
    
    # Slot with dependent validation
    :slot dateRange {
        :type dict
        :default {start "" end ""}
        :constraint {
            {value} {
                set start [dict get $value start]
                set end [dict get $value end]
                if {$start eq "" || $end eq ""} {
                    return 1
                }
                clock scan $start
                clock scan $end
                expr {[clock scan $start] <= [clock scan $end]}
            } "End date must be after start date"
        }
    }
}
```

### Best Practices for Slots

1. Use Slots for Complex Properties
   - When you need validation
   - When you need computed values
   - When you need change notification
   - When you need custom access control

2. Slot Design Guidelines
   - Keep slot definitions clear and focused
   - Use appropriate types and constraints
   - Document slot behavior and requirements
   - Consider inheritance implications

3. Performance Considerations
   - Use computed slots judiciously
   - Cache complex computations
   - Minimize notification overhead
   - Profile slot access patterns

Example of well-designed slots:

```tcl
nx::Class create Account {
    # Simple value slot
    :slot id:string
    
    # Validated slot with constraints
    :slot balance {
        :type double
        :default 0.0
        :constraint {
            {value} {
                expr {$value >= 0}
            } "Balance cannot be negative"
        }
    }
    
    # Computed slot with caching
    :slot interestRate {
        :computed
        :cache 1
        :getter {
            # Complex computation that gets cached
            :computeInterestRate ${:balance}
        }
    }
    
    # Slot with custom access control
    :slot transactions {
        :type list
        :default {}
        :accessor public
        :writer private
        
        # Maintain transaction history
        :setter {value} {
            set :transactions [lrange $value end-99 end]
        }
    }
    
    # Slot with notifications
    :slot status {
        :type string
        :default "active"
        :notifier {old new} {
            :logStatusChange $old $new
            :notifyStatusObservers $old $new
        }
    }
}
```

This demonstrates how slots provide a powerful mechanism for:
- Value management
- Computed properties
- Validation
- Change notification
- Access control
- Introspection 