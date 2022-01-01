#ifndef __FBFW_COLLECTIONS_TKEYS__
#define __FBFW_COLLECTIONS_TKEYS__

#include once "../templates.bi"

#define Key( TType ) __T__##Key##__##TType

'' Keys for all FreeBasic standard data types
type Key( of( string ) )
  public:
    declare constructor()
    declare constructor( as const string )
    declare constructor( as Key( of( string ) ) )
    declare destructor()
    
    declare operator let( as string )
    declare operator let( as Key( of( string ) ) )
    
    declare function getHashCode() as ulong
    
    as string value
end type

constructor Key( of( string ) )()
end constructor

constructor Key( of( string ) )( aKey as const string )
  value = aKey
end constructor

constructor Key( of( string ) )( rhs as Key( of( string ) ) )
  value = rhs.value
end constructor

destructor Key( of( string ) )()
end destructor

operator Key( of( string ) ).let( rhs as string )
  value = rhs
end operator

operator Key( of( string ) ).let( rhs as Key( of( string ) ) )
  value = rhs.value
end operator

function Key( of( string ) ).getHashCode() as ulong
  #define ROT( a, b ) ( ( a shl b ) or ( a shr ( 32 - b ) ) )
  
  dim as zstring ptr strp = strPtr( value )
  dim as integer _
    leng = len( value ), _
    extra_bytes = leng and 3
  
  leng shr= 2
  
  dim as ulong hash = &hdeadbeef
  
  do while( leng )
    hash += *cast( ulong ptr, strp )
    strp += 4
    hash = ( hash shl 5 ) - hash
    hash xor= ROT( hash, 19 )
    leng -= 1
  loop
  
  if( extra_bytes ) then
    select case as const( extra_bytes )
      case 3
        hash xor= *cast( ulong ptr, strp ) and &hffffff
      case 2
        hash xor= *cast( ulong ptr, strp ) and &hffff
      case 1
        hash xor= *strp
    end select
    
    hash = ( hash shl 5 ) - hash
    hash xor= rot( hash, 19 )
  end if
  
  hash += ROT( hash, 2 )
  hash xor= ROT( hash, 27 )
  hash += ROT( hash, 16 )
  
  return( hash )
end function

operator = ( lhs as Key( of( string ) ), rhs as Key( of( string ) ) ) as integer
  return( lhs.value = rhs.value )
end operator

#macro template_key( TType )
  #ifndef __T__##Key##__##TType
  
  type Key( of( TType ) )
    public:
      declare constructor()
      declare constructor( as const TType )
      declare constructor( as Key( of( TType ) ) )
      declare destructor()
      
      declare operator let( as TType )
      declare operator let( as Key( of( TType ) ) )
      
      declare function getHashCode() as ulong
      
      as TType value
  end type
  
  constructor Key( of( TType ) )()
  end constructor
  
  constructor Key( of( TType ) )( aValue as const TType )
    value = aValue
  end constructor
  
  constructor Key( of( TType ) )( aKey as Key( of( TType ) ) )
    value = aKey.value
  end constructor
  
  destructor Key( of( TType ) )()
  end destructor
  
  operator Key( of( TType ) ).let( aValue as TType )
    value = aValue
  end operator
  
  operator Key( of( TType ) ).let( aKey as Key( of( TType ) ) )
    value = aKey.value
  end operator
  
  function Key( of( TType ) ).getHashCode() as ulong
    return( culng( value ) )
  end function
  
  operator = ( lhs as Key( of( TType ) ), rhs as Key( of( TType ) ) ) as integer
    return( lhs.value = rhs.value )
  end operator
  
  #endif
#endmacro
  
#macro template_key_float( TType )
  #ifndef __T__##Key##__##TType
  
  type Key( of( TType ) )
    public:
      declare constructor()
      declare constructor( as const TType )
      declare constructor( as Key( of( TType ) ) )
      declare destructor()
      
      declare operator let( as TType )
      declare operator let( as Key( of( TType ) ) )
      
      declare function getHashCode() as ulong
      
      as TType value
  end type
  
  constructor Key( of( TType ) )()
  end constructor
  
  constructor Key( of( TType ) )( aValue as const TType )
    value = aValue
  end constructor
  
  constructor Key( of( TType ) )( aKey as Key( of( TType ) ) )
    value = aKey.value
  end constructor
  
  destructor Key( of( TType ) )()
  end destructor
  
  operator Key( of( TType ) ).let( aValue as TType )
    value = aValue
  end operator
  
  operator Key( of( TType ) ).let( aKey as Key( of( TType ) ) )
    value = aKey.value
  end operator
  
  function Key( of( TType ) ).getHashCode() as ulong
    return( *cptr( ulong ptr, @value ) )
  end function
  
  operator = ( lhs as Key( of( TType ) ), rhs as Key( of( TType ) ) ) as integer
    return( lhs.value = rhs.value )
  end operator
  
  #endif
#endmacro

template_key( byte )
template_key( ubyte )
template_key( short )
template_key( ushort )
template_key( long )
template_key( ulong )
template_key( integer )
template_key( uinteger )
template_key( boolean )

template_key_float( single )
template_key_float( double )

#endif
