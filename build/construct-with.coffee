((factory) ->

  # Browser and WebWorker
  root = if typeof self is 'object' and self?.self is self
    self

  # Server
  else if typeof global is 'object' and global?.global is global
    global

  # AMD
  if typeof define is 'function' and define.amd
    define ['lodash', 'yess', 'exports'], (_) ->
      root.ConstructWith = factory(root, _)

  # CommonJS
  else if typeof module is 'object' and module isnt null and
          module.exports? and typeof module.exports is 'object'
    module.exports = factory(root, require('lodash'), require('yess'))

  # Browser and the rest
  else
    root.ConstructWith = factory(root, root._)

  # No return value
  return

)((__root__, _) ->
  {extend, isObject, isFunction, getProperty, setProperty} = _
  
  classParameters = (Class) ->
    {prototype} = Class
    parameters  = prototype.__params
  
    if not parameters
      prototype.__params = []
    else if prototype.hasOwnProperty('__params') is false
      prototype.__params = [].concat(parameters)
    else
      parameters
  
  storeParameter = (container, name, options) ->
    index = -1
    for el, i in container when el.name is name
      index = i
      break
  
    parameter = container[index] if index > -1
    parameter = extend({name}, parameter, options)
  
    unless parameter.as
      as           = name.slice(name.lastIndexOf('.') + 1)
      prefix       = parameter.prefix
      parameter.as = if prefix then (prefix + as) else as
  
    if index > -1
      container[index] = parameter
    else
      container.push(parameter)
    parameter
  
  class MissingParameterError extends Error
    constructor: (object, parameter) ->
      @name    = 'MissingParameterError'
      @message = "[ConstructWith] #{object.constructor.name or object} requires
                  parameter '#{parameter}' to present in constructor"
      super(@message)
      Error.captureStackTrace?(this, @name) or (@stack = new Error().stack)
  
  included: (Class) ->
    Class.initializer 'construct-with', (data) ->
      options  = if isFunction(@options) then @options() else @options
      @options = extend({}, options, data)
      @constructWith(@options) if @__params
      return
  
  InstanceMembers:
  
    constructWith: (data) ->
      for param in @__params
        name = param.name
        val  = getProperty(data, name) ? getProperty(this, name)
  
        if val?
          setProperty(this, param.as,    val)
          setProperty(this, param.alias, val) if param.alias
  
        else if param.required
          throw new MissingParameterError(this, param.name)
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