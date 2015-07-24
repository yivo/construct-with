(function() {
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
  })(this, function(__root__, _) {
    var classParameters, extend, getProperty, isFunction, isObject, setProperty, storeParameter;
    extend = _.extend, isObject = _.isObject, isFunction = _.isFunction, getProperty = _.getProperty, setProperty = _.setProperty;
    classParameters = function(Class) {
      var parameters, prototype;
      prototype = Class.prototype;
      parameters = prototype.__parameters;
      if (!parameters) {
        return prototype.__parameters = [];
      } else if (prototype.hasOwnProperty('__parameters') === false) {
        return prototype.__parameters = [].concat(parameters);
      } else {
        return parameters;
      }
    };
    storeParameter = function(container, name, options) {
      var as, i, index, j, len, parameter, prefix, present;
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
      if (!parameter.as) {
        as = name.slice(name.lastIndexOf('.') + 1);
        parameter.as = (prefix = parameter.prefix) ? prefix + as : as;
      }
      if (index > -1) {
        container[index] = parameter;
      } else {
        container.push(parameter);
      }
      return parameter;
    };
    return {
      InstanceMembers: {
        constructWith: function(data) {
          var j, len, name, options, param, params, ref, val;
          options = this.options;
          if (isFunction(options)) {
            options = this.options();
          }
          this.options = extend({}, options, data);
          if (!isObject(data) || !(params = this.__parameters)) {
            return this;
          }
          for (j = 0, len = params.length; j < len; j++) {
            param = params[j];
            name = param.name;
            val = (ref = getProperty(data, name)) != null ? ref : getProperty(this, name);
            if (val != null) {
              setProperty(this, param.as, val);
              if (param.alias) {
                setProperty(this, param.alias, val);
              }
            } else if (param.required) {
              throw new Error("[StrictParameters] " + (this.constructor.name || this) + " requires parameter " + name + " to present in constructor");
            }
          }
          return this;
        }
      },
      ClassMembers: {
        param: function(name, options) {
          return this.params(name, options);
        },
        params: function() {
          var container, index, length, options;
          length = arguments.length;
          options = length > 0 && arguments[length - 1];
          if (!isObject(options)) {
            options = void 0;
          }
          index = -1;
          if (length > 0) {
            container = classParameters(this);
          }
          while (++index < length && arguments[index] !== options) {
            storeParameter(container, arguments[index], options);
          }
          return this;
        }
      }
    };
  });

}).call(this);
