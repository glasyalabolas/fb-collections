#ifndef __FBFW_COMMONS_BI__
#define __FBFW_COMMONS_BI__

#include once "namespace.bi"

'#define __FBFW_FOLDER__ fbfw/
#define __FBFW_FOLDER__

#define __fbfw_str__( a ) #a
#define __fbfw_conc__( a, b ) ##a##b
#define __fbfw_inc__( p, f ) __fbfw_str__( __fbfw_conc__( p, f ) )

#macro __include__( p, f ) _
  #include once __fbfw_inc__( p, f )
#endmacro

#define __FBFW_AUTO_PTR_FOLDER__ auto-ptr/
#define __FBFW_COLLECTIONS_FOLDER__ collections/
#define __FBFW_DEBUG_FOLDER__ debug/
#define __FBFW_DISPLAY_FOLDER__ drawing/
#define __FBFW_DRAWING_FOLDER__ drawing/
#define __FBFW_EASINGS_FOLDER__ easings/
#define __FBFW_ENCODINGS_FOLDER__ encodings/
#define __FBFW_EVENTS_FOLDER__ events/
#define __FBFW_GRAPHICS_FOLDER__ graphics/
#define __FBFW_INTERACTION_FOLDER__ interaction/
#define __FBFW_MATH_FOLDER__ math/
#define __FBFW_RANDOMIZATION_FOLDER__ randomization/
#define __FBFW_SUPPORT_FOLDER__ support/
#define __FBFW_TASKS_FOLDER__ tasks/
#define __FBFW_THREADING_FOLDER__ threading/
#define __FBFW_WINDOWING_FOLDER__ windowing/
#define __FBFW_XML_FOLDER__ xml/

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
