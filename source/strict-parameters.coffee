{extend, isObject, isFunction, getProperty, setProperty} = _

classParameters = (Class) ->
  prototype  = Class::
  parameters = prototype.__parameters

  if not parameters
    prototype.__parameters = []

  else if prototype.hasOwnProperty('__parameters') is false
    prototype.__parameters = [].concat(parameters)

  else
    parameters

storeParameter = (container, name, options) ->
  index = -1

  for present, i in container when present.name is name
    index = i
    break

  parameter = container[index] if index > -1
  parameter = extend({name}, parameter, options)

  unless parameter.as
    as = name.slice(name.lastIndexOf('.') + 1)
    parameter.as = if prefix = parameter.prefix then prefix + as else as

  if index > -1
    container[index] = parameter
  else
    container.push(parameter)
  parameter

InstanceMembers:

  constructWith: (data) ->
    options  = @options
    options  = @options() if isFunction(options)
    @options = extend({}, options, data)

    return this if not isObject(data) or not (params = @__parameters)

    for param in params
      name = param.name
      val  = getProperty(data, name) ? getProperty(this, name)

      if val?
        setProperty(this, param.as, val)
        setProperty(this, param.alias, val) if param.alias

      else if param.required
        throw new Error "[StrictParameters] #{@constructor.name or this} requires
          parameter #{name} to present in constructor"
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