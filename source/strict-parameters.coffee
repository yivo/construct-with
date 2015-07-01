{extend, isFunction, isPlainObject} = _
hasOwnProp            = {}.hasOwnProperty
simpleGetProperty     = _.getProperty
simpleSetProperty     = _.setProperty
propertyAccessorsGet  = root.PropertyAccessors?.InstanceMembers?.get
propertyAccessorsSet  = root.PropertyAccessors?.InstanceMembers?.set

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

    for {name, as, required, alias} in params
      param = if propertyAccessorsGet
        propertyAccessorsGet.call(data, name)
      else
        simpleGetProperty(data, name)

      param ?= if @get
        @get(name)
      else
        simpleGetProperty(this, name)

      if param?
        if @set
          @set(as, param)
          @set(alias, param) if alias

        else
          simpleSetProperty(this, as, param)
          simpleSetProperty(this, alias, param) if alias

      else if required
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