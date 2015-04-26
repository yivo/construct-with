(function() {
  var slice = [].slice;

  (function(root, factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['lodash', 'yess', 'coffee-concerns'], factory);
    } else if (typeof module === 'object' && typeof module.exports === 'object') {
      return module.exports = factory(require('lodash'), require('yess'), require('coffee-concerns'));
    } else {
      return root.StrictParameters = factory(root._, root.yess, root["null"]);
    }
  })(this, function(_, yess) {
    var extend, isFunction, isPlainObject, traverseObject;
    traverseObject = yess.traverseObject;
    extend = _.extend, isFunction = _.isFunction, isPlainObject = _.isPlainObject;
    return {
      InstanceMembers: {
        claimedParameters: [],
        mergeParams: function(data) {
          var alias, as, config, j, len, name, param, ref, required;
          if (!isPlainObject(data)) {
            return;
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
            if (param === null || param === void 0) {
              param = traverseObject(this, name);
            }
            if (param === null || param === void 0) {
              if (required) {
                throw new Error((this.constructor.name || this) + " requires " + name + " to be given on construction (in " + this + ")");
              }
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
          this.reopen('claimedParameters', function(params) {
            var i, index, j, len, param, present;
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
              return params[index] = param;
            } else {
              return params.push(param);
            }
          });
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
