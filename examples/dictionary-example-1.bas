#include once "../inc/collections.bi"
#include once "../common/person.bi"

'' Basic example of usage for Dictionaries
template( Dictionary, of integer, of Person )
template( List, of Person )

#include once "../common/person-predicates.bi"
#include once "../common/person-actions.bi"

sub show overload( d as Dictionary( of integer, of Person ) )
  d.forEach( ShowPerson() )
end sub

scope
  var _
    aDictionary = Dictionary( of integer, of Person )(), _
    aList = List( of Person )()
  
  for items as integer = 1 to 10
    var aPerson = new Person( "Person" & items, items )
    
    aList.add( aPerson )
    
    /'
      Note the syntax here. We pass the Person instance to the List as-is, but
      we pass the instance to the Dictionary dereferenced. This is because the
      default semantics for all collections is to *own* objects passed to them
      as pointers, and to *reference* objects passed to them byref.
      
      Hence, the list will take ownership of the instances and automatically
      destroy them if the list goes out of scope. 
    '/
    aDictionary.add( items, *aPerson )
  next
  
  aList.forEach( PersonsBelowAge( 5 ), ShowPerson() )
  ?
  
  /'
    The dictionary also contains the items, but only *references* to them. They
    will not get collected once the dictionary instance goes out of scope.
  '/
  aDictionary.forEach( PersonsBelowAge( 5 ), SetAgeTo( -8 ) )
  show( aDictionary )
end scope

sleep()
