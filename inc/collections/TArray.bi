#ifndef __FBFW_COLLECTIONS_ARRAY__
#define __FBFW_COLLECTIONS_ARRAY__

#macro template_array( TCollection, TType... )
  templateFor( Array )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( Array( __tcar__( TType ) ) ) )
  
  /'
    Represents a strongly typed dynamic array.
    
    Notice that, to be able to template it, the templated type *MUST*
    implement a default constructor, a copy constructor and the
    assignment operator. Primarily meant for standard data types and
    POD structures.
    
    TODO:
      - Implement multi-dimensional Arrays by using a variadic macro.
        I'm not too sure of the usefulness of this, though.
  '/
  type Array( of( TType ) ) extends Collection( of( TType ) )
    public:
      declare constructor()
      declare constructor( as integer )
      declare virtual destructor() override
      
      declare operator []( as integer ) byref as TType
      
      declare property count() as integer override
      declare property size() as integer override
      declare property at( as integer ) byref as TType
      declare property elements() as TType ptr
      
      declare function add( as TType ) byref as Array( of( TType ) )
      declare function remove( as integer ) byref as Array( of( TType ) )
      declare function insert( as TType, as integer ) byref as Array( of( TType ) )
      declare function clear() byref as Array( of( TType ) ) override
      
      declare function findAll( as Predicate( of( TType ) ) ) as Array( of( TType ) )
      declare function forEach( as Action( of( TType ) ) ) byref as Array( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as Array( of( TType ) ) override
      declare function forEach( _
          as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as Array( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), as any ptr = 0, as any ptr = 0 ) _
        byref as Array( of( TType ) ) override
      
    protected:
      declare sub resize( as integer )
    
    private:
      as TType _array( any )
      as integer _
        _initialSize, _
        _count, _
        _size, _
        _lowerbound
  end type
  
  implement_auto_ptr( of( Array( __tcar__( TType ) ) ) )
  
  constructor Array( of( TType ) )()
    constructor( 16 )
  end constructor
  
  constructor Array( of( TType ) )( aSize as integer )
    _size = iif( aSize < 16, 16, aSize )
    
    _initialSize = _size
    _count = 0
    _lowerBound = 0
    
    redim _array( 0 to _size - 1 )
  end constructor
  
  destructor Array( of( TType ) )()
  end destructor
  
  operator Array( of( TType ) ).[]( index as integer ) byref as TType
    return( _array( index ) )
  end operator
  
  property Array( of( TType ) ).count() as integer
    return( _count )
  end property
  
  property Array( of( TType ) ).size() as integer
    return( _size )
  end property
  
  property Array( of( TType ) ).at( index as integer ) byref as TType
    return( _array( index ) )
  end property
  
  property Array( of( TType ) ).elements() as TType ptr
    return( @_array( 0 ) )
  end property
  
  /'
    Resizes the internal array.
    
    The algorithm works like this:
    When the array is instantiated, the initial size is recorded, and
    it's used to determine when the array is to be resized, and by how
    much. In this case, the array grows every time the number of items
    exceed the initial value by half, and shrinks every time that the
    previous size is exceeded, also by half.
    
    This way, there is a 'window', centered around the current item count. 
    Hence, most of the resizing will happen during bulk addition or deletion
    operations, not when there's a relatively balanced number of them. 
    
    The array would never resize below the initial size requested.
    
    TODO:
      - The algorithm is the same as the one used for Lists. Perhaps
        both can use the same function, to improve code size.
  '/
  sub Array( of( TType ) ).resize( aNewSize as integer )
    aNewSize = iif( aNewSize < _initialSize, _initialSize, aNewSize )
    
    _size = aNewSize
    _lowerBound = _size - _initialSize - ( _initialSize shr 1 )
    
    _lowerBound = iif( _lowerBound < _initialSize, 0, _lowerBound )
    
    redim preserve _array( 0 to _size - 1 )
  end sub
  
  '' Clears the array
  function Array( of( TType ) ).clear() byref as Array( of( TType ) )
    _size = _initialSize
    _count = 0
    _lowerBound = 0
    
    redim _array( 0 to _size - 1 )
    
    return( this )
  end function
  
  '' Adds an element to the array
  function Array( of( TType ) ).add( anElement as TType ) byref as Array( of( TType ) )
    _count += 1
    
    if( _count > _size - _initialSize shr 1 ) then
      '' Resize the internal array if it's necessary
      resize( _size + _initialSize )
    end if
    
    '' And add the element to the end of the array
    _array( _count - 1 ) = anElement
    
    return( this )
  end function
  
  '' Removes an element from the array and adjust the others to fill
  '' in the blanks if needed.
  function Array( of( TType ) ).remove( index as integer ) byref as Array( of( TType ) )
    if( index < _count - 1 ) then
      for i as integer = index to _count - 1
        _array( i ) = _array( i + 1 )
      next
    end if
    
    _count -= 1
    
    '' Resize the array if needed
    if( _count <= _lowerBound ) then
      resize( _size - _initialSize )
    end if 
    
    return( this )
  end function
  
  '' Inserts an element into the array at the specified index.
  function Array( of( TType ) ).insert( anElement as TType, index as integer ) _
    byref as Array( of( TType ) )
    
    if( _count < 1 ) then
      '' If the array is empty, simply add the element.
      return( add( anElement ) )
    else
      '' List is not empty
      if( index >= _count - 1 ) then
        /'
          If index is out of range or at the end of the array, add
          the element as-is.
        '/
        return( add( anElement ) )
      else
        '' If not, add it at the requested place
        _count += 1
        
        if( _count > ( _size - _initialSize shr 1 ) ) then
          '' Resize the internal array if needed
          resize( _size + _initialSize )
        end if
        
        '' Move the items to make room for the inserted one
        if( index < _count - 1 ) then
          for i as integer = _count - 1 to index step -1
            _array( i ) = _array( i - 1 )
          next
        end if
        
        '' And add the item at the requested position
        _array( index ) = anElement
      end if
    end if
    
    return( this )
  end function
  
  '' Returns an array with all the elements that satisfy the specified
  '' predicate.
  function Array( of( TType ) ).findAll( aPredicate as Predicate( of( TType ) ) ) _
    as Array( of( TType ) )
    
    var result = Array( of( TType ) )
    
    for i as integer = 0 to _count - 1
      if( aPredicate.eval( @_array( i ) ) ) then
        result.add( _array( i ) )
      end if
    next
    
    return( result )
  end function
  
  '' Invokes the specified action on each of the elements of the array
  function Array( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as Array( of( TType ) )
    
    dim as integer index = 0
    
    do while( index < _count )
      anAction.indexOf = index
      anAction.invoke( @_array( index ) )
      index += 1
    loop
    
    return( this )
  end function
  
  function Array( of( TType ) ).forEach( anAction as ActionFunc( of( TType ) ), param as any ptr = 0 ) _
    byref as Array( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anAction( i, @_array( i ), param )
    next
    
    return( this )
  end function
  
  '' Invokes the specified action on each of the elements of the array if
  '' they satisfy the specified predicate.
  function Array( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as Array( of( TType ) )
    
    for i as integer = 0 to _count - 1
      aPredicate.indexOf = i
      
      if( aPredicate.eval( @_array( i ) ) ) then
        anAction.indexOf = i
        anAction.invoke( @_array( i ) )
      end if
    next
    
    return( this )
  end function
  
  function Array( of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anAction as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as Array( of( TType ) )
    
    for i as integer = 0 to _count - 1
      if( aPredicate( i, @_array( i ), aPredicateParam ) ) then
        anAction( i, @_array( i ), anActionParam )
      end if
    next
    
    return( this )
  end function
  
  operator = ( lhs as Array( of( TType ) ), rhs as Array( of( TType ) ) ) as integer
    return( @lhs = @rhs )
  end operator
  
  operator <> ( lhs as Array( of( TType ) ), rhs as Array( of( TType ) ) ) as integer
    return( @lhs <> @rhs )
  end operator
#endmacro

#endif
