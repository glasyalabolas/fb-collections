/'
  Some predicates to test
'/
type PersonsBelowAge extends Predicate( of( Person ) )
  public:
    declare constructor( as integer )
    declare destructor() override
    
    declare function eval( as Person ptr ) as boolean override
    
  private:
    declare constructor()
    
    as integer _age
end type

constructor PersonsBelowAge() : end constructor

constructor PersonsBelowAge( anAge as integer )
  _age = iif( anAge < 1, 1, anAge )
end constructor

destructor PersonsBelowAge() : end destructor

function PersonsBelowAge.eval( aPerson as Person ptr ) as boolean
  return( aPerson->age < _age )
end function
