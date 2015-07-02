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
  })(this, function(__root__, _) {
    var classParameters, extend, get, hasOwnProp, isPlainObject, ref, ref1, set, storeParameter;
    extend = _.extend, isPlainObject = _.isPlainObject;
    hasOwnProp = {}.hasOwnProperty;
    get = ((ref = __root__.PropertyAccessors) != null ? ref.get : void 0) || _.getProperty;
    set = ((ref1 = __root__.PropertyAccessors) != null ? ref1.set : void 0) || _.setProperty;
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
          var j, len, name, param, params, val;
          if (!isPlainObject(data) || !(params = this.claimedParameters)) {
            return this;
          }
          for (j = 0, len = params.length; j < len; j++) {
            param = params[j];
            name = param.name;
            val = get(data, name);
            if (val == null) {
              val = this.get ? this.get(name) : get(this, name);
            }
            if (val != null) {
              if (this.set) {
                this.set(param.as, val);
                if (param.alias) {
                  this.set(param.alias, val);
                }
              } else {
                set(this, param.as, val);
                if (param.alias) {
                  set(this, param.alias, val);
                }
              }
            } else if (param.required) {
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
