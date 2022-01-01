#include once "../inc/collections.bi"
#include once "../common/person.bi"

/'
  Slightly more complex example showing how you can compose each collection
  with others to create complex data structures. In this case, a dictionary
  of linked lists of Person types is created, and the dictionary itself is
  keyed by a two dimensional point.
'/

/'
  A simple type to use as key on the dictionary. This one
  represents a point in 2-space.
'/
type Point2
  public:
    declare constructor()
    declare constructor( as integer, as integer )
    declare constructor( as Point2 )
    declare destructor()
    
    declare operator let( as Point2 )
    
    as integer X, Y
end type

constructor Point2() : end constructor

constructor Point2( aX as integer, aY as integer )
  X = aX
  Y = aY
end constructor

constructor Point2( rhs as Point2 )
  X = rhs.X
  Y = rhs.Y
end constructor

destructor Point2() : end destructor

operator Point2.let( rhs as Point2 )
  X = rhs.X
  Y = rhs.Y
end operator

/'
  Types and classes that are to be used as keys MUST implement the
  equality operator.
'/
operator =( lhs as Point2, rhs as Point2 ) as integer
  return( lhs.X = rhs.X andAlso lhs.Y = rhs.Y )
end operator

/'
  We can now define the key for Point2
'/
type Key( of( Point2 ) )
  public:
    declare constructor()
    declare constructor( as const Point2 )
    declare constructor( as Key( of( Point2 ) ) )
    declare destructor()
    
    declare operator let( as Point2 )
    declare operator let( as Key( of( Point2 ) ) )
    
    declare function getHashCode() as ulong
    
    as Point2 value
end type

constructor Key( of( Point2 ) )() : end constructor

constructor Key( of( Point2 ) )( aPoint2 as const Point2 )
  value = aPoint2
end constructor

constructor Key( of( Point2 ) )( rhs as Key( of( Point2 ) ) )
  value = rhs.value
end constructor

destructor Key( of( Point2 ) )() : end destructor

operator Key( of( Point2 ) ).let( rhs as Point2 )
  value = rhs
end operator

operator Key( of( Point2 ) ).let( rhs as Key( of( Point2 ) ) )
  value = rhs.value
end operator

/'
  Note that keys MUST implement BOTH the getHashCode() function AND the
  equality operator to work as such.
'/
function Key( of( Point2 ) ).getHashCode() as ulong
  return( culng( ( ( value.X * &hbf58476d1ce4e5b9ull + value.Y ) * &h94d049bb133111ebull ) ) )
end function

operator =( lhs as Key( of( Point2 ) ), rhs as Key( of( Point2 ) ) ) as integer
  return( lhs.value = rhs.value )
end operator

'' Now we can template the custom collection
template( LinkedList, of( Person ) )
template( Dictionary, of( Point2 ), of( LinkedList( of( Person ) ) ) )

/'
  Little helper function to add a key to the dictionary
'/
sub addTo( _
  aDictionary as Dictionary( of( Point2 ), of( LinkedList( of( Person ) ) ) ), _
  aKey as Point2, aPerson as Person ptr )
  
  var aList = aDictionary.find( aKey )
  
  if( aList = 0 ) then
    aList = new LinkedList( of( Person ) )
    
    aDictionary.add( aKey, aList )
  end if
  
  aList->addLast( aPerson )
end sub

/'
  And this other helper shows all the elements contained in the list
  at the specified key.
'/
sub showAt( _
  aDictionary as Dictionary( of( Point2 ), of( LinkedList( of( Person ) ) ) ), aKey as Point2 )
  
  var aList = aDictionary.find( aKey )
  
  if( aList <> 0 ) then
    var aNode = aList->first
    
    for items as integer = 0 to aList->count - 1
      ? *aNode->item
      
      aNode = aNode->forward
    next
  end if
end sub

/'
  Note that this kind of data structure effectively describes a Spatial Hash.
  
  Spatial Hashes are a very efficient method of space partition, and can be
  used as acceleration structures in place of quadtrees (for the 2D case) and
  octrees (for the 3D case).
'/
var aSpatialHash = Dictionary( of( Point2 ), of( LinkedList( of( Person ) ) ) )()

addTo( aSpatialHash, Point2( 2, 3 ), new Person( "Paul Doe", 37 ) )
addTo( aSpatialHash, Point2( 3, 1 ), new Person( "Janet Doe", 31 ) )
addTo( aSpatialHash, Point2( 4, 5 ), new Person( "Shaiel Doe", 10 ) )
addTo( aSpatialHash, Point2( 4, 5 ), new Person( "Foo Bar Baz", 99 ) )

? "At 2, 3"
showAt( aSpatialHash, Point2( 2, 3 ) )

?
? "At 3, 1"
showAt( aSpatialHash, Point2( 3, 1 ) )

?
? "At 4, 5"
showAt( aSpatialHash, Point2( 4, 5 ) )

sleep()
