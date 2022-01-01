/'
  Some actions to test
'/
type SetAgeTo extends Action( of( Person ) )
  public:
    declare constructor( as integer )
    declare destructor() override
    
    declare sub invoke( as Person ptr ) override
    
  private:
    declare constructor()
    
    as integer _age
end type

constructor SetAgeTo() : end constructor

constructor SetAgeTo( aValue as integer )
  _age = aValue
end constructor

destructor SetAgeTo() : end destructor

sub SetAgeTo.invoke( aPerson as Person ptr )
  aPerson->age = _age
end sub

type ShowPerson extends Action( of( Person ) )
  declare constructor()
  declare destructor() override
  
  declare sub invoke( as Person ptr ) override
end type

constructor ShowPerson() : end constructor

destructor ShowPerson() : end destructor

sub ShowPerson.invoke( aPerson as Person ptr )
  ? *aPerson
end sub
