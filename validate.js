// Generated by CoffeeScript 1.6.2
var $, isInObj, parseMsg, valConstraints, valMessages;

if (typeof valMessages === "undefined" || valMessages === null) {
  valMessages = {
    required: {
      successmsg: 'Well done!',
      errormsg: 'I am sorry but this is required!'
    },
    minlength: {
      successmsg: 'You managed to meet the requirement of %s characters. Well done!',
      errormsg: 'Sorry, minimal length is %s characters!'
    },
    email: {
      successmsg: 'Great!',
      errormsg: 'This does not look like a valid E-Mail address to me'
    },
    regexp: {
      successmsg: 'Great!',
      errormsg: 'Something is wrong!'
    }
  };
}

valConstraints = {
  required: function() {
    return {
      valfun: function(str) {
        if (str.length >= 1) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: valMessages.required.successmsg,
      errormsg: valMessages.required.errormsg
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
      successmsg: parseMsg(valMessages.minlength.successmsg, ml),
      errormsg: parseMsg(valMessages.minlength.errormsg, ml)
    };
  },
  email: function() {
    return {
      valfun: function(str) {
        var exp;

        exp = /^(.{1,})@(.{1,})\.(.{1,})$/;
        if (str.match(exp) != null) {
          return true;
        } else {
          return false;
        }
      },
      successmsg: valMessages.email.successmsg,
      errormsg: valMessages.email.errormsg
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
      successmsg: valMessages.regexp.successmsg,
      errormsg: valMessages.regexp.errormsg
    };
  }
};

$ = jQuery;

$.fn.extend({
  validate: function(options) {
    var ValidationObj, createLi, hideMessages, log, settings, showMessages;

    settings = {
      debug: false,
      onKeyUpValidationSuccess: function(elem, messages) {
        return hideMessages(elem);
      },
      onKeyUpValidationError: function(elem, messages) {
        hideMessages(elem);
        return showMessages(elem, messages);
      },
      onBlurValidationSuccess: function(elem, messages) {
        return hideMessages(elem);
      },
      onBlurValidationError: function(elem, messages) {
        hideMessages(elem);
        return showMessages(elem, messages);
      },
      onSubmitElemValidationSuccess: function(elem, messages) {
        return hideMessages(elem);
      },
      onSubmitElemValidationError: function(elem, messages) {
        hideMessages(elem);
        return showMessages(elem, messages);
      },
      onSubmitValidationSuccess: function(form) {},
      onSubmitValidationError: function(form) {},
      onEmpty: function(elem) {
        return hideMessages(elem);
      },
      validateOnKeyUp: false,
      validateOnBlur: true,
      validateOnSubmit: true,
      useFormPOST: true,
      ulClass: 'valUl',
      liClass: 'valLi'
    };
    settings = $.extend(settings, options);
    hideMessages = function(elem) {
      var errorList;

      errorList = elem.next('ul');
      return errorList.remove();
    };
    showMessages = function(elem, messages) {
      var $messages, errorList, message, _i, _len;

      $messages = messages.failed.map(createLi);
      errorList = $('<ul>').addClass(settings.ulClass);
      for (_i = 0, _len = $messages.length; _i < _len; _i++) {
        message = $messages[_i];
        errorList.append(message);
      }
      return errorList.insertAfter(elem);
    };
    createLi = function(error) {
      return $('<li>' + error + '</li>').addClass(settings.liClass);
    };
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
        this.minval = this.elem.data('minval') || 0;
        if (settings.validateOnKeyUp) {
          this.startKeyUpValidation();
        }
        if (settings.validateOnBlur) {
          this.startBlurValidation();
        }
      }

      ValidationObj.prototype.parseValFuncs = function() {
        var errexp, errfunc, func, message, succexp, succfunc, val, valFuncs, _ref, _ref1;

        errexp = /^(.*)Errormsg$/;
        succexp = /^(.*)Successmsg$/;
        _ref = this.data;
        for (message in _ref) {
          val = _ref[message];
          errfunc = message.match(errexp);
          succfunc = message.match(succexp);
          if (errfunc != null) {
            if (errfunc[1] != null) {
              valMessages[errfunc[1]].errormsg = val;
            }
          }
          if (succfunc != null) {
            if (succfunc[1] != null) {
              valMessages[succfunc[1]].successmsg = val;
            }
          }
        }
        valFuncs = {};
        _ref1 = this.data;
        for (func in _ref1) {
          val = _ref1[func];
          if (isInObj(func, valConstraints)) {
            valFuncs[func] = valConstraints[func](val);
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
                  return valObj.applyRules('onKeyUpValidation');
                }
              } else {
                return valObj.applyRules('onKeyUpValidation');
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
      var applyAllRules, formObj, validationObjects;

      validationObjects = [];
      $(this).find('input, select, textarea').each(function(i) {
        if ($(this).attr('type') !== 'submit') {
          return validationObjects[i] = new ValidationObj($(this));
        }
      });
      formObj = $(this);
      if (settings.validateOnSubmit) {
        $(this).on('submit', function(e) {
          if (!applyAllRules(validationObjects)) {
            e.preventDefault();
            return settings.onSubmitValidationError(formObj);
          } else {
            if (!settings.useFormPOST) {
              e.preventDefault();
              return settings.onSubmitValidationSuccess(formObj);
            } else {
              return settings.onSubmitValidationSuccess(formObj);
            }
          }
        });
      }
      return applyAllRules = function(validationObjects) {
        var success, valObj, _i, _len;

        success = true;
        for (_i = 0, _len = validationObjects.length; _i < _len; _i++) {
          valObj = validationObjects[_i];
          if (!valObj.applyRules('onSubmitElemValidation')) {
            success = false;
          }
        }
        return success;
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

parseMsg = function(msg, param) {
  if (msg.indexOf('%s') === -1) {
    return msg;
  } else {
    return msg.split('%s')[0] + param + msg.split('%s')[1];
  }
};