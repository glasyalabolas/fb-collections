#include once "../inc/collections.bi"
#include once "../common/person.bi"

/'
  Another example for predicates, but using functions instead
  of classes.
'/
function personsBelowAge( aPerson as Person ptr, anAge as integer ) as boolean
  return( cbool( aPerson->age < anAge ) )
end function

template( List, of( Person ) )

function selectFrom( _
    aList as List( of( Person ) ), _
    aPredicate as function( as Person ptr, as integer ) as boolean, _
    anAge as integer ) _
  as auto_ptr( of( List( of( Person ) ) ) )
  
  var selected = new List( of( Person ) )
  
  for i as integer = 0 to aList.count - 1
    if( aPredicate( aList.at( i ), anAge ) ) then
      selected->add( *aList.at( i ) )
    end if
  next
  
  return( auto_ptr( of( List( of( Person ) ) ) )( selected ) )
end function

scope
  var aList = List( of( Person ) )
  
  with aList
    .add( new Person( "John", 34 ) )
    .add( new Person( "Mary", 27 ) )
    .add( new Person( "Jules", 24 ) )
  end with
  
  scope
    var selected = selectFrom( aList, @personsBelowAge, 28 )
    
    ? "Persons whose age is under 28 years: "
    
    for i as integer = 0 to selected->count - 1
      ? selected->at( i )->name & ", " & _
        selected->at( i )->age
    next
  end scope
  
  ?
  ? "All people: "
  for i as integer = 0 to aList.count - 1
    ? aList.at( i )->name & ", " & aList.at( i )->age
  next
  
  ?
end scope

sleep()
