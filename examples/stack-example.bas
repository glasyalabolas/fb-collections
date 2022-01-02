#include once "../inc/collections.bi"
#include once "../common/person.bi"

template( Stack, of( Person ) )

#include once "../common/person-predicates.bi"
#include once "../common/person-actions.bi"

sub dump( s as Stack( of( Person ) ) )
  s.forEach( ShowPerson() )
end sub

'' Simple stack example
scope
  dim as Person persons( ... ) = { _
    Person( "Paul", 1 ), Person( "Mary", 2 ), Person( "Jane", 3 ) }
  
  var st = Stack( of( Person ) )
  
  with st
    .push( persons( 0 ) )
    .push( persons( 1 ) )
    .push( persons( 2 ) )
  end with
  
  st.forEach( ShowPerson() )
end scope

sleep()
