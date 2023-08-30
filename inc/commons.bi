#ifndef __FBFW_COMMONS_BI__
#define __FBFW_COMMONS_BI__

#include once "namespace.bi"

#define __FBFW_FOLDER__

#define __fbfw_str__( a ) #a
#define __fbfw_conc__( a, b ) ##a##b
#define __fbfw_inc__( p, f ) __fbfw_str__( __fbfw_conc__( p, f ) )

#macro __include__( p, f ) _
  #include once __fbfw_inc__( p, f )
#endmacro

#define __FBFW_AUTO_PTR_FOLDER__ auto-ptr/
#define __FBFW_COLLECTIONS_FOLDER__ collections/

namespace __FBFW_NS__
  const as string _
    stCr = chr( 13 ), _
    stLf = chr( 10 ), _
    stCrLf = chr( 13, 10 ), _
    stTab = chr( 9 ), _
    stVerticalTab = chr( 11 ), _
    stSpace = chr( 32 ), _
    stBackspace = chr( 8 ), _
    stFormFeed = chr( 12 )
end namespace

#endif
