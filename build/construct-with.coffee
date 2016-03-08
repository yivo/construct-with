((factory) ->

  # Browser and WebWorker
  root = if typeof self is 'object' and self?.self is self
    self

  # Server
  else if typeof global is 'object' and global?.global is global
    global

  # AMD
  if typeof define is 'function' and define.amd
    define ['yess', 'exports'], (_) ->
      root.ConstructWith = factory(root, Error, Object, _)

  # CommonJS
  else if typeof module is 'object' and module isnt null and
          module.exports? and typeof module.exports is 'object'
    module.exports = factory(root, Error, Object, require('yess'))

  # Browser and the rest
  else
    root.ConstructWith = factory(root, Error, Object, root._)

  # No return value
  return

)((__root__, Error, Object, _) ->
  {isObject, isFunction, getProperty, setProperty} = _
  
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
  
  extend = __root__.Object.assign ? (obj, props1, props2) ->
    if props1?
      obj[k] = v for own k, v of props1
    if props2?
      obj[k] = v for own k, v of props2
    obj
  
  class MissingParameterError extends Error
    constructor: (object, parameter) ->
      @name    = 'MissingParameterError'
      @message = "[ConstructWith] #{object.constructor.name or object} requires
                  parameter #{parameter} to be passed in constructor"
      super(@message)
      Error.captureStackTrace?(this, @name) or (@stack = new Error().stack)
  
  included: (Class) ->
    Class.initializer 'construct-with', (data) ->
      options  = if isFunction(@options) then @options() else @options
      @options = extend({}, options, data)
      @constructWith(@options) if this['_1']
      return
  
  VERSION: '1.0.7'
  
  InstanceMembers:
  
    constructWith: (data) ->
      for param in this['_1']
        name = param.name
        val  = getProperty(data, name) ? getProperty(this, name)
        if val?
          setProperty(this, param.as,    val)
          setProperty(this, param.alias, val) if param.alias?
        else if param.required is true
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
      container = @reopenArray('_1') if length > 0
  
      while ++index < length and arguments[index] isnt options
        storeParameter(container, arguments[index], options)
      this
)