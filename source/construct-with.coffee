{extend, isObject, isFunction, getProperty, setProperty} = _

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
                parameter #{parameter} to be passed in constructor"
    super(@message)
    Error.captureStackTrace?(this, @name) or (@stack = new Error().stack)

included: (Class) ->
  Class.initializer 'construct-with', (data) ->
    options  = if isFunction(@options) then @options() else @options
    @options = extend({}, options, data)
    @constructWith(@options) if this[PARAMS]
    return

VERSION: '1.0.2'

InstanceMembers:

  constructWith: (data) ->
    for param in this[PARAMS]
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
    container = @reopenArray(PARAMS) if length > 0

    while ++index < length and arguments[index] isnt options
      storeParameter(container, arguments[index], options)
    this
