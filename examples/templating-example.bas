#include once "../inc/collections.bi"

'' This is how you template them for basic data types
'' Templates a list of strings
template( List, of string )
'' Templates a dictionary that associates a string to a number
template( Dictionary, of integer, of string )

'' More advanced templating can be done also. This templates a dictionary that
'' associates lists of strings to a string.
template( Dictionary, of string, of List( of string ) )

sub show( l as List( of string ) ptr )
  if( l <> 0 ) then
    for i as integer = 0 to l->count - 1
      ? ( *l )[ i ]
    next
  else
    ? "Not found!"
  end if
end sub

dim as string items( ... ) = { _
  "Pears", "Apples", "Milk", "Meat", "Paul", "Jane" }

var d = Dictionary( of string, of List( of string ) )

d.add( "fruits", new List( of string )->add( items( 0 ) ).add( items( 1 ) ) )
d.add( "groceries", new List( of( string ) )->add( items( 2 ) ).add( items( 3 ) ) )
d.add( "people", new List( of string )->add( items( 4 ) ).add( items( 5 ) ) )

? "Fruits:"
show( d[ "fruits" ] )
?
? "Groceries:"
show( d[ "groceries" ] )
?
? "People:"
show( d[ "people" ] )
?
? "Whatever:"
show( d[ "whatever" ] )

sleep()
