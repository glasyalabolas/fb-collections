#include once "../inc/collections.bi"
#include once "../common/person.bi"

template( List, of( Person ) )

#include once "../common/person-predicates.bi"

/'
  Example usage of predicates to select elements from collections
'/
scope
  var aList = List( of( Person ) )
  
  with aList
    .add( new Person( "John", 34 ) )
    .add( new Person( "Mary", 27 ) )
    .add( new Person( "Jules", 24 ) )
  end with
  
  scope
    var selected = aList.selectAll( PersonsBelowAge( 28 ) )
    
    ? "Persons whose age is under 28 years: "
    
    for i as integer = 0 to selected->count - 1
      ? ( *selected )[ i ]
    next
  end scope
  
  ?
  ? "All people: "
  for i as integer = 0 to aList.count - 1
    ? aList[ i ]
  next
  
  ?
end scope

sleep()
