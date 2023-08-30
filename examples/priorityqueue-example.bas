#include once "../inc/collections.bi"
#include once "../common/person.bi"

template( PriorityQueue, of Person )

#include once "../common/person-predicates.bi"
#include once "../common/person-actions.bi"

/'
  Some basic example usage for Priority Queues.
  
  Priority Queues do have some quirks to their usage, explained in the
  example below. If the explanation doesn't make sense, consider that
  collections always return *pointers* to the elements they contain and
  not *references* to them.
'/
? "** Wrong usage **"

scope
  var aQueue = PriorityQueue( of Person )( Collections.PriorityOrder.Ascending )
  
  '' Note that these will be added by reference to the queue
  var _
    p1 = Person( "Paul Doe", 37 ), _
    p2 = Person( "Shaiel Doe", 12 ), _
    p3 = Person( "Janet Doe", 32 )
  
  /'
    While you can indeed add both types of elements to priority queues
    (by reference and by pointer) as with any collection, and they will
    get collected when you 'clear()' the queue or it goes out of scope,
    when you're dequeuing you will have a problem, because you can't
    discriminate whether or not you should dispose of the dequeued
    element. Returning an auto_ptr is also not a possibility (because 
    this may not be what you intend), so this example will indeed cause
    a leak.
    
    Bottom line: ALWAYS add elements to a queue either by pointer or
    by reference, but NEVER both.
  '/
  aQueue _
    .enqueue( 3, new Person( "Person 1", 3 ) ) _
    .enqueue( 7, new Person( "Person 2", 7 ) ) _
    .clear() _
    .enqueue( 3, new Person( "Person 3", 3 ) ) _
    .enqueue( 7, new Person( "Person 4", 7 ) ) _
    .enqueue( p1.age, p1 ) _
    .enqueue( p2.age, p2 ) _
    .enqueue( p3.age, p3 )
    
  for items as integer = 0 to aQueue.count - 1
    ? *( aQueue.dequeue() )
  next
end scope

/'
  And here you'll notice that both 'Person 3' and 'Person 4' didn't
  got destroyed, causing a leak (see above).
'/

/'
  This is the correct, intended usage: we will pass all elements by
  pointer to the queue, and delete them after we retrieved and used
  them.
  We could also pass references to elements and not delete them if
  another class (such as another collection) owns them.
'/
?
? "** Correct usage **"

scope
  var aQueue = PriorityQueue( of Person )( Collections.PriorityOrder.Descending )
  
  var _
    p1 = new Person( "Paul Doe", 37 ), _
    p2 = new Person( "Shaiel Doe", 12 ), _
    p3 = new Person( "Janet Doe", 32 )
  
  aQueue _
    .enqueue( 3, new Person( "Person 1", 3 ) ) _
    .enqueue( 7, new Person( "Person 2", 7 ) ) _
    .enqueue( p1->age, p1 ) _
    .enqueue( p2->age, p2 ) _
    .enqueue( p3->age, p3 ) _
    .forEach( SetAgeTo( -4 ) )
  
  for items as integer = 0 to aQueue.count - 1
    var item = aQueue.dequeue()
    
    ? *item
    
    delete( item )
  next
end scope

sleep()
