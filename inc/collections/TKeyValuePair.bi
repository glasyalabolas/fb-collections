#ifndef __FBFW_COLLECTIONS_KEYVALUEPAIR__
#define __FBFW_COLLECTIONS_KEYVALUEPAIR__

'' Template for key-value pairs, to be used in keyed collections.
#define KeyValuePair( TKey, TType ) _
  __T__##KeyValuePair##__##TKey##__##TType

#macro template_keyValuePair( TKey, TType )
  #ifndef __T__##KeyValuePair##__##TKey##__##TType
  
  type KeyValuePair( of( TKey ), of( TType ) )
    public:
      declare constructor()
      declare constructor( as Key( of( TKey ) ), byref as const TType )
      declare constructor( as Key( of( TKey ) ), as TType ptr )
      declare constructor( as KeyValuePair( of( TKey ), of( TType ) ) )
      declare destructor()
      
      declare operator let( as KeyValuePair( of( TKey ), of( TType ) ) )
      
      as Key( of( TKey ) ) _key
      as TType ptr _value
      
    private:
      as boolean _needsDisposing
  end type
  
  constructor KeyValuePair( of( TKey ), of( TType ) )()
  end constructor
  
  constructor KeyValuePair( of( TKey ), of( TType ) )( aKey as Key( of( TKey ) ), aValue as TType ptr )
    _key = aKey
    _value = aValue
    _needsDisposing = true
  end constructor
  
  constructor KeyValuePair( of( TKey ), of( TType ) )( aKey as Key( of( TKey ) ), byref aValue as const TType )
    _key = aKey
    _value = cptr( TType ptr, @aValue )
    _needsDisposing = false
  end constructor
  
  constructor KeyValuePair( of( TKey ), of( TType ) )( rhs as KeyValuePair( of( TKey ), of( TType ) ) )
    _key = rhs._key
    _value = rhs._value
    _needsDisposing = rhs._needsDisposing
  end constructor
  
  destructor KeyValuePair( of( TKey ), of( TType ) )()
    if( _needsDisposing andAlso _value <> 0 ) then
      delete( _value )
    end if
  end destructor
  
  operator KeyValuePair( of( TKey ), of( TType ) ).let( rhs as KeyValuePair( of( TKey ), of( TType ) ) )
    _key = rhs._key
    _value = rhs._value
    _needsDisposing = rhs._needsDisposing
  end operator
  
  #endif
#endmacro

#endif
