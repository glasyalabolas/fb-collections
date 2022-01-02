#ifndef __FBFW_AUTO_PTR__
#define __FBFW_AUTO_PTR__

/'
  Templating framework for Auto_ptr pointers.
  
  An auto_ptr is a kind of 'scoped' pointer, that is, a pointer that
  gets automatically collected when it goes out of scope (like a
  normal variable). This is implemented as a class that aggregates the
  pointer in question, and acts as a proxy for it.
  
  The primary usage for auto_ptrs is to represent collections: since
  making copies of them is not always possible (nor practical), these
  pointers are a compromise: you can use them in expressions as proxies
  for the collections they aggregate, without the need to make unneeded
  copying nor having to implement copy constructors and assignment
  operators on the objects they hold.
'/
#define auto_ptr( TType ) __T__##Auto_ptr##__##TType##__

#macro declare_auto_ptr( TType )
  '' Forward declare the type that the auto_ptr aggregates.
  #ifndef __##TType
    type as TType __##TType
  #endif
  
  /'
    The declaration for the auto_ptr template is separated from the
    implementation to allow classes that implement methods that return
    auto_ptrs to be created. Otherwise, you couldn't do it because the
    class you're declaring and implementing isn't yet complete, so you
    need to forward declare it (see above). Note that we can't forward
    declare the auto_ptr because, to be able to return them, we need
    to have at least the constructor declared.
    
    Generally this type of pointer is returned by collections, to allow
    them to return results from operations also as collections (such as
    selectAll(), findAll() and the like). Having them return auto_ptrs
    allows for ephimeral expressions such as this:
    
    aList.selectAll( aPredicate() )->forEach( anAction() )
    
    That is, we select the items from a collection that satisfy a certain
    predicate and apply some operation on them. After the expression is
    evaluated, the auto_ptr that contains the results of the selectAll()
    operation immediately goes out of scope and is deleted, avoiding the
    memory leak that would result with raw pointers in such an expression.
  '/
  
  #ifndef __T__##Auto_ptr##__##TType##__##decl_start
  
  type Auto_ptr( of( TType ) )
    public:
      declare constructor( as __##TType ptr )
      declare constructor( as Auto_ptr( of( TType ) ) )
      declare destructor()
      
      declare operator cast() as __##TType ptr
      declare operator cast() byref as __##TType
      
    private:
      declare constructor()
      declare operator let( as Auto_ptr( of( TType ) ) )
      
      as __##TType ptr _ptr
      as boolean _owner
  end type
  
  /'
    Flags that the declaration is completed. The implementing macro
    will use this symbol to bracket the type declaration.
  '/
  #define __T__##Auto_ptr##__##TType##__##decl_start
  
  #endif
#endmacro

/'
  The rest of the implementation for the auto_ptr. Generally, when
  you're defining a type (or a template for a type) you'll do it
  like this:
  
  declare_auto_ptr( of( <Type> ) )
  
  type _
    <Type>
    
    /' ... '/
    
    declare function _
      getSomeResults() as auto_ptr( of( <Type> ) )
  end type
  
  implement_auto_ptr( of( <Type> ) )
  
  That way, we can effectively return auto_ptrs from the type
  being defined (otherwise we'll have somewhat of a chicken-egg
  problem with the type it aggregates). This scheme is used by
  collections to return auto_ptrs to themselves.
  
  Definitely not compiler-friendly stuff. However, the definition
  is tiny so hopefully it won't have a major impact on performance.
'/
#macro implement_auto_ptr( TType )
  #if   defined( __T__##Auto_ptr##__##TType##__##decl_start ) andAlso _
    not defined( __T__##Auto_ptr##__##TType##__##_decl_end )
  
  '' Default constructor is disabled
  constructor Auto_ptr( of( TType ) )() : end constructor
  
  /'
    Note the semantics of the copy constructor: whenever an
    instance of an auto_ptr is passed to it, the current instance 
    *takes ownership* of the pointer from the other instance. 
    Thus, while both of them refer to the same pointer, only one of 
    them (the one that was copied) will collect it. If the first
    instance (the one that was copied) is out-scoped, then it will
    delete itself but **NOT** the pointer it aggregates, since its
    ownership was taken by another instance.
  '/
  constructor Auto_ptr( of( TType ) )( rhs as Auto_ptr( of( TType ) ) )
    _ptr = rhs._ptr
    _owner = true
    rhs._owner = false
  end constructor
  
  /'
    And this is the constructor that would be used when, for
    example, returning an auto_ptr from a method/function:
    
    function _
      getResults() _
      as auto_ptr( of( <Type> ) )
      
      .....
      
      return( auto_ptr( of( <Collection>( of( <Type> ) ) ) ) )
    end function
  '/
  constructor Auto_ptr( of( TType ) )( aPtr as __##TType ptr )
    _ptr = aPtr
    _owner = true
  end constructor
  
  destructor Auto_ptr( of( TType ) )()
    if( _owner ) then
      delete( _ptr )
    end if
  end destructor
  
  operator Auto_ptr( of( TType ) ).let( rhs as Auto_ptr( of( TType ) ) )
  end operator
  
  operator Auto_ptr( of( TType ) ).cast() as TType ptr
    return( _ptr )
  end operator
  
  operator Auto_ptr( of( TType ) ).cast() byref as TType
    return( *_ptr )
  end operator
  
  operator -> ( rhs as Auto_ptr( of( TType ) ) ) byref as TType
    return( cast( TType, rhs ) )
  end operator
  
  operator * ( rhs as Auto_ptr( of( TType ) ) ) byref as TType
    return( cast( TType, rhs ) )
  end operator
  
  /'
    Flags that the declaration of the Auto_ptr is finished. 
    
    This effectively brackets the declaration and prevents it from
    being declared again if the auto_ptr is already templated (as
    is frequently the case with collections).
    
    But this also allows us to template collections inside namespaces, 
    since we can't #undef symbols within them.
  '/
  #define __T__##Auto_ptr##__##TType##__##_decl_end
  
  #endif
#endmacro

/'
  If the type/class that the auto_ptr aggregates is already
  defined we can simply use 'template( Auto_ptr( of( <Type> ) )'.
  This is the template macro for it.
'/
#macro template_auto_ptr( TCollection, TType... )
  declare_auto_ptr( __tcar__( TType ) )
  implement_auto_ptr( __tcar__( TType ) )
#endmacro

#endif
