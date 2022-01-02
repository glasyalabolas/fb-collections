#include once "../inc/collections.bi"

/'
  A more advanced example of List usage: disposing callbacks.
  
  Note that this an advanced option for Lists that isn't implemented
  on other collections yet, and you won't normally need it (you can
  simply add the element to the collection by reference).
'/
type as Something ptr Something_ptr

type Something
  public:
    declare constructor()
    declare constructor( as integer )
    declare destructor()
    
    declare operator cast() as string
    
    as integer foo
end type

constructor Something() : end constructor

constructor Something( aFoo as integer )
  foo = aFoo
end constructor

destructor Something()
  ? "Something was destroyed."
end destructor

operator Something.cast() as string
  return( "Something.foo is: " & foo )
end operator

template( List, of( Something_ptr ) )

sub dispose( item as Something_ptr ptr )
  delete( *item )
end sub

/'
  Will need to add support for disposing callbacks for this particular
  use case, since elements within the list won't get destroyed properly.
'/
scope
  var _
    aList = List( of( Something_ptr ) )( @dispose ), _
    aSomething = new Something( 4 )
  
  aList.add( @aSomething )
  
  ? ( *aList.at( 0 ) )->foo
  
  '' Or alternatively:
  '' ? *( aList[ 0 ] ).foo
  '' ? **aList.at( 0 ).foo
end scope

? "Finished."

sleep()
