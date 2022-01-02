#ifndef __FBFW_COLLECTIONS_STACK__
#define __FBFW_COLLECTIONS_STACK__

#macro template_stack( TCollection, TType... )
  templateFor( Stack )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( Stack( __tcar__( TType ) ) ) )
  
  type Stack( of( TType ) ) extends Collection( of( TCollection ), of( TType ) )
    public:
      declare constructor()
      declare constructor( as integer )
      declare constructor( as boolean )
      declare constructor( as integer, as boolean )
      declare constructor( as Stack( of( TType ) ) )
      declare virtual destructor() override
      
      declare operator let( as Stack( of( TType ) ) )
      
      declare property count() as integer override
      declare property size() as integer override
      declare property top() byref as TType
      
      declare function clear() byref as Stack( of( TType ) ) override
      
      declare function push( byref as TType ) as boolean
      declare function pop() as TType
      
      declare function forEach( as Action( of( TType ) ) ) _
        byref as Stack( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as Stack( of( TType ) ) override
      declare function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as Stack( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), _
          as any ptr = 0, as any ptr = 0 ) _
        byref as Stack( of( TType ) ) override
      
    private:
      declare sub resize( as integer )
      
      as TType ptr _elements
      as integer _
        _count, _
        _size, _
        _initialSize, _
        _lowerBound
      as boolean _fixedSize
  end type
  
  implement_auto_ptr( of( Stack( __tcar__( TType ) ) ) )
  
  constructor Stack( of( TType ) )()
    constructor( 256, false )
  end constructor
  
  constructor Stack( of( TType ) )( aSize as integer )
    constructor( aSize, false )
  end constructor
  
  constructor Stack( of( TType ) )( isFixedSize as boolean )
    constructor( 256, isFixedSize )
  end constructor
  
  constructor Stack( of( TType ) )( _
    aSize as integer, isFixedSize as boolean )
    
    _fixedSize = isFixedSize
    _size = iif( aSize < 4, 4, aSize )
    
    _initialSize = _size
    _count = 0
    _lowerBound = 0
    
    _elements = allocate( _size * sizeOf( TType ) )
  end constructor
  
  constructor Stack( of( TType ) )( rhs as Stack( of( TType ) ) )
    deallocate( _elements )
    
    with rhs
      _size = ._size
      _count = ._count
      _initialSize = ._initialSize
      _lowerBound = ._lowerBound
      _fixedSize = ._fixedSize
    end with
    
    _elements = allocate( _size * sizeOf( TType ) )
    memcpy( _elements, rhs._elements, _size * sizeOf( TType ) )
  end constructor
  
  destructor Stack( of( TType ) )()
    deallocate( _elements )
  end destructor
  
  operator Stack( of( TType ) ).let( rhs as Stack( of( TType ) ) )
    deallocate( _elements )
    
    with rhs
      _size = ._size
      _count = ._count
      _initialSize = ._initialSize
      _lowerBound = ._lowerBound
      _fixedSize = ._fixedSize
    end with
    
    _elements = allocate( _size * sizeOf( TType ) )
    memcpy( _elements, rhs._elements, _size * sizeOf( TType ) )
  end operator
  
  property Stack( of( TType ) ).count() as integer
    return( _count )
  end property
  
  property Stack( of( TType ) ).size() as integer
    return( _size )
  end property
  
  property Stack( of( TType ) ).top() byref as TType
    return( _elements[ _count - 1 ] )
  end property
  
  sub Stack( of( TType ) ).resize( newSize as integer )
    newSize = iif( newSize < _initialSize, _initialSize, newSize )
    
    _size = newSize
    
    _lowerBound = _size - _initialSize - ( _initialSize shr 1 )
    _lowerBound = iif( _lowerBound < _initialSize, 0, _lowerBound )
    
    _elements = reallocate( _elements, _size * sizeof( TType ) )
  end sub
  
  function Stack( of( TType ) ).clear() byref as Stack( of( TType ) )
    _size = _initialSize
    _count = 0
    _lowerBound = 0
    
    _elements = reallocate( _elements, _size * sizeOf( TType ) )
    
    return( this )
  end function
  
  function Stack( of( TType ) ).push( byref item as TType ) as boolean
    _count += 1
    
    if( not _fixedSize ) then
      if( _count > ( _size - _initialSize shr 1 ) ) then
        '' Resize the internal array if necessary
        resize( _size + _initialSize )
      end if
    end if
    
    if( _count <= _size ) then
      '' And add the element to the end of the stack
      _elements[ _count - 1 ] = item
      return( true )
    end if
    
    _count = _size
    
    return( false )
  end function
  
  function Stack( of( TType ) ).pop() as TType
    var value = _elements[ _count - 1 ]
    
    _count -= 1
    
    if( not _fixedSize ) then
      '' Resize the list if needed
      if( _count <= _lowerBound ) then
        resize( _size - _initialSize )
      end if 
    end if
    
    return( value )
  end function
  
  function Stack( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as Stack( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anAction.indexOf = i
      anAction.invoke( @_elements[ i ] )
    next
    
    return( this )
  end function
  
  function Stack( of( TType ) ).forEach( _
      anActionFunc as ActionFunc( of( TType ) ), anActionParam as any ptr = 0 ) _
    byref as Stack( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anActionFunc( i, @_elements[ i ], anActionParam )
    next
    
    return( this )
  end function
  
  function Stack( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as Stack( of( TType ) )
    
    for i as integer = 0 to _count - 1
      aPredicate.indexOf = i
      
      if( aPredicate.eval( @_elements[ i ] ) ) then
        anAction.indexOf = i
        anAction.invoke( @_elements[ i ] )
      end if
    next
    
    return( this )
  end function
  
  function Stack( of( TType ) ).forEach( _
      aPredicateFunc as PredicateFunc( of( TType ) ), anActionFunc as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as Stack( of( TType ) )
    
    for i as integer = 0 to _count - 1
      if( aPredicateFunc( _
        i, @_elements[ i ], aPredicateParam ) ) then
        
        anActionFunc( i, @_elements[ i ], anActionParam )
      end if
    next
    
    return( this )
  end function
#endmacro

#undef implement_copy

#endif
