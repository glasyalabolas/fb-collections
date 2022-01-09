#ifndef __FBFW_COLLECTIONS_LIST__
#define __FBFW_COLLECTIONS_LIST__

#macro template_list( TCollection, TType... )
  templateFor( ListElement )
  templateFor( List )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( List( __tcar__( TType ) ) ) )
  
  '' Represents an element in an array-like list
  #ifndef __T__##ListElement##__##TType##__
  
  type ListElement( of( TType ) )
    public:
      declare constructor( as TType ptr, as boolean, as sub( byval as TType ptr ) )
      declare destructor()
      
      as TType ptr _item
      
    private:
      declare constructor()
      declare constructor( as ListElement( of( TType ) ) )
      declare operator let( as ListElement( of( TType ) ) )
      
      as boolean _needsDisposing
      as sub( as TType ptr ) _disposeCallback
  end type
  
  constructor ListElement( of( TType ) )()
  end constructor
  
  constructor ListElement( of( TType ) )( _
    anItem as TType ptr, aNeedsDisposing as boolean, aDisposeCallback as sub( as TType ptr ) )
    
    _item = anItem
    _needsDisposing = aNeedsDisposing
    _disposeCallback = aDisposeCallback
  end constructor
  
  constructor ListElement( of( TType ) )( rhs as ListElement( of( TType ) ) )
  end constructor
  
  destructor ListElement( of( TType ) )()
    if( _needsDisposing ) then
      if( _disposeCallback <> 0 ) then
        _disposeCallback( _item )
      else
        delete( _item )
      end if
    end if
  end destructor
  
  operator ListElement( of( TType ) ).let( rhs as ListElement( of( TType ) ) )
  end operator
  
  operator = ( lhs as ListElement( of( TType ) ), rhs as ListElement( of( TType ) ) ) as integer
    return( lhs._item = rhs._item )
  end operator
  
  #endif
  
  /'
    Represents a strongly-typed array-like list.
    
    It dynamically grows or shrinks to accomodate the amount of entries 
    put into it. However, there is some extra space allocated, to avoid 
    having to resize the array every time an item is added or removed 
    from it.
    
    So, the list grows or shrinks by an amount of elements equal to the 
    initial size given (also called the 'capacity').
  '/
  type List( of( TType ) ) extends Collection( of( TType ) )
    public:
      declare constructor()
      declare constructor( as integer )
      declare constructor( as sub( as TType ptr ) )
      declare constructor( as integer, as sub( as TType ptr ) )
      declare virtual destructor() override
      
      declare operator [] ( as integer ) byref as TType
      
      declare property size() as integer override
      declare property count() as integer override
      declare property at( as integer ) as TType ptr
      declare property elements() as ListElement( of( TType ) ) ptr ptr
      
      declare function clear() byref as List( of( TType ) ) override
      declare function contains( as const TType ) as boolean
      declare function containsItem( as TType ) as boolean
      declare function indexOf( as const TType ) as integer
      declare function add( byref as const TType ) byref as List( of( TType ) )
      declare function add( as TType ptr ) byref as List( of( TType ) )
      declare function addRange( as List( of( TType ) ) ) byref as List( of( TType ) )
      declare function insert( byref as const TType, as integer ) byref as List( of( TType ) )
      declare function insert( as TType ptr, as integer ) byref as List( of( TType ) )
      declare function insertRange( as List( of( TType ) ), as integer ) byref as List( of( TType ) )
      declare function remove( as const TType ) byref as List( of( TType ) )
      declare function removeAt( as integer ) byref as List( of( TType ) )
      declare function removeRange( as integer, as integer ) byref as List( of( TType ) )
      
      declare function forEach( as Action( of( TType ) ) ) _
        byref as List( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as List( of( TType ) ) override
      declare function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as List( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), _
          as any ptr = 0, as any ptr = 0 ) _
        byref as List( of( TType ) ) override
      
      declare function selectFirst( as Predicate( of( TType ) ) ) as TType ptr
      declare function selectFirst( as PredicateFunc( of( TType ) ), as any ptr = 0 ) as TType ptr
      declare function selectLast( as Predicate( of( TType ) ) ) as TType ptr
      declare function selectLast( as PredicateFunc( of( TType ) ), as any ptr = 0 ) as TType ptr
      declare function selectAll( as Predicate( of( TType ) ) ) _
        as Auto_ptr( of( List( of( TType ) ) ) )
      declare function selectAll( as PredicateFunc( of( TType ) ), as any ptr = 0 ) _
        as Auto_ptr( of( List( of( TType ) ) ) )
      
    protected:
      declare constructor( as List( of( TType ) ) )
      declare operator let( as List( of( TType ) ) )
    
    private:
      declare sub dispose()
      
      declare function addElement( as TType ptr, as boolean ) byref as List( of( TType ) )
      declare function insertElement( as TType ptr, as integer, as boolean ) _
        byref as List( of( TType ) )
      declare sub resize( as integer )
      
      declare function selectOne( _
          as integer, as integer, as integer, as Predicate( of( TType ) ) ptr ) _
        as TType ptr
      declare function selectOne( _
          as integer, as integer, as integer, as PredicateFunc( of( TType ) ), as any ptr = 0 ) _
        as TType ptr
      declare function selectMany( _
          as integer, as integer, as integer, as Predicate( of( TType ) ) ptr ) _
        as Auto_ptr( of( List( of( TType ) ) ) )
      declare function selectMany( _
          as integer, as integer, as integer, as PredicateFunc( of( TType ) ), as any ptr = 0 ) _
        as Auto_ptr( of( List( of( TType ) ) ) )
      
      as ListElement( of( TType ) ) ptr _elements( any )
      as integer _
        _count, _
        _size, _
        _initialSize, _
        _lowerBound
      
      as sub( as TType ptr ) _disposeCallback
  end type
  
  implement_auto_ptr( of( List( __tcar__( TType ) ) ) )
  
  constructor List( of( TType ) )()
    constructor( 32, 0 )
  end constructor
  
  constructor List( of( TType ) )( aSize as integer )
    constructor( aSize, 0 )
  end constructor
  
  constructor List( of( TType ) )( aDisposeCallback as sub( as TType ptr ) )
    
    constructor( 32, aDisposeCallback )
  end constructor
  
  constructor List( of( TType ) )( _
    aSize as integer, aDisposeCallback as sub( as TType ptr ) )
    
    _size = iif( aSize < 16, 16, aSize )
    
    _initialSize = _size
    _count = 0
    _lowerBound = 0
    
    redim _elements( 0 to _size - 1 )
    
    _disposeCallback = aDisposeCallback
  end constructor
  
  constructor List( of( TType ) )( rhs as List( of( TType ) ) )
  end constructor
  
  operator List( of( TType ) ).let( rhs as List( of( TType ) ) )
  end operator
  
  destructor List( of( TType ) )()
    dispose()
  end destructor
  
  operator List( of( TType ) ).[] ( index as integer ) byref as TType
    return( *( _elements( index )->_item ) )
  end operator
  
  sub List( of( TType ) ).dispose()
    for i as integer = 0 to _size - 1
      if( _elements( i ) <> 0 ) then
        delete( _elements( i ) )
        _elements( i ) = 0
      end if
    next
  end sub
  
  /'
    Resizes the internal array.
    
    The algorithm works like the one of the Array collection. See the
    implementation there for details.
  '/
  sub List( of( TType ) ).resize( newSize as integer )
    newSize = iif( newSize < _initialSize, _
      _initialSize, newSize )
    
    _size = newSize
    
    _lowerBound = _size - _initialSize - ( _initialSize shr 1 )
    _lowerBound = iif( _lowerBound < _initialSize, _
      0, _lowerBound )
    
    redim preserve _elements( 0 to _size - 1 )
  end sub
  
  property List( of( TType ) ).size() as integer
    return( _size )
  end property
  
  property List( of( TType ) ).count() as integer
    return( _count )
  end property
  
  '' Returns the value associated with the specified index
  property List( of( TType ) ).at( index as integer ) as TType ptr 
    return( _elements( index )->_item )
  end property
  
  property List( of( TType ) ).elements() as ListElement( of( TType ) ) ptr ptr
    return( @_elements( 0 ) )
  end property
  
  function List( of( TType ) ).contains( anItem as const TType ) as boolean
    return( cbool( indexOf( anItem ) > 0 ) )
  end function
  
  function List( of( TType ) ).containsItem( anItem as TType ) as boolean
    dim as boolean found = false
    
    for i as integer = 0 to _count - 1
      if( @anItem = _elements( i )->_item ) then
        found = true
        exit for
      end if
    next
    
    return( found )
  end function
  
  function List( of( TType ) ).indexOf( anItem as const TType ) as integer
    for i as integer = 0 to _count - 1
      if( cptr( TType ptr, @anItem ) = _elements( i )->_item ) then
        return( i )
      end if
    next
    
    return( -1 )
  end function
  
  function List( of( TType ) ).clear() byref as List( of( TType ) )
    dispose()
    
    _size = _initialSize
    _count = 0
    _lowerBound = 0
    
    redim _elements( 0 to _size - 1 )
    
    return( this )
  end function
  
  function List( of( TType ) ).addElement( anItem as TType ptr, needsDisposing as boolean ) _
    byref as List( of( TType ) )
    
    _count += 1
    
    if( _count > ( _size - _initialSize shr 1 ) ) then
      '' Resize the internal array if it's necessary
      resize( _size + _initialSize )
    end if
    
    '' And add the element to the end of the list
    _elements( _count - 1 ) = new ListElement( of( TType ) )( _
      anItem, _
      needsDisposing, _
      _disposeCallback )
    
    return( this )
  end function
  
  '' Inserts an element at the specified index.
  function List( of( TType ) ).insertElement( _
      anElement as TType ptr, index as integer, needsDisposing as boolean ) _
    byref as List( of( TType ) )
    
    if( _count < 1 ) then
      '' List is empty, simply add the element and be done with it
      addElement( anElement, needsDisposing )
    else
      '' If list is not empty, insert the element
      if( index > _count - 1 ) then
        '' If index is out of range, add it at the end of the list
        addElement( anElement, needsDisposing )
      else
        '' If not, add it at the requested place
        _count += 1
        
        if( _count > ( _size - _initialSize shr 1 ) ) then
          '' Resize the internal array if it's necessary
          resize( _size + _initialSize )
        end if
        
        '' Move the items to make room for the inserted one
        if( index < _count - 1 ) then
          for i as integer = _count - 1 to index step -1
            _elements( i ) = _elements( i - 1 )
          next
        end if
        
        '' And add the item at the requested position
        _elements( index ) = new ListElement( of( TType ) )( _
          anElement, _
          needsDisposing, _
          _disposeCallback )
      end if
    end if
    
    return( this )
  end function
  
  function List( of( TType ) ).add( byref anItem as const TType ) byref as List( of( TType ) )
    return( addElement( cptr( TType ptr, @anItem ), false ) )
  end function
  
  function List( of( TType ) ).add( anItem as TType ptr ) byref as List( of( TType ) )
    return( addElement( anItem, true ) )
  end function
  
  function List( of( TType ) ).addRange( aList as List( of( TType ) ) ) byref as List( of( TType ) )
    for i as integer = 0 to aList.count - 1
      add( *aList.at( i ) )
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).insert( byref anItem as const TType, anIndex as integer ) _
    byref as List( of( TType ) )
    
    return( insertElement( cptr( TType ptr, @anItem ), anIndex, false ) )
  end function
  
  function List( of( TType ) ).insert( anItem as TType ptr, anIndex as integer ) _
    byref as List( of( TType ) )
    
    return( insertElement( anItem, anIndex, true ) )
  end function
  
  function List( of( TType ) ).insertRange( aList as List( of( TType ) ), anIndex as integer ) _
    byref as List( of( TType ) )
    
    for i as integer = aList.count - 1 to 0 step -1
      insert( *aList.at( i ), anIndex )
    next
    
    return( this )
  end function
  
  '' Removes the specified element
  function List( of( TType ) ).remove( anItem as const TType ) byref as List( of( TType ) )
    for i as integer = 0 to _count - 1
      if( cptr( TType ptr, @anItem ) = _elements( i )->_item ) then
        removeAt( i )
        exit for
      end if
    next
    
    return( this )
  end function
  
  '' Removes the element at the specified index.
  function List( of( TType ) ).removeAt( index as integer ) byref as List( of( TType ) )
    if( _count > 0 ) then
      dim as ListElement( of( TType ) ) ptr element = _elements( index )
      
      /'
        Removes element and adjust the others to fill the blanks
        if needed.
      '/
      if( index < _count - 1 ) then
        for i as integer = index to _count - 1
          _elements( i ) = _elements( i + 1 )
        next
      end if
      
      delete( element )
      _count -= 1
      
      '' Resize the list if needed
      if( _count <= _lowerBound ) then
        resize( _size - _initialSize )
      end if 
    end if
    
    return( this )
  end function
  
  function List( of( TType ) ).removeRange( anIndex as integer, aCount as integer ) _
    byref as List( of( TType ) )
    
    for i as integer = 0 to aCount - 1
      removeAt( anIndex )
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) byref as List( of( TType ) )
    for i as integer = 0 to _count - 1
      anAction.indexOf = i
      anAction.invoke( _elements( i )->_item )
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).forEach( _
      anAction as ActionFunc( of( TType ) ), anActionParam as any ptr = 0 ) _
    byref as List( of( TType ) )
    
    for i as integer = 0 to _count - 1
      anAction( i, _elements( i )->_item, anActionParam )
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as List( of( TType ) )
    
    for i as integer = 0 to _count - 1
      aPredicate.indexOf = i
      
      if( aPredicate.eval( _elements( i )->_item ) ) then
        anAction.indexOf = i
        anAction.invoke( _elements( i )->_item )
      end if
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anAction as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as List( of( TType ) )
    
    for i as integer = 0 to _count - 1
      if( aPredicate( i, _elements( i )->_item, aPredicateParam ) ) then
        anAction( i, _elements( i )->_item, anActionParam )
      end if
    next
    
    return( this )
  end function
  
  function List( of( TType ) ).selectOne( _
      first as integer, last as integer, inc as integer, aPredicate as Predicate( of( TType ) ) ptr ) _
    as TType ptr
    
    dim as TType ptr result
    
    for i as integer = first to last step inc
      aPredicate->indexOf = i
      
      if( aPredicate->eval( _elements( i )->_item ) ) then
        result = _elements( i )->_item
        exit for
      end if
    next
    
    return( result )
  end function
  
  function List( of( TType ) ).selectOne( _
      first as integer, last as integer, inc as integer, _
      aPredicate as PredicateFunc( of( TType ) ), aParam as any ptr = 0 ) _
    as TType ptr
    
    dim as TType ptr result
    
    for i as integer = first to last step inc
      if( aPredicate( i, _elements( i )->_item, aParam ) ) then
        result = _elements( i )->_item
        exit for
      end if
    next
    
    return( result )
  end function
  
  function List( of( TType ) ).selectMany( _
      first as integer, last as integer, inc as integer, aPredicate as Predicate( of( TType ) ) ptr ) _
    as Auto_ptr( of( List( of( TType ) ) ) )
    
    var result = new List( of( TType ) )
    
    for i as integer = first to last step inc
      aPredicate->indexOf = i
      
      if( aPredicate->eval( _elements( i )->_item ) ) then
        result->add( *_elements( i )->_item )
      end if
    next
    
    return( Auto_ptr( of( List( of( TType ) ) ) )( result ) )
  end function
  
  function List( of( TType ) ).selectMany( _
      first as integer, last as integer, inc as integer, _
      aPredicate as PredicateFunc( of( TType ) ), aParam as any ptr = 0 ) _
    as Auto_ptr( of( List( of( TType ) ) ) )
    
    var result = new List( of( TType ) )
    
    for i as integer = first to last step inc
      if( aPredicate( i, _elements( i )->_item, aParam ) ) then
        result->add( *_elements( i )->_item )
      end if
    next
    
    return( Auto_ptr( of( List( of( TType ) ) ) )( result ) )
  end function
  
  function List( of( TType ) ).selectFirst( aPredicate as Predicate( of( TType ) ) ) _
    as TType ptr
    
    return( selectOne( 0, _count - 1, 1, @aPredicate ) )
  end function
  
  function List( of( TType ) ).selectFirst( _
      aPredicate as PredicateFunc( of( TType ) ), aParam as any ptr = 0 ) _
    as TType ptr
    
    return( selectOne( 0, _count - 1, 1, aPredicate, aParam ) )
  end function
  
  function List( of( TType ) ).selectLast( aPredicate as Predicate( of( TType ) ) ) as TType ptr
    return( selectOne( _count - 1, 0, -1, @aPredicate ) )
  end function
  
  function List( of( TType ) ).selectLast( _
      aPredicate as PredicateFunc( of( TType ) ), aParam as any ptr = 0 ) _
    as TType ptr
    
    return( selectOne( _count - 1, 0, -1, aPredicate, aParam ) )
  end function
  
  function List( of( TType ) ).selectAll( aPredicate as Predicate( of( TType ) ) ) _
    as Auto_ptr( of( List( of( TType ) ) ) )
    
    return( selectMany( 0, _count - 1, 1, @aPredicate ) )
  end function
  
  function List( of( TType ) ).selectAll( _
      aPredicate as PredicateFunc( of( TType ) ), aParam as any ptr = 0 ) _
    as Auto_ptr( of( List( of( TType ) ) ) )
    
    return( selectMany( 0, _count - 1, 1, aPredicate, aParam ) )
  end function
  
  operator = ( lhs as List( of( TType ) ), rhs as List( of( TType ) ) ) as integer
    return( @lhs = @rhs )
  end operator
  
  operator <> ( lhs as List( of( TType ) ), rhs as List( of( TType ) ) ) as integer
    return( @lhs <> @rhs )
  end operator
#endmacro

#endif
