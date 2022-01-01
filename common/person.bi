/'
  A simple type for unit testing
'/
type Person
  public:
    declare constructor()
    declare constructor( as const string, as integer )
    declare constructor( as Person )
    declare operator let( as Person )
    declare destructor()
    
    declare operator cast() as string
    
    as string name
    as integer age
end type

constructor Person()
  name = "<unknown>"
  age = 0
end constructor

constructor Person( aName as const string, anAge as integer )
  name = aName
  age = anAge
end constructor

constructor Person( rhs as Person )
  name = rhs.name
  age = rhs.age
end constructor

destructor Person()
  ? "R.I.P. (" & name & ", " & age & ")"
end destructor

operator Person.let( rhs as Person )
  name = rhs.name
  age = rhs.age
end operator

operator Person.cast() as string
  return( name & ", " & age )
end operator

operator =( lhs as Person, rhs as Person ) as integer
  return( lhs.name = rhs.name andAlso lhs.age = rhs.age )
end operator

operator <>( lhs as Person, rhs as Person ) as integer
  return( lhs.name <> rhs.name orElse lhs.age <> rhs.age )
end operator

operator <( lhs as Person, rhs as Person ) as integer
  return( lhs.age < rhs.age )
end operator

operator <=( lhs as Person, rhs as Person ) as integer
  return( lhs.age <= rhs.age )
end operator

operator >( lhs as Person, rhs as Person ) as integer
  return( lhs.age > rhs.age )
end operator

operator >=( lhs as Person, rhs as Person ) as integer
  return( lhs.age >= rhs.age )
end operator
