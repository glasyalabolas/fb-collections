#include once "../inc/collections.bi"

/'
  Example showing how to use collections with abstract base
  classes/interfaces.
'/

'' Classic interface for the Command pattern
type ICommand extends Object
  declare virtual destructor()
  
  declare abstract sub execute()
end type

destructor ICommand() : end destructor

operator =( lhs as ICommand, rhs as ICommand ) as integer
  return( @lhs = @rhs )
end operator

/'
  Derive a Command that 'activates' a sensor
'/
type ActivateSensor extends ICommand
  declare constructor()
  declare destructor() override
  
  declare sub execute() override
end type

constructor ActivateSensor() : end constructor

destructor ActivateSensor() : end destructor

sub ActivateSensor.execute()
  ? "Sensor activated"
end sub

/'
  Derive a Command that 'engages' a clutch
'/
type EngageClutch extends ICommand
  declare constructor()
  declare destructor() override
  
  declare sub execute() override
end type

constructor EngageClutch() : end constructor

destructor EngageClutch() : end destructor

sub EngageClutch.execute()
  ? "Engaging clutch"
end sub

template( List, of( ICommand ) )

/'
  Note that the derived Action does indeed work transparently with
  interfaces too.
'/
type Execute extends Action( of( ICommand ) )
  declare constructor()
  declare destructor() override
  
  declare sub invoke( as ICommand ptr ) override
end type

constructor Execute() : end constructor

destructor Execute() : end destructor

sub Execute.invoke( aCommand as ICommand ptr )
  aCommand->execute()
end sub

/'
  Here, we instantiate a List of ICommands and add two derived classes
  to it (ActivateSensor and EngageClutch). Then, we use an Action to
  execute each one in turn using the forEach() method of the List.
'/
scope
  var commands = List( of( ICommand ) )()
  
  commands.add( new ActivateSensor() ).add( new EngageClutch() ).forEach( Execute() )
end scope

sleep()
