#ifndef __FBFW_COLLECTIONS__PREDICATE__
#define __FBFW_COLLECTIONS__PREDICATE__

'' Template for Predicates
#define Predicate( TType ) __T__##IPredicate##__##TType
#define PredicateFunc( TType ) __T__##PredicateFunc##__##TType

#macro template_predicate( TType )
  #ifndef __T__##IPredicate##__##TType
  
  type Predicate( of( TType ) ) extends Object
    declare virtual destructor()
    
    declare abstract function eval( as TType ptr ) as boolean
    
    '' Set by the 'forEach' methods
    as integer indexOf
  end type
  
  destructor Predicate( of( TType ) )() export
  end destructor
  
  #endif
  
  #ifndef __T__##PredicateFunc##__##TType
  
  type as function( as integer, as TType ptr, as any ptr = 0 ) as boolean _
    __T__##PredicateFunc##__##TType
  
  #endif
#endmacro

#endif
