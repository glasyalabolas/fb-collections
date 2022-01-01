#ifndef __FBFW_COLLECTIONS_ACTION__
#define __FBFW_COLLECTIONS_ACTION__

/'
  Template for Actions
'/
#define Action( TType ) __T__##IAction##__##TType
#define ActionFunc( TType ) __T__##ActionFunc##__##TType

#macro template_action( TType )
  #ifndef __T__##IAction##__##TType
  
  type Action( of( TType ) ) extends Object
    declare virtual destructor()
    
    declare abstract sub invoke( as TType ptr )
    
    as integer indexOf
  end type
  
  destructor Action( of( TType ) )() export
  end destructor
  
  #endif
  
  #ifndef __T__##ActionFunc##__##TType
  
  type as sub( as integer, as TType ptr, as any ptr = 0 ) _
    __T__##ActionFunc##__##TType
  
  #endif
#endmacro

#endif
