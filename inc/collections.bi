#ifndef __FBFW_COLLECTIONS__
#define __FBFW_COLLECTIONS__

#include once "crt.bi"
#include once "namespace.bi"

/'
  Framework for strongly-typed templated collections.
  
  10/30/2019
    Added support for variadic macros (Freebasic >= 1.07.1).
  
  10/26/2019
    Initial version.
  
  TODO:
    - Optimize code generation size. This might have a slight impact
      on performance but a MAJOR impact on executable size and
      compile times.
    - Add support for disposing callbacks for all collections.
    - Implement the selectAll() method for all collections where it
      will make sense.
    - Implement iterators.
'/
#include once "templates.bi"

__include__( __FBFW_COLLECTIONS_FOLDER__, TKeys.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TPredicate.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TAction.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TKeyValuePair.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, ICollection.bi )

#include once "auto-ptr.bi"

/'
  The templated type itself expands into the current namespace,
  but this is reserved for future expansions, and to integrate
  your own collection code.
'/
namespace __FBFW_NS_COLLECTIONS__
  '' The priority order for Priority Queues
  enum PriorityOrder
    Ascending
    Descending
  end enum
  
  '' For Unordered maps
  const as long INVALID_HANDLE = -1
end namespace

/'
  Standard collections
'/
__include__( __FBFW_COLLECTIONS_FOLDER__, TArray.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TList.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TLinkedList.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TDictionary.bi )
__include__( __FBFW_COLLECTIONS_FOLDER__, TPriorityQueue.bi )
'' TODO: refactor these two collections
'__include__( __FBFW_COLLECTIONS_FOLDER__, TUnorderedMap.bi )
'__include__( __FBFW_COLLECTIONS_FOLDER__, TStack.bi )

#endif
