((root, factory) ->
  if typeof define is 'function' and define.amd
    define ['lodash', 'yess', 'coffee-concerns'], (_, yess) ->
      root.StrictParameters = factory(root, _, yess)
  else if typeof module is 'object' && typeof module.exports is 'object'
    module.exports = factory(root, require('lodash'), require('yess'), require('coffee-concerns'))
  else
    root.StrictParameters = factory(root, root._, root.yess)
  return
)(this, (root, _, yess) ->
  {extend, isFunction, isPlainObject, traverseObject} = _
  hasOwnProp = {}.hasOwnProperty
  
  InstanceMembers:
  
    mergeParams: (data) ->
      return this unless isPlainObject(data)
  
      if @options
        # Let the initial options be a function
        if isFunction(@options)
          @options = @options.call(this)
        extend(@options, data)
      else
        @options = data
  
      return this unless config = @claimedParameters
  
      for {name, as, required, alias} in config
        param = traverseObject(data, name)
  
        unless param?
          param = traverseObject(this, name)
  
        if !param? and required
          throw new Error("#{@constructor.name or this} requires parameter '#{name}' to present (in #{this})")
        else
          @[as] = param
          @[alias] = param if alias
      this
  
  ClassMembers:
    param: (name, options) ->
      prototype = this::
  
      params = prototype.claimedParameters
  
      if !params
        params = prototype.claimedParameters = []
  
      else unless hasOwnProp.call(prototype, 'claimedParameters')
        params = prototype.claimedParameters = [].concat(params)
  
      index  = -1
  
      for present, i in params when present.name is name
        index = i
        break
  
      param = params[index] if index > -1
      param = extend({name}, param, options)
      param.as ||= name.slice(name.lastIndexOf('.') + 1)
  
      if index > -1
        params[index] = param
      else params.push(param)
  
      this
  
    params: (names..., last) ->
      # Last argument can be either name, either options
      options = last if isPlainObject(last)
  
      for name in names
        @param(name, options)
  
      # If last arg isn't options then it is name
      unless options
        @param(last)
      this
)