#ifndef __FBFW_COLLECTIONS_LINKED_LIST__
#define __FBFW_COLLECTIONS_LINKED_LIST__

#macro template_linkedlist( TCollection, TType... )
  templateFor( LinkedListNode )
  templateFor( LinkedList )
  
  template_predicate( __tcar__( TType ) )
  template_action( __tcar__( TType ) )
  template_collection( TCollection, __tcar__( TType ) )
  declare_auto_ptr( of( LinkedList( __tcar__( TType ) ) ) )
  
  '' Represents a node for the Linked List class
  #ifndef __T__##LinkedListNode##__##TType##__
  
  type LinkedListNode( of( TType ) )
    public:
      declare constructor( as TType ptr, as boolean )
      declare destructor()
      
      '' The item associated with this node
      as TType ptr item
      
      as LinkedListNode( of( TType ) ) ptr _
        forward, backward
      
    private:
      declare constructor()
      declare constructor( as LinkedListNode( of( TType ) ) )
      declare operator let( as LinkedListNode( of( TType ) ) )
      
      as boolean _needsDisposing
  end type
  
  constructor LinkedListNode( of( TType ) )()
  end constructor
  
  constructor LinkedListNode( of( TType ) )( anItem as TType ptr, needsDisposing as boolean )
    item = anItem
    _needsDisposing = needsDisposing
  end constructor
  
  constructor LinkedListNode( of( TType ) )( rhs as LinkedListNode( of( TType ) ) )
  end constructor
  
  destructor LinkedListNode( of( TType ) )()
    if( _needsDisposing andAlso item <> 0 ) then
      delete( item )
    end if
  end destructor
  
  operator LinkedListNode( of( TType ) ).let( rhs as LinkedListNode( of( TType ) ) )
  end operator
  
  operator = ( lhs as LinkedListNode( of( TType ) ), rhs as LinkedListNode( of( TType ) ) ) as integer
    return( lhs.item = rhs.item )
  end operator
  
  #endif
  
  /'
    Represents a strongly-typed doubly-linked list.
    
    It allows for insertion/removal of elements either from the head of 
    the list or from the tail, and also allows first-to-last or last-to-first
    traversal. Thus, it can be used both as a queue/heap or as a stack, by 
    using the appropriate methods to add/remove elements from it.
  '/
  type LinkedList( of( TType ) ) extends Collection( of( TType ) )
    public:
      declare constructor()
      declare virtual destructor() override
      
      declare operator [] ( as integer ) as TType ptr
      
      declare property size() as integer override
      declare property count() as integer override
      declare property first() as LinkedListNode( of( TType ) ) ptr
      declare property last() as LinkedListNode( of( TType ) ) ptr
      declare property at( as integer ) as TType ptr
      
      declare function clear() byref as LinkedList( of( TType ) ) override
      
      declare function contains( as const TType ) as boolean
      declare function contains( as TType ptr ) as boolean
      declare function findNode( as const TType ) as LinkedListNode( of( TType ) ) ptr
      declare function findNode( as TType ptr ) as LinkedListNode( of( TType ) ) ptr
      declare function addBefore( as LinkedListNode( of( TType ) ) ptr, as TType ptr ) _
        as LinkedListNode( of( TType ) ) ptr 
      declare function addBefore( as LinkedListNode( of( TType ) ) ptr, byref as const TType ) _
        as LinkedListNode( of( TType ) ) ptr 
      declare function addAfter( _
          as LinkedListNode( of( TType ) ) ptr, as TType ptr ) _
        as LinkedListNode( of( TType ) ) ptr
      declare function addAfter( _
          as LinkedListNode( of( TType ) ) ptr, byref as const TType ) _
        as LinkedListNode( of( TType ) ) ptr
      declare function addFirst( as TType ptr ) as LinkedListNode( of( TType ) ) ptr
      declare function addFirst( byref as const TType ) as LinkedListNode( of( TType ) ) ptr
      declare function addLast( as TType ptr ) as LinkedListNode( of( TType ) ) ptr
      declare function addLast( byref as const TType ) as LinkedListNode( of( TType ) ) ptr
      declare function remove( as LinkedListNode( of( TType ) ) ptr ) _
        byref as LinkedList( of( TType ) )
      declare function removeItem( as LinkedListNode( of( TType ) ) ptr ) as TType ptr
      declare function removeFirst() byref as LinkedList( of( TType ) )
      declare function removeFirstItem() as TType ptr
      declare function removeLast() byref as LinkedList( of( TType ) )
      declare function removeLastItem() as TType ptr
      
      declare function forEach( as Action( of( TType ) ) ) _
        byref as LinkedList( of( TType ) ) override
      declare function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
        byref as LinkedList( of( TType ) ) override
      declare function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
        byref as LinkedList( of( TType ) ) override
      declare function forEach( _
          as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), as any ptr = 0, as any ptr = 0 ) _
        byref as LinkedList( of( TType ) ) override
      
    protected:
      declare constructor( as LinkedList( of( TType ) ) )
      declare operator let( as LinkedList( of( TType ) ) )
    
    private:
      declare sub dispose()
      
      declare function addElementBefore( _
          as LinkedListNode( of( TType ) ) ptr, as TType ptr, as boolean ) _
        as LinkedListNode( of( TType ) ) ptr
      declare function addElementAfter( _
          as LinkedListNode( of( TType ) ) ptr, as TType ptr, as boolean ) _
        as LinkedListNode( of( TType ) ) ptr
      declare function addElementFirst( as TType ptr, as boolean ) _
        as LinkedListNode( of( TType ) ) ptr
      declare function addElementLast( as TType ptr, as boolean ) _
        as LinkedListNode( of( TType ) ) ptr
      
      as LinkedListNode( of( TType ) ) ptr _
        _last, _first
      as integer _count
  end type
  
  implement_auto_ptr( of( LinkedList( __tcar__( TType ) ) ) )
  
  constructor LinkedList( of( TType ) )()
  end constructor
  
  constructor LinkedList( of( TType ) )( rhs as LinkedList( of( TType ) ) )
  end constructor
  
  operator LinkedList( of( TType ) ).let( rhs as LinkedList( of( TType ) ) )
  end operator
  
  destructor LinkedList( of( TType ) )()
    dispose()
  end destructor
  
  sub LinkedList( of( TType ) ).dispose()
    do while( _count > 0 )
      remove( _last )
    loop
  end sub
  
  operator LinkedList( of( TType ) ).[] ( index as integer ) as TType ptr
    var n = first
    
    for i as integer = 0 to index - 1
      n = n->forward
    next
    
    return( n->item )
  end operator
  
  property LinkedList( of( TType ) ).size() as integer
    return( _count )
  end property
  
  property LinkedList( of( TType ) ).count() as integer
    return( _count )
  end property
  
  '' Returns the first node in the list
  property LinkedList( of( TType ) ).first() as LinkedListNode( of( TType ) ) ptr
    return( _first )
  end property
  
  '' Returns the last node in the list
  property LinkedList( of( TType ) ).last() as LinkedListNode( of( TType ) ) ptr
    return( _last )
  end property
  
  '' Returns the value associated at the specified index
  property LinkedList( of( TType ) ).at( index as integer ) as TType ptr
    var n = _first
    
    dim as LinkedListNode( of( TType ) ) ptr node
    
    for i as integer = 0 to _count - 1
      if( i = index ) then
        node = n
        exit for
      end if
    next
    
    return( node->item )  
  end property
  
  function LinkedList( of( TType ) ).contains( anItem as const TType ) as boolean
    return( findNode( anItem ) <> 0 )
  end function
  
  function LinkedList( of( TType ) ).contains( anItem as TType ptr ) as boolean
    return( findNode( anItem ) <> 0 )
  end function
  
  /'
    Returns the node in the Linked List that contains the specified
    reference, if it exists. Otherwise returns a null pointer.
  '/
  function LinkedList( of( TType ) ).findNode( anItem as const TType ) _
    as LinkedListNode( of( TType ) ) ptr
    
    dim as LinkedListNode( of( TType ) ) ptr result
    
    var node = _first
    
    for i as integer = 0 to _count - 1
      if( cptr( TType ptr, @anItem ) = node->item ) then
        result = node
        exit for
      end if
      
      node = node->forward
    next
    
    return( result )
  end function
  
  function LinkedList( of( TType ) ).findNode( anItem as TType ptr ) _
    as LinkedListNode( of( TType ) ) ptr
    
    dim as LinkedListNode( of( TType ) ) ptr result
    
    var node = _first
    
    for i as integer = 0 to _count - 1
      if( anItem = node->item ) then
        result = node
        exit for
      end if
      
      node = node->forward
    next
    
    return( result )
  end function
  
  '' Clears the list
  function LinkedList( of( TType ) ).clear() byref as LinkedList( of( TType ) )
    dispose()
    
    _count = 0
    _first = 0
    _last = _first
    
    return( this )
  end function
  
  '' Inserts an item before the specified node.
  function LinkedList( of( TType ) ).addElementBefore( _
      aNode as LinkedListNode( of( TType ) ) ptr, anItem as TType ptr, needsDisposing as boolean ) _
    as LinkedListNode( of( TType ) ) ptr
    
    var newNode = new LinkedListNode( of( TType ) )( anItem, needsDisposing )
    
    newNode->backward = aNode->backward
    newNode->forward = aNode
    
    if( aNode->backward = 0 ) then
      _first = newNode
    else
      aNode->backward->forward = newNode
    end if
    
    _count += 1
    aNode->backward = newNode
    
    return( newNode )
  end function
  
  function LinkedList( of( TType ) ).addBefore( _
      aNode as LinkedListNode( of( TType ) ) ptr, anItem as TType ptr ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementBefore( aNode, anItem, true ) )
  end function
  
  function LinkedList( of( TType ) ).addBefore( _
      aNode as LinkedListNode( of( TType ) ) ptr, byref anItem as const TType ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementBefore( aNode, cptr( TType ptr, @anItem ), false ) )
  end function
  
  '' Inserts an item after the specified node.
  function LinkedList( of( TType ) ).addElementAfter( _
      aNode as LinkedListNode( of( TType ) ) ptr, anItem as TType ptr, needsDisposing as boolean ) _
    as LinkedListNode( of( TType ) ) ptr
    
    var newNode = new LinkedListNode( of( TType ) )( anItem, needsDisposing )
    
    newNode->backward = aNode
    newNode->forward = aNode->forward
    
    if( aNode->forward = 0 ) then
      _last = newNode
    else
      aNode->forward->backward = newNode
    end if
    
    _count += 1
    aNode->forward = newNode
    
    return( newNode )
  end function
  
  function LinkedList( of( TType ) ).addAfter( _
      aNode as LinkedListNode( of( TType ) ) ptr, anItem as TType ptr ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementAfter( aNode, anItem, true ) )
  end function
  
  function LinkedList( of( TType ) ).addAfter( _
      aNode as LinkedListNode( of( TType ) ) ptr, byref anItem as const TType ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementAfter( aNode, cptr( TType ptr, @anItem ), false ) )
  end function
  
  '' Inserts an item at the beginning of the list.
  function LinkedList( of( TType ) ).addElementFirst( _
      anItem as TType ptr, needsDisposing as boolean ) _
    as LinkedListNode( of( TType ) ) ptr
    
    if( _first = 0 ) then
      var newNode = new LinkedListNode( of( TType ) )( anItem, needsDisposing )
      
      _first = newNode
      _last = newNode
      
      newNode->backward = 0
      newNode->forward = 0
      
      _count += 1
      
      return( newNode )
    end if
    
    return( addElementBefore( _first, anItem, needsDisposing ) )
  end function
  
  function LinkedList( of( TType ) ).addFirst( anItem as TType ptr ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementFirst( anItem, true ) )
  end function
  
  function LinkedList( of( TType ) ).addFirst( byref anItem as const TType ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementFirst( cptr( TType ptr, @anItem ), false ) )
  end function
  
  '' Inserts an item at the end of the list.
  function LinkedList( of( TType ) ).addElementLast( anItem as TType ptr, needsDisposing as boolean ) _
    as LinkedListNode( of( TType ) ) ptr
    
    if( _last = 0 ) then
      return( addElementFirst( anItem, needsDisposing ) )
    end if
    
    return( addElementAfter( _last, anItem, needsDisposing ) )
  end function
  
  function LinkedList( of( TType ) ).addLast( anItem as TType ptr ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementLast( anItem, true ) )
  end function
  
  function LinkedList( of( TType ) ).addLast( byref anItem as const TType ) _
    as LinkedListNode( of( TType ) ) ptr
    
    return( addElementLast( cptr( TType ptr, @anItem ), false ) )
  end function
  
  '' Removes the specified node from the list
  function LinkedList( of( TType ) ).remove( node as LinkedListNode( of( TType ) ) ptr ) _
    byref as LinkedList( of( TType ) )
    
    if( node <> 0 andAlso _count > 0 ) then
      if( node->backward = 0 ) then
        _first = node->forward
      else
        node->backward->forward = node->forward
      end if
      
      if( node->forward = 0 ) then
        _last = node->backward
      else
        node->forward->backward = node->backward
      end if
      
      _count -= 1
      
      delete( node )
    end if
    
    return( this )
  end function
  
  function LinkedList( of( TType ) ).removeItem( node as LinkedListNode( of( TType ) ) ptr ) _
    as TType ptr
    
    dim as TType ptr result
    
    if( node <> 0 andAlso _count > 0 ) then
      if( node->backward = 0 ) then
        _first = node->forward
      else
        node->backward->forward = node->forward
      end if
      
      if( node->forward = 0 ) then
        _last = node->backward
      else
        node->forward->backward = node->backward
      end if
      
      _count -= 1
      
      result = node->item
      node->item = 0
      
      delete( node )
    end if
    
    return( result )
  end function
  
  '' Removes the first node on the list
  function LinkedList( of( TType ) ).removeFirst() byref as LinkedList( of( TType ) )
    return( remove( _first ) )
  end function
  
  function LinkedList( of( TType ) ).removeFirstItem() as TType ptr
    return( removeItem( _first ) )
  end function
  
  '' Removes the last node in the list
  function LinkedList( of( TType ) ).removeLast() byref as LinkedList( of( TType ) )
    return( remove( _last ) )
  end function
  
  function LinkedList( of( TType ) ).removeLastItem() as TType ptr
    return( removeItem( _last ) )
  end function
  
  function LinkedList( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as LinkedList( of( TType ) )
    
    var n = _first
    
    for i as integer = 0 to _count - 1
      anAction.invoke( n->item )
      n = n->forward
    next
    
    return( this )
  end function
  
  function LinkedList( of( TType ) ).forEach( anAction as ActionFunc( of( TType ) ), param as any ptr = 0 ) _
    byref as LinkedList( of( TType ) )
    
    var n = _first
    
    for i as integer = 0 to _count - 1
      anAction( i, n->item, param )
      n = n->forward
    next
    
    return( this )
  end function
  
  function LinkedList( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as LinkedList( of( TType ) )
    
    var n = _first
    
    for i as integer = 0 to _count - 1
      if( aPredicate.eval( n->item ) ) then
        anAction.invoke( n->item )
      end if
      
      n = n->forward
    next
    
    return( this )
  end function
  
  function LinkedList( of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anAction as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as LinkedList( of( TType ) )
    
    var n = _first
    
    for i as integer = 0 to _count - 1
      if( aPredicate( i, n->item, aPredicateParam ) ) then
        anAction( i, n->item, anActionParam )
      end if
      
      n = n->forward
    next
    
    return( this )
  end function
  
  operator = ( lhs as LinkedList( of( TType ) ), rhs as LinkedList( of( TType ) ) ) as integer
    return( @lhs = @rhs )
  end operator
  
  operator <> ( lhs as LinkedList( of( TType ) ), rhs as LinkedList( of( TType ) ) ) as integer
    return( @lhs <> @rhs )
  end operator
#endmacro

#endif
