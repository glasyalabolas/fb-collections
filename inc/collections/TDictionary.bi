#ifndef __FBFW_COLLECTIONS_DICTIONARY__
#define __FBFW_COLLECTIONS_DICTIONARY__

#macro template_dictionary( TCollection, TKey, TType... )
  templateFor( Dictionary )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_keyValuePair( of( TKey ), __tcar__( TType ) )
  template_action( of( KeyValuePair( of( TKey ), __tcar__( TType ) ) ) ) 
  template_predicate( of( KeyValuePair( of( TKey ), __tcar__( TType ) ) ) )
  
  '' Note the use of this macro instead of 'template'. Doing so will
  '' avoid creating a recursive macro, which isn't allowed.
  template_type_non_keyed( LinkedList, of( KeyValuePair( of( TKey ), __tcar__( TType ) ) ) )
  
  template_collection( ofKey( Dictionary, of( TKey ) ), __tcar__( TType ) )
  
  '' Represents a strongly-typed dictionary of key-value pairs
  type Dictionary( of( TKey ), of( TType ) ) extends Collection( of( TType ) )
    public:
      declare constructor()
      declare constructor( as integer )
      declare virtual destructor() override
      
      declare property size() as integer override
      declare property count() as integer override
      
      declare operator []( as TKey ) as TType ptr
      
      declare function containsKey( as TKey ) as boolean
      declare sub getKeys( a() as TKey )
      declare function add( as TKey, as TType ptr ) _
        byref as Dictionary( of( TKey ), of( TType ) )
      declare function add( as TKey, as TType ptr, byref as TType ) _
        byref as Dictionary( of( TKey ), of( TType ) )
      declare function add( as TKey, byref as TType ) _
        byref as Dictionary( of( TKey ), of( TType ) )
      declare function remove( as TKey ) _
        byref as Dictionary( of( TKey ), of( TType ) )
      declare function removeItem( as TKey ) as TType ptr
      declare function clear() byref as Dictionary( of( TKey ), of( TType ) ) override
      declare function find( as TKey ) as TType ptr
      
      declare function findEntry( as TKey ) _
        as KeyValuePair( of( TKey ), of( TType ) ) ptr
      declare function findBucket( as TKey ) _
        as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr
        
      declare function forEach( as Action( of( TType ) ) ) _
        byref as Dictionary( of( TKey ), of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as Dictionary( of( TKey ), of( TType ) ) override
      declare function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as Dictionary( of( TKey ), of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), as any ptr = 0, as any ptr = 0 ) _
        byref as Dictionary( of( TKey ), of( TType ) ) override
      
    protected:
      declare constructor( as Dictionary( of( TKey ), of( TType ) ) )
      declare operator let( as Dictionary( of( TKey ), of( TType ) ) )
      
    private:
      declare sub dispose( _
        as integer, as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ptr ) 
      declare sub setResizeThresholds( as integer, as single, as single )
      declare sub addEntry( _
        as KeyValuePair( of( TKey ), of( TType ) ) ptr, _
        as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ptr, _
        as integer )
      declare function removeEntry( aKey as TKey ) byref as Dictionary( of( TKey ), of( TType ) )
      declare sub rehash( as integer )
      
      as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ptr _
        _hashTable
      as integer _
        _count, _
        _size, _
        _initialSize, _
        _maxThreshold, _
        _minThreshold
  end type
  
  constructor Dictionary( of( TKey ), of( TType ) )()
    constructor( 256 )
  end constructor
  
  constructor Dictionary( of( TKey ), of( TType ) )( aSize as integer )
    _initialSize = iif( aSize < 8, 8, aSize )
    _size = _initialSize
    
    _hashTable = callocate( _
      _size, sizeof( LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ) )
      
    setResizeThresholds( _initialSize, 0.55, 0.85 )
  end constructor
  
  constructor Dictionary( of( TKey ), of( TType ) )( rhs as Dictionary( of( TKey ), of( TType ) ) )
  end constructor
  
  operator Dictionary( of( TKey ), of( TType ) ).let( rhs as Dictionary( of( TKey ), of( TType ) ) )
  end operator
  
  destructor Dictionary( of( TKey ), of( TType ) )()
    dispose( _size, _hashTable )
    
    deallocate( _hashTable )
  end destructor
  
  property Dictionary( of( TKey ), of( TType ) ).count() as integer
    return( _count )
  end property
  
  property Dictionary( of( TKey ), of( TType ) ).size() as integer
    return( _size )
  end property
  
  operator Dictionary( of( TKey ), of( TType ) ).[]( k as TKey ) as TType ptr
    return( find( k ) )
  end operator
  
  '' Disposes all the elements of the internal hash table
  sub Dictionary( of( TKey ), of( TType ) ).dispose( _
    aSize as integer, aHashTable as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ptr )
    
    for i as integer = 0 to aSize - 1
      if( aHashTable[ i ] <> 0 ) then
        delete( aHashTable[ i ] )
        aHashTable[ i ] = 0
      end if
    next
  end sub
  
  /'
    Sets the resize thresholds on rehashings, expressed in 
    normalized percentages of the previous size (the 'lower'
    parameter) and the current size (the 'upper' parameter). 
    Since the hash table always grows and shrinks by a fixed 
    factor of 2, the previous size is computed by dividing the
    current size by 2.
    
    The factors used in the code are 0.55 for the lower threshold
    and 0.85 for the higher threshold. This maintains the load of
    the table at around 0.50, that is, near-optimal. Doing this
    helps to keep rehashings to a minimum, and at the same time
    maintains a fast access time and a reasonable memory
    footprint.
    
    As it is currently tailored, it slightly favors additions over
    removals, but they should take about the same time, nonetheless.
  '/
  sub Dictionary( of( TKey ), of( TType ) ).setResizeThresholds( _
    newSize as integer, lower as single, upper as single )
    
    '' Don't let the new size fall below the initial size
    newSize = iif( newSize < _initialSize, _initialSize, newSize )
    
    '' Compute previous size
    dim as integer previousSize = newSize shr 1
    
	  '' If the previous size is below the initial size, set it to 0
    previousSize = iif( previousSize < _initialSize, 0, previousSize )
    
    '' Calculate the lower and upper thresholds in number of entries
    _minThreshold = int( previousSize * lower )
    _maxThreshold = int( newSize * upper )
  end sub
  
  /'
    Rehashes the internal hash table to the specified size. Used
    when the size of the table changes to keep all key-value pairs
    up to date.
  '/
  sub Dictionary( of( TKey ), of( TType ) ).rehash( newSize as integer )
    setResizeThresholds( newSize, 0.55, 0.85 )
    
    dim as LinkedList( of( KeyValuePair( _
      of( TKey ), of( TType ) ) ) ) ptr ptr _
      newTable = callocate( _
        newSize, sizeof( LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ) )
      
    _count = 0
    
    for i as integer = 0 to _size - 1
      var aBucket = _hashTable[ i ]
      
      if( aBucket <> 0 ) then
        var aNode = aBucket->first
        
        do while( aNode <> 0 )
          addEntry( aNode->item, newTable, newSize )
          
          aNode->item = 0
          aNode = aNode->forward
        loop
      end if
    next
    
    dispose( _size, _hashTable )
    deallocate( _hashTable )
    
    _size = newSize
    _hashTable = newTable
  end sub
  
  function Dictionary( of( TKey ), of( TType ) ).clear() byref as Dictionary( of( TKey ), of( TType ) )
    dispose( _size, _hashTable )
    
    _size = _initialSize
    _count = 0
    
    setResizeThresholds( _initialSize, 0.55, 0.85 )
    
    return( this )
  end function
  
  '' Returns whether or not the dictionary contains the specified key
  function Dictionary( of( TKey ), of( TType ) ).containsKey( aKey as TKey ) as boolean
    return( cbool( findEntry( aKey ) <> 0 ) )
  end function
  
  sub Dictionary( of( TKey ), of( TType ) ).getKeys( a() as TKey )
    redim a( 0 to _count - 1 )
    
    dim as integer item
    
    for i as integer = 0 to _size - 1
      if( _hashTable[ i ] <> 0 ) then
        var n = _hashTable[ i ]->last
        
        for j as integer = 0 to _hashTable[ i ]->count - 1
          a( item ) = n->item->_key.value
          item += 1
          
          n = n->backward
        next
      end if
    next
  end sub
  
  '' Finds a bucket in the internal hash table
  function Dictionary( of( TKey ), of( TType ) ).findBucket( aKey as TKey ) _
    as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr
    
    return( _hashTable[ Key( _
      of( TKey ) )( aKey ).getHashCode() mod _size ] )
  end function
  
  '' Find a key-value pair in the internal hash table
  function Dictionary( of( TKey ), of( TType ) ).findEntry( aKey as TKey ) _
    as KeyValuePair( of( TKey ), of( TType ) ) ptr
    
    dim as KeyValuePair( of( TKey ), of( TType ) ) ptr _
      entry = 0
    
    var aBucket = findBucket( aKey )
    
    if( aBucket <> 0 ) then
      var aNode = aBucket->last
      
      do while( aNode <> 0 )
        if( aNode->item->_key = aKey ) then
          entry = aNode->item
          exit do
        end if
        
        aNode = aNode->backward
      loop
    end if
    
    return( entry )
  end function
  
  '' Finds a value within the dictionary, using the specified key
  function Dictionary( of( TKey ), of( TType ) ).find( aKey as TKey ) as TType ptr
    var anEntry = findEntry( aKey )
    
    return( iif( anEntry <> 0, anEntry->_value, 0 ) )
  end function
  
  '' Adds a key-value pair to the specified hash table
  sub Dictionary( of( TKey ), of( TType ) ).addEntry( _
    anEntry as KeyValuePair( of( TKey ), of( TType ) ) ptr, _
    aHashTable as LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) ) ptr ptr, _
    aSize as integer )
    
    dim as ulong bucketNumber = anEntry->_key.getHashCode() mod aSize
    
    if( aHashTable[ bucketNumber ] = 0 ) then
      aHashTable[ bucketNumber ] = new LinkedList( of( KeyValuePair( of( TKey ), of( TType ) ) ) )
      aHashTable[ bucketNumber ]->addLast( anEntry )
    else
      aHashTable[ bucketNumber ]->addLast( anEntry )
    end if
    
    _count += 1
  end sub
  
  '' Adds a value to the dictionary, using the specified key
  function Dictionary( of( TKey ), of( TType ) ).add( _
      aKey as TKey, byref aValue as TType ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    addEntry( new KeyValuePair( of( TKey ), of( TType ) )( aKey, aValue ), _hashTable, _size )
    
    if( _count > _maxThreshold ) then
      rehash( _size shl 1  )
    end if
    
    return( this )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).add( _
      aKey as TKey, aValue as TType ptr ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    addEntry( new KeyValuePair( of( TKey ), of( TType ) )( aKey, aValue ), _hashTable, _size )
    
    if( _count > _maxThreshold ) then
      rehash( _size shl 1  )
    end if
    
    return( this )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).add( _
      aKey as TKey, aValue as TType ptr, byref anInitialValue as TType ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    addEntry( new KeyValuePair( of( TKey ), of( TType ) )( aKey, aValue ), _hashTable, _size )
    
    if( _count > _maxThreshold ) then
      rehash( _size shl 1  )
    end if
    
    return( this )
  end function
  
  '' Removes a key-value pair from the internal hash table
  function Dictionary( of( TKey ), of( TType ) ).removeEntry( aKey as TKey ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    var aBucket = findBucket( aKey )
    
    if( aBucket <> 0 ) then
      var aNode = aBucket->last
      
      do while( aNode <> 0 )
        if( aNode->item->_key = aKey ) then
          aBucket->remove( aNode )
          
          _count -= 1
          
          if( _count < _minThreshold ) then
            rehash( _size shr 1 )
          end if
          
          exit do
        end if
        
        aNode = aNode->backward
      loop
    end if
    
    return( this )
  end function
  
  /'
    Removes a key-value pair from the internal hash table.
    
    Returns the item that was associated with the pair, or
    a null pointer if the item was not found.
  '/
  function Dictionary( of( TKey ), of( TType ) ).removeItem( aKey as TKey ) _
    as TType ptr
    
    var aBucket = findBucket( aKey )
    
    dim as TType ptr item
    
    if( aBucket <> 0 ) then
      var aNode = aBucket->last
      
      do while( aNode <> 0 )
        if( aNode->item->_key = aKey ) then
          var entry = aBucket->removeItem( aNode )
          
          item = entry->_value
          entry->_value = 0
          
          delete( entry )
          
          _count -= 1
          
          if( _count < _minThreshold ) then
            rehash( _size shr 1 )
          end if
          
          exit do
        end if
        
        aNode = aNode->backward
      loop
    end if
    
    return( item )
  end function
  
  '' Removes an entry from the dictionary using the specified key
  function Dictionary( of( TKey ), of( TType ) ).remove( aKey as TKey ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    return( removeEntry( aKey ) )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    for i as integer = 0 to _size - 1
      if( _hashTable[ i ] <> 0 ) then
        var n = _hashTable[ i ]->first
        
        for j as integer = 0 to _hashTable[ i ]->count - 1
          anAction.invoke( n->item->_value )
          
          n = n->forward
        next
      end if
    next
    
    return( this )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).forEach( _
      anAction as ActionFunc( of( TType ) ), param as any ptr = 0 ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    for i as integer = 0 to _size - 1
      if( _hashTable[ i ] <> 0 ) then
        var n = _hashTable[ i ]->first
        
        for j as integer = 0 to _hashTable[ i ]->count - 1
          anAction( i, n->item->_value, param )
          
          n = n->forward
        next
      end if
    next
    
    return( this )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    for i as integer = 0 to _size - 1
      if( _hashTable[ i ] <> 0 ) then
        var n = _hashTable[ i ]->first
        
        for j as integer = 0 to _hashTable[ i ]->count - 1
          if( aPredicate.eval( n->item->_value ) ) then
            anAction.invoke( n->item->_value )
          end if
          
          n = n->forward
        next
      end if
    next
    
    return( this )
  end function
  
  function Dictionary( of( TKey ), of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anAction as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as Dictionary( of( TKey ), of( TType ) )
    
    for i as integer = 0 to _size - 1
      if( _hashTable[ i ] <> 0 ) then
        var n = _hashTable[ i ]->first
        
        for j as integer = 0 to _hashTable[ i ]->count - 1
          if( aPredicate( i, n->item->_value, aPredicateParam ) ) then
            anAction( i, n->item->_value, anActionParam )
          end if
          
          n = n->forward
        next
      end if
    next
    
    return( this )
  end function
  
  operator = ( _
      lhs as Dictionary( of( TKey ), of( TType ) ), rhs as Dictionary( of( TKey ), of( TType ) ) ) _
    as integer
    
    return( @lhs = @rhs )
  end operator
  
  operator <> ( _
      lhs as Dictionary( of( TKey ), of( TType ) ), rhs as Dictionary( of( TKey ), of( TType ) ) ) _
    as integer
    
    return( @lhs <> @rhs )
  end operator
#endmacro

#endif
