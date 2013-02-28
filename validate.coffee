# TODO: HTML5 validation?

# invoke:
# $("form").validate
#   debug: true

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
        valFuncs = {}
        for func, val of @data
          valFuncs[func] = (constraints[func](val)) if isInObj(func, constraints)
        # override standard messages
        errexp = /^(.*)Errormsg$/
        succexp = /^(.*)Successmsg$/
        for message, val of @data
          errfunc = message.match(errexp)
          succfunc = message.match(succexp)
          if errfunc?
            if errfunc[1]?
              valFuncs[errfunc[1]].errormsg = val
          if succfunc?
            if succfunc[1]?
              valFuncs[succfunc[1]].successmsg = val
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

constraints =
  required: () ->
    valfun: (str) ->
      return if str.length >= 1 then true else false
    successmsg: 'You were right, this is fuckin required'
    errormsg: 'You have to fill this, man!'
  
  minlength: (ml) ->
    valfun: (str) ->
      return if str.length >= parseInt(ml) then true else false
    successmsg: 'Yeah!'
    errormsg: 'Sorry, minimal length is ' + ml + ' characters'

  fullname: () ->
    valfun: (str) ->
      # Full name with hyphens, Umlauts and some other crazy letters
      exp = /^[a-zA-ZàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšžÀÁÂÄÃÅÈÉÊËÌÍÎÏÒÓÔÖÕØÙÚÛÜŸÝÑßÇŒÆČŠŽ∂ð ,.'-]+$/
      return if str.match(exp)? then true else false
    successmsg: 'Great!'
    errormsg: 'Please provide a full name.'

  regexp: (exp) ->
    valfun: (str) ->
      return if str.match(exp)? then true else false
    successmsg: 'Great!'
    errormsg: 'Something is wrong!'