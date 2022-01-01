#ifndef __FBFW_TEMPLATES__
#define __FBFW_TEMPLATES__

#include once "commons.bi"

/'
  Templating framework for FreeBasic versions >= 1.07.1.
  
  10/30/2019
    Decoupled the templating scheme from collections and added support
    for variadic macros. The interface is streamlined now, and all
    templating can be done using the 'template' macro (even user-defined
    ones).
  
  10/28/2019
    Initial version.
'/

/'
  Not required, just syntactic sugar to make the code (especially those
  within templating macros) more readable.
'/
#define of( TType ) ##TType

/'
  Very useful #defines to treat the variadic argument list of a macro as
  a Lisp-like list.
  
  For those unfamiliar with them, 'car' returns the first argument of a
  list, and 'cdr' returns all the arguments BUT the first. Using them,
  you can select any argument from a list:
  
  car( foo, bar, baz ) = ( foo )
  cdr( foo, bar, baz ) = ( bar, baz )
  car( cdr( foo, bar, baz ) ) = ( bar )
  cdr( cdr( foo, bar, baz ) ) = ( baz )
  
  And so on and so forth. For those that know Logo instead, they
  are equivalent to the 'butlast' and 'butfirst' statements,
  respectively (also provided below, since they're more 'BASIC' like
  than their Lisp counterparts).
  
  The 'str_car' and 'str_cdr' just stringize their arguments. Needed
  because so the preprocessor evals them (ie you can't do '#car( args )').
  
  These definitions are used to parse the variadic argument of a
  variadic macro.
'/
#define __tcar__( a, b... ) a
#define __tcdr__( a, b... ) b
#define __tbutlast__( a, b... ) a
#define __tbutfirst__( a, b... ) b
#define __s_tcar__( a, b... ) #a
#define __s_tcdr__( a, b... ) #b
#define __s_tbutlast__( a, b... ) #a
#define __s_tbutfirst__( a, b... ) #b

'' Determines whether or not 'arg' exists
#define __va_has_arg__( arg ) ( len( arg ) > 0 )

'' Concatenates two lists of symbols
#define __conc__( a, b... ) a##b

/'
  Creates a #define that mangles the name given to that of a templated
  symbol. Used when creating templates, so instead of having to mangle
  the name yourself and provide the #define with the intended name, you
  simply invoke this macro and it creates it for you. 
  
  Basically:
  
  #macro template_<mytypename>( args )
    templateFor( <mytypename> )
    
    '' And now you can use the symbol directly
    
    type <mytypename>( of( <type> ) )
      '' ...
    end type
  #endmacro
  
  See the implementations for the collections for more details.
'/
#macro templateFor( TTemplate )
  #ifndef TTemplate
    #define TTemplate( TKey, TType... ) _
      __conc__( __T, __conc__( __##TTemplate, _
        __conc__( __conc__( __, TKey ), _
          __conc__( __, TType ) ) ) )
  #endif
#endmacro

/'
  Expands the templating macro for a non-keyed type. Needed to avoid
  recursive macros (same as the one below).
'/
#macro template_type_non_keyed( TTemplate, TType... )
  #ifndef __T__##TTemplate##__##TType##__
    template_##TTemplate( TTemplate, TType )
  #endif
#endmacro

/'
  Expands the templating macro but for keyed types (ie types that may
  index into a collection by key, or a keyed collection itself).
'/
#macro template_type_keyed( TTemplate, TKey, TType... )
  #ifndef __T__##TTemplate##__##TKey##__##TType
    template_##TTemplate( TTemplate, TKey, TType )
  #endif
#endmacro

/'
  The topmost templating macro.
  
  This can be used in fact to template any type that is defined
  within macros that have the following signatures:
  
  For non-keyed templates:
  
    template_<templateName>( TCollection, TType... )
  
  For keyed templates (note also that this applies to 'generic'
  templates; you'll just have to parse the 'TType' argument):
  
    template_<templateName>( TCollection, TKey, TType... )
  
  Where <templateName> is the name of the templated type. Of course,
  parameters can take any name you wish, it's only the signature
  that counts. 
'/
#macro template( TTemplate, T... )
  #if( __va_has_arg__( __s_tcar__( __tcdr__( T ) ) ) )
    template_type_keyed( _
      TTemplate, _
      __tcar__( T ), _
      __tcar__( __tcdr__( T ) ) )
  #else
    template_type_non_keyed( TTemplate, T )
  #endif
#endmacro

#endif
