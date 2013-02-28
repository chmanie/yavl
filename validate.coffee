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
      # very simple regex for email validation
      # read: http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
      exp = /^(.{1,})@(.{1,})\.(.{1,})$/
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
        # function is invoked if KeyUp validation was successful
      onKeyUpValidationError: (elem, messages) ->
        # function is invoked if KeyUp validation caused an error
      onBlurValidationSuccess: (elem, messages) ->
        # function is invoked if validation after blur was successful
      onBlurValidationError: (elem, messages) ->
        # function is invoked if validation after caused an error
      onSubmitElemValidationSuccess: (elem, messages) ->
        # function is invoked on if validation of a specific element after submit was successful
      onSubmitElemValidationError: (elem, messages) ->
        # function is invoked on if validation of a specific element after submit caused an error
      onSubmitValidationSuccess: (form) ->
        # function is invoked if everything is fine after submit
      onSubmitValidationError: (form) ->
        # function is invoked if there is one or more error in the form
      onEmpty: (elem) ->
        # function is invoked if element was emptied (after blur or keyUp)

      validateOnKeyUp: false
      validateOnBlur: true
      validateOnSubmit: true

      # defines wether the form's standard http POST functionality is used
      # you can specify your own actions on successful validation in onSubmitValidationSuccess()
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
        
        # --- VALIDATION ON KEYUP ---
        if settings.validateOnKeyUp
          @startKeyUpValidation()
        # --- VALIDATION ON BLUR ---
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

      # --- VALIDATION ON KEYUP ---
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
                  valObj.applyRules('onKeyUpValidation')
              else
                valObj.applyRules('onKeyUpValidation')
      
      # --- VALIDATION ON BLUR ---
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
      formObj = $(this)
      # --- VALIDATION ON SUBMIT ---
      if settings.validateOnSubmit
        $(this).on('submit', (e) ->
          # apply rules to all elements
          if(!applyAllRules(validationObjects))
            # one or more element validations failed
            e.preventDefault()
            settings.onSubmitValidationError(formObj)
          else
            if(!settings.useFormPOST)
              # user does not want to use the form's http POST
              e.preventDefault()
              settings.onSubmitValidationSuccess(formObj)
            else
              # invoke function when everything is fine
              settings.onSubmitValidationSuccess(formObj)
        )

      applyAllRules = (validationObjects) ->
        success = true
        for valObj in validationObjects
          if !valObj.applyRules('onSubmitElemValidation')
            success = false
        # false if one or more validations failed
        return success

isInObj = (aKey, obj) ->
  for key, val of obj
    return true if key == aKey
  return false

parseMsg = (msg, param) ->
  if msg.indexOf('%s') == -1
    return msg
  else 
    return msg.split('%s')[0] + param + msg.split('%s')[1]

