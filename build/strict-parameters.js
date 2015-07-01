(function() {
  var slice = [].slice;

  (function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      define(['lodash', 'yess'], function(_) {
        return root.StrictParameters = factory(root, _);
      });
    } else if (typeof module === 'object' && typeof module.exports === 'object') {
      module.exports = factory(root, require('lodash'), require('yess'));
    } else {
      root.StrictParameters = factory(root, root._);
    }
  })(this, function(root, _) {
    var classParameters, extend, hasOwnProp, isFunction, isPlainObject, propertyAccessorsGet, propertyAccessorsSet, ref, ref1, ref2, ref3, simpleGetProperty, simpleSetProperty, storeParameter;
    extend = _.extend, isFunction = _.isFunction, isPlainObject = _.isPlainObject;
    hasOwnProp = {}.hasOwnProperty;
    simpleGetProperty = _.getProperty;
    simpleSetProperty = _.setProperty;
    propertyAccessorsGet = (ref = root.PropertyAccessors) != null ? (ref1 = ref.InstanceMembers) != null ? ref1.get : void 0 : void 0;
    propertyAccessorsSet = (ref2 = root.PropertyAccessors) != null ? (ref3 = ref2.InstanceMembers) != null ? ref3.set : void 0 : void 0;
    classParameters = function(klass) {
      var parameters, prototype;
      prototype = klass.prototype;
      parameters = prototype.claimedParameters;
      if (!parameters) {
        return prototype.claimedParameters = [];
      } else if (hasOwnProp.call(prototype, 'claimedParameters') === false) {
        return prototype.claimedParameters = [].concat(parameters);
      } else {
        return parameters;
      }
    };
    storeParameter = function(container, name, options) {
      var i, index, j, len, parameter, present;
      index = -1;
      for (i = j = 0, len = container.length; j < len; i = ++j) {
        present = container[i];
        if (!(present.name === name)) {
          continue;
        }
        index = i;
        break;
      }
      if (index > -1) {
        parameter = container[index];
      }
      parameter = extend({
        name: name
      }, parameter, options);
      parameter.as || (parameter.as = name.slice(name.lastIndexOf('.') + 1));
      if (index > -1) {
        container[index] = parameter;
      } else {
        container.push(parameter);
      }
      return parameter;
    };
    return {
      InstanceMembers: {
        mergeParams: function(data) {
          var alias, as, j, len, name, param, params, ref4, required;
          if (!isPlainObject(data) || !(params = this.claimedParameters)) {
            return this;
          }
          for (j = 0, len = params.length; j < len; j++) {
            ref4 = params[j], name = ref4.name, as = ref4.as, required = ref4.required, alias = ref4.alias;
            param = propertyAccessorsGet ? propertyAccessorsGet.call(data, name) : simpleGetProperty(data, name);
            if (param == null) {
              param = this.get ? this.get(name) : simpleGetProperty(this, name);
            }
            if (param != null) {
              if (this.set) {
                this.set(as, param);
                if (alias) {
                  this.set(alias, param);
                }
              } else {
                simpleSetProperty(this, as, param);
                if (alias) {
                  simpleSetProperty(this, alias, param);
                }
              }
            } else if (required) {
              throw new Error((this.constructor.name || this) + " requires parameter '" + name + "' to present (in " + this + ")");
            }
          }
          return this;
        }
      },
      ClassMembers: {
        param: function(name, options) {
          var container;
          container = classParameters(this);
          storeParameter(container, name, options);
          return this;
        },
        parameter: function() {
          return this.param.apply(this, arguments);
        },
        params: function() {
          var j, k, last, len, name, names, options;
          names = 2 <= arguments.length ? slice.call(arguments, 0, j = arguments.length - 1) : (j = 0, []), last = arguments[j++];
          if (isPlainObject(last)) {
            options = last;
          }
          for (k = 0, len = names.length; k < len; k++) {
            name = names[k];
            this.param(name, options);
          }
          if (!options) {
            this.param(last);
          }
          return this;
        }
      }
    };
  });

}).call(this);
