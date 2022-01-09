#ifndef __FBFW_COLLECTIONS_PRIORITYQUEUE__
#define __FBFW_COLLECTIONS_PRIORITYQUEUE__

#macro template_priorityqueue( TCollection, TType... )
  templateFor( QueueElement )
  templateFor( PriorityQueue )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( PriorityQueue( __tcar__( TType ) ) ) )
  
  /'
    Represents an element of the priority queue.
    
    There's no need to instantiate or extend this class, as it is
    used by the internal heap only.
  '/
  #ifndef __T__##QueueElement##__##TType##__ 
  
  type QueueElement( of( TType ) )
    public:
      declare constructor( as integer, as TType ptr, as boolean )
      declare destructor()
      
      declare property priority() as integer
      declare property value() as TType ptr
      
      declare function detach() as TType ptr
      
    private:
      declare constructor()
      
      declare constructor( as QueueElement( of( TType ) ) )
      declare operator let( as QueueElement( of( TType ) ) )
      
      '' The priority of this element
      as integer _priority
      
      '' The value associated with this element
      as TType ptr _value
      
      as boolean _needsDisposing
  end type
  
  constructor QueueElement( of( TType ) )()
  end constructor
  
  constructor QueueElement( of( TType ) )( _
    aPriority as integer, aValue as TType ptr, needsDisposing as boolean )
     
    _priority = aPriority
    _value = aValue
    _needsDisposing = needsDisposing
  end constructor
  
  constructor QueueElement( of( TType ) )( rhs as QueueElement( of( TType ) ) )
  end constructor
  
  operator QueueElement( of( TType ) ).let( rhs as QueueElement( of( TType ) ) )
  end operator
  
  destructor QueueElement( of( TType ) )()
    if( _needsDisposing andAlso _value <> 0 ) then
      delete( _value )
    end if
  end destructor
  
  property QueueElement( of( TType ) ).priority() as integer
    return( _priority )
  end property
  
  property QueueElement( of( TType ) ).value() as TType ptr
    return( _value )
  end property
  
  function QueueElement( of( TType ) ).detach() as TType ptr
    var element = _value
    
    _value = 0
    
    return( element )
  end function
  
  operator < ( lhs as QueueElement( of( TType ) ), rhs as QueueElement( of( TType ) ) ) as integer
    return( lhs.priority < rhs.priority )
  end operator
  
  operator > ( lhs as QueueElement( of( TType ) ), rhs as QueueElement( of( TType ) ) ) as integer
    return( lhs.priority > rhs.priority )
  end operator
  
  #endif
  
  '' Represents a strongly-typed priority queue (aka binary heap) 
  type PriorityQueue( of( TType ) ) extends Collection( of( TType ) )
    public:
      declare constructor()
      declare constructor( as integer )
      declare constructor( as Collections.PriorityOrder )
      declare constructor( as integer, as Collections.PriorityOrder )
      declare virtual destructor() override
      
      declare property size() as integer override
      declare property count() as integer override
      declare property top() as TType ptr
      
      declare function clear() byref as PriorityQueue( of( TType ) ) override
      declare function enqueue( as integer, as TType ptr ) _
        byref as PriorityQueue( of( TType ) )
      declare function enqueue( as integer, byref as const TType ) _
        byref as PriorityQueue( of( TType ) )
      declare function dequeue() as TType ptr
      declare function forEach( as Action( of( TType ) ) ) _
        byref as PriorityQueue( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as PriorityQueue( of( TType ) ) override
      declare function forEach( _
          as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as PriorityQueue( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), as any ptr = 0, as any ptr = 0 ) _
        byref as PriorityQueue( of( TType ) ) override
      
    private:
      declare sub dispose()
      declare function enqueueElement( as QueueElement( of( TType ) ) ptr ) _
        byref as PriorityQueue( of( TType ) )
      declare sub resize( as uinteger )
      
      as QueueElement( of( TType ) ) ptr _elements( any )
      as uinteger _
        _size, _
        _initialSize, _
        _lowerBound
      as integer _count
      as Collections.PriorityOrder _priorityOrder
  end type
  
  implement_auto_ptr( of( PriorityQueue( __tcar__( TType ) ) ) )
  
  /'
    Note that the default priority order is set to 'Descending'
    since this property is usually understood as 'the higher
    the value, the higher the priority'
  '/
  constructor PriorityQueue( of( TType ) )()
    constructor( 32, Collections.PriorityOrder.Descending )
  end constructor
  
  constructor PriorityQueue( of( TType ) )( aSize as integer )
    constructor( aSize, Collections.PriorityOrder.Descending )
  end constructor
  
  constructor PriorityQueue( of( TType ) )( _
    aPriority as Collections.PriorityOrder )
    
    constructor( 32, aPriority )
  end constructor
  
  constructor PriorityQueue( of( TType ) )( aSize as integer, aPriority as Collections.PriorityOrder )
    /'
      Primary constructor.
      
      Note that we're using a 1-based array instead of a more common
      0-based one. This makes a lot of things easier down the road,
      especially adding an element: since we're declaring the	element
      count as unsigned, leaving a bit of space at the root of the
      heap we don't have to check for underflow conditions during the
      sifting.
    '/
    _size = iif( aSize < 32, 32, aSize )
    _priorityOrder = aPriority
    
    redim _elements( 1 to _size )
    
    _count = 0
    _initialSize = _size
    _lowerBound = 1
  end constructor
  
  destructor PriorityQueue( of( TType ) )()
    dispose()
  end destructor
  
  sub PriorityQueue( of( TType ) ).dispose()
    for i as integer = 1 to _size
      if( _elements( i ) <> 0 ) then
        delete( _elements( i ) )
        _elements( i ) = 0
      end if
    next
  end sub
  
  property PriorityQueue( of( TType ) ).size() as integer
    return( _size )
  end property
  
  property PriorityQueue( of( TType ) ).count() as integer
    return( _count )
  end property
  
  property PriorityQueue( of( TType ) ).top() as TType ptr
    /'
      Peeks the top value field of the root of the heap, without removing it.
      It will return a null pointer if the heap is empty.
    '/
    if( _count > 0 ) then
      return( _elements( 1 )->value )
    else
      return( 0 )
    end if
  end property
  
  function PriorityQueue( of( TType ) ).clear() byref as PriorityQueue( of( TType ) )
    dispose()
    
    _size = _initialSize
    
    redim _elements( 1 to _size )
    
    _count = 0
    _lowerBound = 1
    
    return( this )
  end function
  
  /'
    Resizes the internal array used as the heap.
    
    The algorithm works like the ones from the Array and List 
    collections. See the implementation on the Array collections for
    details.
  '/
  sub PriorityQueue( of( TType ) ).resize( newSize as uinteger )
    newSize = iif( newSize < _initialSize, _initialSize, newSize )
    
    _size = newSize
    
    _lowerBound = _size - _initialSize - ( _initialSize shr 1 )
    _lowerBound = iif( _lowerBound < _initialSize, 1, _lowerBound )
    
    redim preserve _elements( 1 to _size )
  end sub
  
  /'
    Enqueues (adds) an element to the tail of the heap.
    
    Whenever an element is added to a binary heap, the heap has to be
    rebalanced (a process known as 'sifting') to leave it in a valid
    state. The procedure starts at the tail and proceeds towards the
    root.
  '/
  function PriorityQueue( of( TType ) ).enqueueElement( _
      anElement as QueueElement( of( TType ) ) ptr ) _
    byref as PriorityQueue( of( TType ) )
    
    '' Increment the number of elements in the heap
    _count += 1
    
    '' Resize the internal heap if needed
    if( _count > _size - _initialSize shr 1 ) then
      resize( _size + _initialSize )
    end if
    
    '' Set the current element position to the tail of the heap
    dim as uinteger elementPosition = _count
    
    _elements( elementPosition ) = anElement
    
    '' The parent position of this element
    dim as uinteger parentPosition
    
    '' Flag to end the sifting loop if appropriate
    dim as boolean done
    
    /'
      Sift the heap until the enqueued element reaches its correct
      position or it bubbles all the way to the root of the heap.
      
      The parent position of the considered element can be computed
      as the considered element position \ 2 in a 1-based array.
    '/
    do
      '' Assume that the element is at its correct place
      done = true
      
      '' Compute position of parent
      parentPosition = elementPosition shr 1
      
      /'
        If the element has a parent, see if we need to swap the considered 
        element with its parent, given the priority order.
      '/
      if( parentPosition > 0 ) then
        dim as boolean needSwap = iif( _
            _priorityOrder = Collections.PriorityOrder.Ascending, _
              iif( _
                *_elements( elementPosition ) < _
                *_elements( parentPosition ), _
                true, false ), _
              iif( _
                *_elements( elementPosition ) > _
                *_elements( parentPosition ), _
                true, false ) )
        
        /'
          Swap the considered element with its parent and update the
          element's position to that of its parent to continue the
          sifting.
        '/
        if( needSwap ) then
          swap _elements( elementPosition ), _elements( parentPosition )
          
          elementPosition = parentPosition
          
          ''Sifting has not finished yet
          done = false
        end if
      end if
    loop until( done )
    
    return( this )
  end function
  
  function PriorityQueue( of( TType ) ).enqueue( _
      aPriority as integer, aValue as TType ptr ) _
    byref as PriorityQueue( of( TType ) )
    
    return( enqueueElement( new QueueElement( of( TType ) )( aPriority, aValue, true ) ) )
  end function
  
  function PriorityQueue( of( TType ) ).enqueue( _
      aPriority as integer, _
      byref aValue as const TType ) _
    byref as PriorityQueue( of( TType ) )
    
    return( enqueueElement( new QueueElement( of( TType ) )( _
        aPriority, cptr( TType ptr, @aValue ), false ) ) )
  end function
  
  /'
    Dequeues (removes) an element from the heap
    
    The heap has to be sifted also when removing elements, this time
    starting from the head (the root) element and proceeding towards
    the tail.
  '/
  function PriorityQueue( of( TType ) ).dequeue() as TType ptr
    dim as TType ptr elementValue = 0
    
    if( _count > 0 ) then
      '' Fetch the value at the root of the heap
      elementValue = _elements( 1 )->detach()
      
      '' Delete the QueueElement associated with it
      delete( _elements( 1 ) )
      _elements( 1 ) = 0
      
      '' Then, bring the element on the tail of the heap to the root
      swap _elements( 1 ), _elements( _count )
      
      '' Decrement the element count to account for the removed element
      _count -= 1
      
      '' Resize the internal heap if needed
      if( _count < _lowerBound ) then
        resize( _size - _initialSize )
      end if
      
      /'
        Here, the element at the root of the heap is successively checked
        against its two siblings to swap their positions if necessary.
        
        If there are still elements remaining in the heap, we need to reorder
        them to account for the removal of it's previous root element. The
        sifting direction depends on how the class was instantiated (in 
        'Ascending' or 'Descending' priority order).
      
        The current element position is set at the root of the heap to start
        the sifting.
      '/
      dim as uinteger elementPosition = 1
      
      '' The new position the element could potentially take
      dim as uinteger newPosition
      
      '' Flag to end the sifting loop if appropriate
      dim as boolean done
      
      do while( _count > 0 andAlso not done )
        ''Assume the element is at the correct position already
        done = true
        
        '' Compute the positions of the two siblings of the element
        dim as uinteger _
          child1Position = elementPosition shl 1, _
          child2Position = child1Position + 1
        
        '' Check if the element has one or two siblings
        if( child1Position <= _count ) then
          if( child2Position <= _count ) then
            /'
              The element has two siblings, see which of the two we need to swap
              according to the desired priority order, and record its position.
            '/
            newPosition = iif( _
              _priorityOrder = Collections.PriorityOrder.Ascending, _
              iif( _
                *_elements( child1Position ) < _
                *_elements( child2Position ), _
                child1Position, _
                child2Position ), _
              iif( _
                *_elements( child1Position ) > _
                *_elements( child2Position ), _
                child1Position, _
                child2Position ) )
          else
            '' Only one sibling left, always record its position
            newPosition = child1Position
          end if
          
          '' Check to see if we need to swap the element with its sibling
          dim as boolean needSwap = iif( _
              _priorityOrder = Collections.PriorityOrder.Ascending, _
              iif( _
                *_elements( elementPosition ) > _
                *_elements( newPosition ), _
                true, _
                false ), _
              iif( _
                *_elements( elementPosition ) < _
                *_elements( newPosition ), _
                true, _
                false ) )
          
          /'
            If needed, swap the considered element's position with the new position computed
            above, and set the current element position to the new one to continue the sifting
            from there.
          '/
          if( needSwap ) then
            swap _elements( elementPosition ), _elements( newPosition )
            
            elementPosition = newPosition
            
            '' Sifting is not done yet
            done = false
          end if
        end if
      loop
    end if
    
    return( elementValue )
  end function
  
  function PriorityQueue( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as PriorityQueue( of( TType ) )
    
    for i as integer = 1 to _count
      anAction.invoke( _elements( i )->value )
    next
    
    return( this )
  end function
  
  function PriorityQueue( of( TType ) ).forEach( _
      anAction as ActionFunc( of( TType ) ), param as any ptr = 0 ) _
    byref as PriorityQueue( of( TType ) )
    
    for i as integer = 1 to _count
      anAction( i, _elements( i )->value, param )
    next
    
    return( this )
  end function
  
  function PriorityQueue( of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anAction as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as PriorityQueue( of( TType ) )
    
    for i as integer = 1 to _count
      if( aPredicate( i, _elements( i )->value, aPredicateParam ) ) then
        anAction( i, _elements( i )->value, anActionParam )
      end if
    next
    
    return( this )
  end function
  
  function PriorityQueue( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as PriorityQueue( of( TType ) )
    
    for i as integer = 1 to count
      if( aPredicate.eval( _elements( i )->value ) ) then
        anAction.invoke( _elements( i )->value )
      end if
    next
    
    return( this )
  end function
  
  operator = ( lhs as PriorityQueue( of( TType ) ), rhs as PriorityQueue( of( TType ) ) ) as integer
    return( @lhs = @rhs )
  end operator
  
  operator <> ( lhs as PriorityQueue( of( TType ) ), rhs as PriorityQueue( of( TType ) ) ) as integer
    return( @lhs <> @rhs )
  end operator
#endmacro

#endif
