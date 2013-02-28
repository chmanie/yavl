// Generated by CoffeeScript 1.5.0
var $, constraints, isInObj;

$ = jQuery;

$.fn.extend({
  validate: function(options) {
    var ValidationObj, log, settings;
    settings = {
      debug: false,
      onKeyUpValidationSuccess: function(elem, messages) {},
      onKeyUpValidationError: function(elem, messages) {},
      onBlurValidationSuccess: function(elem, messages) {},
      onBlurValidationError: function(elem, messages) {},
      onSubmitValidationSuccess: function(elem, messages) {},
      onSubmitValidationError: function(elem, messages) {},
      onEmpty: function(elem) {},
      validateOnKeyUp: false,
      validateOnBlur: true,
      validateOnSubmit: true,
      useFormPOST: true
    };
    settings = $.extend(settings, options);
    log = function(msg) {
      if (settings.debug) {
        return typeof console !== "undefined" && console !== null ? console.log(msg) : void 0;
      }
    };
    ValidationObj = (function() {

      function ValidationObj(elem) {
        this.elem = elem;
        this.data = this.elem.data();
        this.valFuncs = this.parseValFuncs();
        this.minval = this.elem.data('minval') != null ? this.elem.data('minval') : 0;
        if (settings.validateOnKeyUp) {
          this.startKeyUpValidation();
        }
        if (settings.validateOnBlur) {
          this.startBlurValidation();
        }
      }

      ValidationObj.prototype.parseValFuncs = function() {
        var errexp, errfunc, func, message, succexp, succfunc, val, valFuncs, _ref, _ref1;
        valFuncs = {};
        _ref = this.data;
        for (func in _ref) {
          val = _ref[func];
          if (isInObj(func, constraints)) {
            valFuncs[func] = constraints[func](val);
          }
        }
        errexp = /^(.*)Errormsg$/;
        succexp = /^(.*)Successmsg$/;
        _ref1 = this.data;
        for (message in _ref1) {
          val = _ref1[message];
          errfunc = message.match(errexp);
          succfunc = message.match(succexp);
          if (errfunc != null) {
            if (errfunc[1] != null) {
              valFuncs[errfunc[1]].errormsg = val;
            }
          }
          if (succfunc != null) {
            if (succfunc[1] != null) {
              valFuncs[succfunc[1]].successmsg = val;
            }
          }
        }
        return valFuncs;
      };

      ValidationObj.prototype.startKeyUpValidation = function() {
        var valObj;
        valObj = this;
        return this.elem.on('keyup', function(e) {
          if (valObj.elem.val() === '') {
            return settings.onEmpty(valObj.elem);
          } else {
            if (e.which === 13 || e.which === 16) {
              return e.preventDefault();
            } else {
              if (typeof minval !== "undefined" && minval !== null) {
                if (valObj.elem.val().length >= parseInt(minval)) {
                  return valObj.applyRules('onKeyupValidation');
                }
              } else {
                return valObj.applyRules('onKeyupValidation');
              }
            }
          }
        });
      };

      ValidationObj.prototype.startBlurValidation = function() {
        var valObj;
        valObj = this;
        return this.elem.on('blur', function(e) {
          if (valObj.elem.val() !== '') {
            return valObj.applyRules('onBlurValidation');
          } else {
            return settings.onEmpty(valObj.elem);
          }
        });
      };

      ValidationObj.prototype.applyRules = function(eventFunc) {
        var funcName, funcObj, messages, _ref;
        messages = {
          success: [],
          failed: []
        };
        _ref = this.valFuncs;
        for (funcName in _ref) {
          funcObj = _ref[funcName];
          if (funcObj.valfun(this.elem.val()) === false) {
            messages.failed.push(funcObj.errormsg);
          } else {
            messages.success.push(funcObj.successmsg);
          }
        }
        if (messages.failed.length === 0) {
          settings[eventFunc + 'Success'](this.elem, messages);
          return true;
        } else {
          settings[eventFunc + 'Error'](this.elem, messages);
          return false;
        }
      };

      return ValidationObj;

    })();
    return this.each(function() {
      var applyAllRules, validationObjects;
      validationObjects = [];
      $(this).find('input, select, textarea').each(function(i) {
        if ($(this).attr('type') !== 'submit') {
          return validationObjects[i] = new ValidationObj($(this));
        }
      });
      if (settings.validateOnSubmit) {
        $(this).on('submit', function(e) {
          if (!applyAllRules(validationObjects) || !settings.useFormPOST) {
            return e.preventDefault();
          }
        });
      }
      return applyAllRules = function(validationObjects) {
        var valObj, _i, _len;
        for (_i = 0, _len = validationObjects.length; _i < _len; _i++) {
          valObj = validationObjects[_i];
          if (!valObj.applyRules('onSubmitValidation')) {
            return false;
          }
        }
        return true;
      };
    });
  }
});

isInObj = function(aKey, obj) {
  var key, val;
  for (key in obj) {
    val = obj[key];
    if (key === aKey) {
      return true;
    }
  }
  return false;
};

constraints = {
  required: function() {
    return {
      valfun: function(str) {
        if (str.length >= 1) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: 'You were right, this is fuckin required',
      errormsg: 'You have to fill this, man!'
    };
  },
  minlength: function(ml) {
    return {
      valfun: function(str) {
        if (str.length >= parseInt(ml)) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: 'Yeah!',
      errormsg: 'Sorry, minimal length is ' + ml + ' characters'
    };
  },
  fullname: function() {
    return {
      valfun: function(str) {
        var exp;
        exp = /^[a-zA-ZàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšžÀÁÂÄÃÅÈÉÊËÌÍÎÏÒÓÔÖÕØÙÚÛÜŸÝÑßÇŒÆČŠŽ∂ð ,.'-]+$/;
        if (str.match(exp) != null) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: 'Great!',
      errormsg: 'Please provide a full name.'
    };
  },
  regexp: function(exp) {
    return {
      valfun: function(str) {
        if (str.match(exp) != null) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: 'Great!',
      errormsg: 'Something is wrong!'
    };
  }
};