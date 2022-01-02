#include once "../inc/collections.bi"
#include once "../common/person.bi"

/'
  Usage example for Arrays
'/
template( Array, of( Person ) )

/'
  Some example predicates and actions
'/
#include once "../common/person-predicates.bi"
#include once "../common/person-actions.bi"

sub showArray( anArray as Array( of( Person ) ) )
  for i as integer = 0 to anArray.count - 1
    ? anArray.at( i ), anArray[ i ]
  next
end sub

var anArray = Array( of( Person ) )()

with anArray
  .add( Person( "Paul", 37 ) )
  .add( Person( "Jenny", 12 ) )
  .add( Person( "Shaiel", 10 ) )
  .add( Person( "Brisa", 23 ) )
  .add( Person( "Mabel", 40 ) )
end with

var another = anArray.forEach( PersonsBelowAge( 13 ), SetAgeTo( 1 ) )

? "Showing elements: "

for index as integer = 0 to another.count - 1
  ? another.at( index )
next

?

for index as integer = 0 to anArray.count - 1
  ? anArray.at( index )
next

? "Clearing..."
anArray.clear()
? "Done."

? "Element count: "; anArray.count

for index as integer = 0 to anArray.count - 1
  ? anArray.at( index )
next

?
? "Showing result array: "
showArray( another )

sleep()
