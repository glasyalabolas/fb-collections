#ifndef __FBFW_COLLECTIONS_ICOLLECTION__
#define __FBFW_COLLECTIONS_ICOLLECTION__

/'
  This one is required for keyed collections. Mangles the name of the
  template appropriately so that the base class for a keyed collection
  can be properly templated.
'/
#define ofKey( TTemplate, TKey ) TTemplate##__##TKey

#define Collection( TType ) __T__##ICollection##__##TType

#macro template_collection( TCollection, TType... )
  #ifndef __T__##ICollection##__##TType
  
  '' Base class for Collections
  type Collection( of( TType ) ) extends Object
    declare virtual destructor()
    
    declare virtual property size() as integer
    declare virtual property count() as integer
    
    declare virtual function clear() byref as Collection( of( TType ) )
    declare virtual function forEach( as Action( of( TType ) ) ) byref as Collection( of( TType ) )
    declare virtual function forEach( as ActionFunc( of( TType ) ), as any ptr = 0 ) _
      byref as Collection( of( TType ) )
    declare virtual function forEach( as Predicate( of( TType ) ), as Action( of( TType ) ) ) _
      byref as Collection( of( TType ) )
    declare virtual function forEach( _
        as PredicateFunc( of( TType ) ), as ActionFunc( of( TType ) ), as any ptr = 0, as any ptr = 0 ) _
      byref as Collection( of( TType ) )
  end type
  
  destructor Collection( of( TType ) )() export
  end destructor
  
  property Collection( of( TType ) ).size() as integer export
    return( count )
  end property
  
  property Collection( of( TType ) ).count() as integer export
    return( 0 )
  end property
  
  function Collection( of( TType ) ).clear() byref as Collection( of( TType ) ) export
    return( this )
  end function
  
  function Collection( of( TType ) ).forEach( anAction as Action( of( TType ) ) ) _
    byref as Collection( of( TType ) ) export
    
    return( this )
  end function
  
  function Collection( of( TType ) ).forEach( _
      anAction as ActionFunc( of( TType ) ), anActionParam as any ptr = 0 ) _
    byref as Collection( of( TType ) ) export
    
    return( this )
  end function
  
  function Collection( of( TType ) ).forEach( _
      aPredicate as Predicate( of( TType ) ), anAction as Action( of( TType ) ) ) _
    byref as Collection( of( TType ) ) export
    
    return( this )
  end function
  
  function Collection( of( TType ) ).forEach( _
      aPredicate as PredicateFunc( of( TType ) ), anActionFunc as ActionFunc( of( TType ) ), _
      aPredicateParam as any ptr = 0, anActionParam as any ptr = 0 ) _
    byref as Collection( of( TType ) ) export
    
    return( this )
  end function
  
  #endif
#endmacro

#endif
