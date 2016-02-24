(function() {
  var extend1 = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  (function(factory) {
    var root;
    root = typeof self === 'object' && (typeof self !== "undefined" && self !== null ? self.self : void 0) === self ? self : typeof global === 'object' && (typeof global !== "undefined" && global !== null ? global.global : void 0) === global ? global : void 0;
    if (typeof define === 'function' && define.amd) {
      define(['yess', 'exports'], function(_) {
        return root.ConstructWith = factory(root, _);
      });
    } else if (typeof module === 'object' && module !== null && (module.exports != null) && typeof module.exports === 'object') {
      module.exports = factory(root, require('yess'));
    } else {
      root.ConstructWith = factory(root, root._);
    }
  })(function(__root__, _) {
    var MissingParameterError, extend, getProperty, isFunction, isObject, setProperty, storeParameter;
    extend = _.extend, isObject = _.isObject, isFunction = _.isFunction, getProperty = _.getProperty, setProperty = _.setProperty;
    storeParameter = function(container, name, options) {
      var as, el, i, index, j, len, parameter, prefix;
      index = -1;
      for (i = j = 0, len = container.length; j < len; i = ++j) {
        el = container[i];
        if (!(el.name === name)) {
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
        prefix = parameter.prefix;
        parameter.as = prefix ? prefix + as : as;
      }
      if (index > -1) {
        container[index] = parameter;
      } else {
        container.push(parameter);
      }
      return parameter;
    };
    MissingParameterError = (function(superClass) {
      extend1(MissingParameterError, superClass);

      function MissingParameterError(object, parameter) {
        this.name = 'MissingParameterError';
        this.message = "[ConstructWith] " + (object.constructor.name || object) + " requires parameter " + parameter + " to be passed in constructor";
        MissingParameterError.__super__.constructor.call(this, this.message);
        (typeof Error.captureStackTrace === "function" ? Error.captureStackTrace(this, this.name) : void 0) || (this.stack = new Error().stack);
      }

      return MissingParameterError;

    })(Error);
    return {
      included: function(Class) {
        return Class.initializer('construct-with', function(data) {
          var options;
          options = isFunction(this.options) ? this.options() : this.options;
          this.options = extend({}, options, data);
          if (this['_1']) {
            this.constructWith(this.options);
          }
        });
      },
      VERSION: '1.0.2',
      InstanceMembers: {
        constructWith: function(data) {
          var j, len, name, param, ref, ref1, val;
          ref = this['_1'];
          for (j = 0, len = ref.length; j < len; j++) {
            param = ref[j];
            name = param.name;
            val = (ref1 = getProperty(data, name)) != null ? ref1 : getProperty(this, name);
            if (val != null) {
              setProperty(this, param.as, val);
              if (param.alias) {
                setProperty(this, param.alias, val);
              }
            } else if (param.required) {
              throw new MissingParameterError(this, param.name);
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
            container = this.reopenArray('_1');
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
