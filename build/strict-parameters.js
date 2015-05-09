(function() {
  var slice = [].slice;

  (function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      define(['lodash', 'yess', 'coffee-concerns'], function(_, yess) {
        return root.StrictParameters = factory(root, _, yess);
      });
    } else if (typeof module === 'object' && typeof module.exports === 'object') {
      module.exports = factory(root, require('lodash'), require('yess'), require('coffee-concerns'));
    } else {
      root.StrictParameters = factory(root, root._, root.yess);
    }
  })(this, function(root, _, yess) {
    var extend, hasOwnProp, isFunction, isPlainObject, traverseObject;
    extend = _.extend, isFunction = _.isFunction, isPlainObject = _.isPlainObject, traverseObject = _.traverseObject;
    hasOwnProp = {}.hasOwnProperty;
    return {
      InstanceMembers: {
        claimedParameters: [],
        mergeParams: function(data) {
          var alias, as, config, j, len, name, param, ref, required;
          if (!isPlainObject(data)) {
            return this;
          }
          if (this.options) {
            if (isFunction(this.options)) {
              this.options = this.options.call(this);
            }
            extend(this.options, data);
          } else {
            this.options = data;
          }
          if (!(config = this.claimedParameters)) {
            return this;
          }
          for (j = 0, len = config.length; j < len; j++) {
            ref = config[j], name = ref.name, as = ref.as, required = ref.required, alias = ref.alias;
            param = traverseObject(data, name);
            if (param == null) {
              param = traverseObject(this, name);
            }
            if ((param == null) && required) {
              throw new Error((this.constructor.name || this) + " requires parameter '" + name + "' to present (in " + this + ")");
            } else {
              this[as] = param;
              if (alias) {
                this[alias] = param;
              }
            }
          }
          return this;
        }
      },
      ClassMembers: {
        param: function(name, options) {
          var i, index, j, len, param, params, present, prototype;
          prototype = this.prototype;
          if (!hasOwnProp.call(prototype, 'claimedParameters') && (params = prototype.claimedParameters)) {
            prototype.claimedParameters = [].concat(params);
          }
          params = prototype.claimedParameters;
          index = -1;
          for (i = j = 0, len = params.length; j < len; i = ++j) {
            present = params[i];
            if (!(present.name === name)) {
              continue;
            }
            index = i;
            break;
          }
          if (index > -1) {
            param = params[index];
          }
          param = extend({
            name: name
          }, param, options);
          param.as || (param.as = name.slice(name.lastIndexOf('.') + 1));
          if (index > -1) {
            params[index] = param;
          } else {
            params.push(param);
          }
          return this;
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
