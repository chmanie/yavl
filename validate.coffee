# TODO: HTML5 validation?

# invoke:
# $("form").validate

if !valMessages?
  valMessages = 
    required:
      successmsg: 'Well done!'
      errormsg: 'I am sorry but this is required!'
    minlength:
      successmsg: 'You managed to meet the requirement of %s characters. Well done!'
      errormsg: 'Sorry, minimal length is %s characters!'
    email:
      successmsg: 'Great!'
      errormsg: 'This does not look like a valid E-Mail address to me'
    fullname:
      successmsg: 'Great!'
      errormsg: 'Please provide a full name'
    regexp:
      successmsg: 'Great!'
      errormsg: 'Something is wrong!'

valConstraints =
  required: () ->
    valfun: (str) ->
      return if str.length >= 1 then true else false
    successmsg: valMessages.required.successmsg
    errormsg: valMessages.required.errormsg
  
  minlength: (ml) ->
    valfun: (str) ->
      return if str.length >= parseInt(ml) then true else false
    successmsg: parseMsg(valMessages.minlength.successmsg, ml)
    errormsg: parseMsg(valMessages.minlength.errormsg, ml)

  email: () ->
    valfun: (str) ->
      exp = /^(.*)@(.*)\.(.*)$/
      return if str.match(exp)? then true else false
    successmsg: valMessages.email.successmsg
    errormsg: valMessages.email.errormsg

  fullname: () ->
    valfun: (str) ->
      # Full name with hyphens, Umlauts and some other crazy letters
      exp = /^[a-zA-ZàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšžÀÁÂÄÃÅÈÉÊËÌÍÎÏÒÓÔÖÕØÙÚÛÜŸÝÑßÇŒÆČŠŽ∂ð ,.'-]+$/
      return if str.match(exp)? then true else false
    successmsg: valMessages.fullname.successmsg
    errormsg: valMessages.fullname.errormsg

  regexp: (exp) ->
    valfun: (str) ->
      return if str.match(exp)? then true else false
    successmsg: valMessages.regexp.successmsg
    errormsg: valMessages.regexp.errormsg

# Reference jQuery
$ = jQuery

# Adds plugin object to jQuery
$.fn.extend
  validate: (options) ->
    # Default settings
    settings =
      debug: false
      onKeyUpValidationSuccess: (elem, messages) ->
      onKeyUpValidationError: (elem, messages) ->
      onBlurValidationSuccess: (elem, messages) ->
      onBlurValidationError: (elem, messages) ->
      onSubmitValidationSuccess: (elem, messages) ->
      onSubmitValidationError: (elem, messages) ->
      onEmpty: (elem) ->

      validateOnKeyUp: false
      validateOnBlur: true
      validateOnSubmit: true

      useFormPOST: true

    # Merge default settings with options.
    settings = $.extend settings, options

    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    class ValidationObj
      constructor: (@elem) ->
        @data = @elem.data()
        @valFuncs = @parseValFuncs()
        @minval = if @elem.data('minval')? then @elem.data('minval') else 0
        # start event listeners
        if settings.validateOnKeyUp
          @startKeyUpValidation()
        if settings.validateOnBlur
          @startBlurValidation()

      parseValFuncs: () ->
        # override standard messages
        errexp = /^(.*)Errormsg$/
        succexp = /^(.*)Successmsg$/
        for message, val of @data
          errfunc = message.match(errexp)
          succfunc = message.match(succexp)
          if errfunc?
            if errfunc[1]?
              valMessages[errfunc[1]].errormsg = val
          if succfunc?
            if succfunc[1]?
              valMessages[succfunc[1]].successmsg = val
        valFuncs = {}
        for func, val of @data
          valFuncs[func] = (valConstraints[func](val)) if isInObj(func, valConstraints)
        return valFuncs

      startKeyUpValidation: () ->
        valObj = @
        @elem.on 'keyup', (e) ->
          if valObj.elem.val() == ''
            settings.onEmpty(valObj.elem)
          else
            if (e.which == 13 or e.which == 16)
              e.preventDefault() # TODO: this does not work!
            else 
              if minval?
                if (valObj.elem.val().length >= parseInt(minval))
                  valObj.applyRules('onKeyupValidation')
              else
                valObj.applyRules('onKeyupValidation')
      
      startBlurValidation: () ->
        valObj = @
        @elem.on 'blur', (e) ->
          if valObj.elem.val() != ''
            valObj.applyRules('onBlurValidation')
          else
            settings.onEmpty(valObj.elem)
      
      applyRules: (eventFunc) ->
        messages = 
          success: []
          failed: []
        for funcName, funcObj of @valFuncs
          if funcObj.valfun(@elem.val()) is false
            messages.failed.push(funcObj.errormsg)
          else
            messages.success.push(funcObj.successmsg)
        if(messages.failed.length == 0)
          settings[eventFunc + 'Success'](@elem, messages)
          return true
        else
          settings[eventFunc + 'Error'](@elem, messages)
          return false

    
    # _Insert magic here._
    return @each ()->
      validationObjects = []
      $(this).find('input, select, textarea').each((i) ->
        if $(this).attr('type') != 'submit'
          validationObjects[i] = new ValidationObj($(this))
      )

      if settings.validateOnSubmit
        $(this).on('submit', (e) ->
          if(!applyAllRules(validationObjects) || !settings.useFormPOST)
            e.preventDefault()
        )

      applyAllRules = (validationObjects) ->
        for valObj in validationObjects
          if !valObj.applyRules('onSubmitValidation')
            return false
        return true

isInObj = (aKey, obj) ->
  for key, val of obj
    return true if key == aKey
  return false

parseMsg = (msg, param) ->
  if msg.indexOf('%s') == -1
    return msg
  else 
    return msg.split('%s')[0] + param + msg.split('%s')[1]

