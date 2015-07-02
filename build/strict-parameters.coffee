((root, factory) ->
  if typeof define is 'function' and define.amd
    define ['lodash', 'yess'], (_) ->
      root.StrictParameters = factory(root, _)
  else if typeof module is 'object' && typeof module.exports is 'object'
    module.exports = factory(root, require('lodash'), require('yess'))
  else
    root.StrictParameters = factory(root, root._)
  return
)(this, (__root__, _) ->
  {extend, isPlainObject} = _
  hasOwnProp  = {}.hasOwnProperty
  get         = __root__.PropertyAccessors?.get or _.getProperty
  set         = __root__.PropertyAccessors?.set or _.setProperty
  
  classParameters = (klass) ->
    prototype  = klass::
    parameters = prototype.claimedParameters
  
    unless parameters
      prototype.claimedParameters = []
  
    else if hasOwnProp.call(prototype, 'claimedParameters') is false
      prototype.claimedParameters = [].concat(parameters)
  
    else
      parameters
  
  storeParameter = (container, name, options) ->
    index = -1
  
    for present, i in container when present.name is name
      index = i
      break
  
    parameter = container[index] if index > -1
    parameter = extend({name}, parameter, options)
    parameter.as ||= name.slice(name.lastIndexOf('.') + 1)
  
    if index > -1
      container[index] = parameter
    else
      container.push(parameter)
    parameter
  
  InstanceMembers:
  
    mergeParams: (data) ->
      return this if not isPlainObject(data) or not (params = @claimedParameters)
  
      for param in params
        name = param.name
        val  = get(data, name)
        val ?= if @get
          @get(name)
        else
          get(this, name)
  
        if val?
          if @set
            @set(param.as, val)
            @set(param.alias, val) if param.alias
  
          else
            set(this, param.as, val)
            set(this, param.alias, val) if param.alias
  
        else if param.required
          throw new Error("#{@constructor.name or this} requires parameter '#{name}' to present (in #{this})")
      this
  
  ClassMembers:
  
    param: (name, options) ->
      container = classParameters(this)
      storeParameter(container, name, options)
      this
  
    parameter: ->
      @param(arguments...)
  
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