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
  {extend, isObject, isFunction, getProperty, setProperty} = _
  
  classParameters = (Class) ->
    prototype  = Class::
    parameters = prototype.claimedParameters
  
    unless parameters
      prototype.claimedParameters = []
  
    else if prototype.hasOwnProperty('claimedParameters') is false
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
      options = @options
      options = @options() if isFunction(options)
  
      if isObject(data)
        if isObject(options)
          extend(options, data)
        else
          options = extend({}, data)
      else return this
  
      return this unless (params = @claimedParameters)
  
      for param in params
        name = param.name
        val  = getProperty(data, name) ? getProperty(this, name)
  
        if val?
          setProperty(this, param.as, val)
          setProperty(this, param.alias, val) if param.alias
  
        else if param.required
          throw new Error("#{@constructor.name or this} requires parameter '#{name}' to present (in #{this})")
      this
  
  ClassMembers:
  
    param: (name, options) ->
      @params(name, options)
  
    params: ->
      length    = arguments.length
      options   = length > 0 and arguments[length - 1]
      options   = undefined unless isObject(options)
      index     = -1
      container = classParameters(this) if length > 0
  
      while ++index < length and arguments[index] isnt options
        storeParameter(container, arguments[index], options)
      this
)