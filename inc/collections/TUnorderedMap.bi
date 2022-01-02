#ifndef __FBFW_COLLECTIONS_UNORDEREDMAP__
#define __FBFW_COLLECTIONS_UNORDEREDMAP__

#macro template_unorderedmap( TCollection, TType... )
  templateFor( UnorderedMap )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( UnorderedMap( __tcar__( TType ) ) ) )

  type UnorderedMap( of ( TType ) ) extends Collection( of( TCollection ), of( TType ) )
    public:
      declare constructor()
      declare constructor( as UnorderedMap( of( TType ) ) )
      declare constructor( as integer )
      declare constructor( as boolean )
      declare constructor( as integer, as boolean )
      declare virtual destructor() override
      
      declare operator let( as UnorderedMap( of( TType ) ) )
      
      declare property count() as integer override
      declare property size() as integer override
      
      declare operator []( as integer ) byref as TType
      
      declare function clear() byref as UnorderedMap( of( TType ) ) override
      
      declare function add( byref as TType ) as integer
      declare function remove( as integer ) as integer
      
      declare function forEach( as Action( of( TType ) ) ) _
        byref as UnorderedMap( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as UnorderedMap( of( TType ) ) override
      declare function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as UnorderedMap( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), _
          as any ptr = 0, as any ptr = 0 ) _
        byref as UnorderedMap( of( TType ) ) override
      
    private:
      declare sub resize( byval as integer )
      
      as TType ptr _elements
      
      as integer _
        _count, _
        _size, _
        _initialSize, _
        _lowerBound
      as boolean _fixedSize
  end type
  
  implement_auto_ptr( of( UnorderedMap( __tcar__( TType ) ) ) )
  
  constructor UnorderedMap( of( TType ) )()
    constructor( 256, false )
  end constructor
  
  constructor UnorderedMap( of( TType ) )( aSize as integer )
    constructor( aSize, false )
  end constructor
  
  constructor UnorderedMap( of( TType ) )( isFixedSize as boolean )
    constructor( 256, isFixedSize )
  end constructor
  
  constructor UnorderedMap( of( TType ) )( aSize as integer, isFixedSize as boolean )
    _fixedSize = isFixedSize
    _size = iif( aSize < 4, 4, aSize )
    
    _initialSize = _size
    _count = 0
    _lowerBound = 0
    
    _elements = allocate( _size * sizeof( TType ) )
  end constructor
  
  constructor UnorderedMap( of( TType ) )( rhs as UnorderedMap( of( TType ) ) )
    deallocate( _elements )
    
    with rhs
      _size = ._size
      _count = ._count
      _initialSize = ._initialSize
      _lowerBound = ._lowerBound
      _fixedSize = ._fixedSize
    end with
    
    _elements = allocate( _size * sizeof( TType ) )
    memcpy( _elements, rhs._elements, _size * sizeof( TType ) )
  end constructor
  
  destructor UnorderedMap( of( TType ) )()
    deallocate( _elements )
  end destructor
  
  operator UnorderedMap( of( TType ) ).let( rhs as UnorderedMap( of( TType ) ) )
    deallocate( _elements )
    
    with rhs
      _size = ._size
      _count = ._count
      _initialSize = ._initialSize
      _lowerBound = ._lowerBound
      _fixedSize = ._fixedSize
    end with
    
    _elements = allocate( _size * sizeof( TType ) )
    
    memcpy( _
      _elements, rhs._elements, _size * sizeof( TType ) )
  end operator
  
  property UnorderedMap( of( TType ) ).count() as integer
    return( _count )
  end property
  
  property UnorderedMap( of( TType ) ).size() as integer
    return( _size )
  end property
  
  operator UnorderedMap( of( TType ) ).[] ( index as integer ) byref as TType
    return( _elements[ index ] )
  end operator
  
  sub UnorderedMap( of( TType ) ).resize( newSize as integer )
    newSize = iif( newSize < _initialSize, _initialSize, newSize )
    
    _size = newSize
    
    _lowerBound = _size - _initialSize - ( _initialSize shr 1 )
    _lowerBound = iif( _lowerBound < _initialSize, 0, _lowerBound )
    
    _elements = reallocate( _elements, _size * sizeOf( TType ) )
  end sub
  
  function UnorderedMap( of( TType ) ).clear() byref as UnorderedMap( of( TType ) )
    _size = _initialSize
    _count = 0
    _lowerBound = 0
    
    _elements = reallocate( _elements, _size * sizeOf( TType ) )
    
    return( this )
  end function
  
  function UnorderedMap( of( TType ) ).add( byref item as TType ) as integer
    _count += 1
    
    if( not _fixedSize ) then
      if( _count > ( _size - _initialSize shr 1 ) ) then
        '' Resize the internal array if necessary
        resize( _size + _initialSize )
      end if
    end if
    
    if( _count <= _size ) then
      '' And add the element to the end of the map
      _elements[ _count - 1 ] = item
      return( _count - 1 )
    end if
    
    _count = _size
    
    return( Collections.INVALID_HANDLE )
  end function
  
  function UnorderedMap( of( TType ) ).remove( index as integer ) as integer
    _elements[ index ] = _elements[ _count - 1 ]
    _count -= 1
    
    if( not _fixedSize ) then
      '' Resize the list if needed
      if( _count <= _lowerBound ) then
        resize( _size - _initialSize )
      end if 
    end if
    
    return( index )
  end function
  
  function UnorderedMap( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as UnorderedMap( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anAction.indexOf = i
      anAction.invoke( @_elements[ i ] )
    next
    
    return( this )
  end function
  
  function UnorderedMap( of( TType ) ).forEach( _
      anActionFunc as ActionFunc( of( TType ) ), anActionParam as any ptr = 0 ) _
    byref as UnorderedMap( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anActionFunc( i, @_elements[ i ], anActionParam )
    next
    
    return( this )
  end function
  
  function UnorderedMap( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as UnorderedMap( of( TType ) )
    
    for i as integer = 0 to _count - 1
      aPredicate.indexOf = i
      
      if( aPredicate.eval( @_elements[ i ] ) ) then
        anAction.indexOf = i
        anAction.invoke( @_elements[ i ] )
      end if
    next
    
    return( this )
  end function
  
  function UnorderedMap( of( TType ) ).forEach( _
      aPredicateFunc as PredicateFunc( of( TType ) ), anActionFunc as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as UnorderedMap( of( TType ) )
    
    for i as integer = 0 to _count - 1
      if( aPredicateFunc( _
        i, @_elements[ i ], aPredicateParam ) ) then
        
        anActionFunc( i, @_elements[ i ], anActionParam )
      end if
    next
    
    return( this )
  end function
#endmacro

#endif
