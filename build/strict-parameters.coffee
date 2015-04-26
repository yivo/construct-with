((root, factory) ->
  if typeof define is 'function' and define.amd
    define ['lodash', 'yess', 'coffee-concerns'], (_, yess) ->
      root.StrictParameters = factory(root, _, yess)
  else if typeof module is 'object' && typeof module.exports is 'object'
    module.exports = factory(root, require('lodash'), require('yess'), require('coffee-concerns'))
  else
    root.StrictParameters = factory(root, root._, root.yess)
)(this, (root, _, yess) ->
  {traverseObject} = yess
  {extend, isFunction, isPlainObject} = _
  
  InstanceMembers:
  
    claimedParameters: []
  
    mergeParams: (data) ->
      return unless isPlainObject(data)
  
      if @options
        # Let the initial options be a function
        if isFunction(@options)
          @options = @options.call(@)
        extend(@options, data)
      else
        @options = data
  
      return @ unless config = @claimedParameters
  
      for {name, as, required, alias} in config
        param = traverseObject(data, name)
  
        if param is null or param is undefined
          param = traverseObject(this, name)
  
        if param is null or param is undefined
          if required
            throw new Error("#{@constructor.name or this} requires #{name} to be given on construction (in #{this})")
        else
          @[as] = param
          @[alias] = param if alias
      @
  
  ClassMembers:
    param: (name, options) ->
      @reopen 'claimedParameters', (params) ->
        index = -1
  
        for present, i in params when present.name is name
          index = i
          break
  
        param = params[index] if index > -1
        param = extend({name}, param, options)
        param.as ||= name.slice(name.lastIndexOf('.') + 1)
  
        if index > -1
          params[index] = param
        else params.push(param)
      @
  
    params: (names..., last) ->
      # Last argument can be either name, either options
      options = last if isPlainObject(last)
  
      for name in names
        @param(name, options)
  
      # If last arg isn't options then it is name
      unless options
        @param(last)
      @
)