#include once "fbfw/collections.bi"

/'
  Example showing how templating works with namespaces
'/
namespace My
  type Foo
    as integer bar
  end type
  
  '' This templated queue will be in the 'My' namespace
  template( PriorityQueue, of( Foo ) )
end namespace

/'
  And of course, if you've templated a collection within a namespace,
  you'll have to qualify (or import the namespace).
'/
var aList = My.PriorityQueue( of( Foo ) )

/'
  Templating from outside a namespace is a little trickier, since you can't
  qualify the symbol. However, with this little trick you can do it: simply
  type alias the class you want templated, and use the alias to template it.
'/
type as My.Foo My_Foo

/'
  But of course you'll have to use the unqualified alias instead of the real
  name. This is quite unfortunate, but hopefully it will be solved in future
  releases of FreeBasic.
'/
template( Dictionary, of( string ), of( My_Foo ) )
