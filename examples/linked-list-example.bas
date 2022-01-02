#include once "../inc/collections.bi"
#include once "../common/person.bi"

/'
  Linked list example usage
'/
template( LinkedList, of( Person ) )

#include once "../common/person-predicates.bi"
#include once "../common/person-actions.bi"

scope
  var _
    p1 = Person( "Person 1", 1 ), _
    p2 = Person( "Person 2", 2 ), _
    aLinkedList = LinkedList( of( Person ) )()
  
  with aLinkedList
    .addFirst( new Person( "Paul Doe", 37 ) )
    .addFirst( new Person( "Janet Cabral", 31 ) )
    .addFirst( new Person( "Shaiel Lindt Cabral", 10 ) )
    .addFirst( p1 )
    .addFirst( p2 )
  
    .removefirst()
  end with
  
  aLinkedList.forEach( PersonsBelowAge( 20 ), SetAgeTo( -4 ) )
  
  /'
    And this is how one iterates a LinkedList from first to last node. To
    iterate the list backwards, the code is similar:
    
    aNode = aLinkedList.last
    
    for item as integer = 0 to aLinkedList.count - 1
      
      /' ... '/
      
      aNode = aNode->backward
    next
    
  '/
  var aNode = aLinkedList.first
  
  for item as integer = 0 to aLinkedList.count - 1
    ? *aNode->item
    
    aNode = aNode->forward
  next
  
  aLinkedList.clear()
end scope

sleep()
