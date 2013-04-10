# TODO: HTML5 validation?
# TODO: Use jQuery events?


# invoke:
# $("form").validate

if !valMessages?
  valMessages = 
    validateRequired:
      successmsg: ''
      errormsg: 'I am sorry but this is required!'
    validateRangeLength:
      successmsg: ''
      errormsg: 'Sorry, the length is meant to be between %s and %s characters!'
    validateMinLength:
      successmsg: ''
      errormsg: 'Please provide at least %s characters'
    validateEmail:
      successmsg: ''
      errormsg: 'This does not look like a valid E-Mail address to me'
    validateRegexp:
      successmsg: ''
      errormsg: 'Something is wrong!'

valConstraints =
  validateRequired: () ->
    valfun: (str) ->
      # since this is validateRequired str.length has to be > 0
      return if str.length >= 1 then true else false
    successmsg: valMessages.validateRequired.successmsg
    errormsg: valMessages.validateRequired.errormsg

  validateRangeLength: (ml) ->
    valfun: (str) ->
      return if ml[0] <= str.length <= ml[1] then true else false
    successmsg: parseMsg(valMessages.validateRangeLength.successmsg, ml)
    errormsg: parseMsg(valMessages.validateRangeLength.errormsg, ml)

  validateMinLength: (rl) ->
    valfun: (str) ->
      return if str.length >= parseInt(rl) then true else false
    successmsg: parseMsg(valMessages.validateMinLength.successmsg, rl)
    errormsg: parseMsg(valMessages.validateMinLength.errormsg, rl)

  validateEmail: () ->
    valfun: (str) ->
      # very simple regex for email validation
      # read: http://davidcel.is/blog/2012/09/06/stop-validating-email-addresses-with-regex/
      exp = /^(.{1,})@(.{1,})\.(.{1,})$/
      return if str.match(exp)? then true else false
    successmsg: valMessages.validateEmail.successmsg
    errormsg: valMessages.validateEmail.errormsg

  validateRegexp: (exp) ->
    valfun: (str) ->
    # TODO: is exp a string or a regex obj? 
      return if str.match(exp)? then true else false
    successmsg: valMessages.validateRegexp.successmsg
    errormsg: valMessages.validateRegexp.errormsg

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
        hideMessages(elem)
      onKeyUpValidationError: (elem, messages) ->
        # function is invoked if KeyUp validation caused an error
        hideMessages(elem)
        showMessages(elem, messages)
      onBlurValidationSuccess: (elem, messages) ->
        # function is invoked if validation after blur was successful
        hideMessages(elem)
      onBlurValidationError: (elem, messages) ->
        # function is invoked if validation after caused an error
        hideMessages(elem)
        showMessages(elem, messages)
      onSubmitElemValidationSuccess: (elem, messages) ->
        # function is invoked if validation of a specific element after submit was successful
        hideMessages(elem)
      onSubmitElemValidationError: (elem, messages) ->
        # function is invoked if validation of a specific element after submit caused an error
        hideMessages(elem)
        showMessages(elem, messages)
      onSubmitValidationSuccess: (form) ->
        # function is invoked if everything is fine after submit
      onSubmitValidationError: (form) ->
        # function is invoked if there is one or more error in the form
      onEmpty: (elem) ->
        # function is invoked if element was emptied (after blur or keyUp)
        hideMessages(elem)

      validateOnKeyUp: false
      validateOnBlur: true
      validateOnSubmit: true

      # defines wether the form's standard http POST functionality is used
      # you can specify your own actions on successful validation in onSubmitValidationSuccess()
      useFormPOST: true

      # class names to apply on ul and li of error lists
      ulClass: 'valUl'
      liClass: 'valLi'

    # Merge default settings with options.
    settings = $.extend settings, options

    # functions for default errorList DOM manipulation
    hideMessages = (elem) ->
      errorList = elem.next('ul')
      errorList.remove()

    showMessages = (elem, messages) ->
      $messages = messages.failed.map(createLi)
      errorList = $('<ul>').addClass(settings.ulClass)
      for message in $messages
        errorList.append(message)
      errorList.insertAfter(elem)

    createLi = (error) ->
      return $('<li>' + error + '</li>').addClass(settings.liClass)

    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    class ValidationObj
      constructor: (@elem) ->
        @data = @elem.data()
        @valFuncs = @parseValFuncs()
        @minval = @elem.data('validate-minval') || 0
        # start event listeners
        
        # keyup and blur validation for input and textarea elements
        if @elem.is('input') or @elem.is('textarea')
          # --- VALIDATION ON KEYUP ---
          if settings.validateOnKeyUp
            @startKeyUpValidation()
          # --- VALIDATION ON BLUR ---
          if settings.validateOnBlur
            @startBlurValidation()
        
        # click validation for select and checkbox elements
        if @elem.is('select') or @elem.is('checkbox')
          @startClickValidation()

      parseValFuncs: () ->
        # override standard messages with self-defined ones in HTML attributes.
        # e.g. <input data-validate-email-errormsg="Error in E-Mail!">
        errexp = /^(.*)Errormsg$/
        succexp = /^(.*)Successmsg$/
        for valkey, value of @data
          errfunc = valkey.match(errexp)
          succfunc = valkey.match(succexp)
          if errfunc?
            if errfunc[1]?
              valMessages[errfunc[1]].errormsg = value
          if succfunc?
            if succfunc[1]?
              valMessages[succfunc[1]].successmsg = value
        valFuncs = {}
        for func, value of @data
          valFuncs[func] = (valConstraints[func](value)) if member(func, valConstraints)
        return valFuncs

      # --- VALIDATION ON KEYUP ---
      startKeyUpValidation: () ->
        valObj = @
        @elem.on 'keyup', (e) ->
          if valObj.elem.val() == '' && e.which != 13
            settings.onEmpty(valObj.elem)
          else
            if valObj.minval?
              if (valObj.elem.val().length >= parseInt(valObj.minval))
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

      # --- VALIDATION ON CLICK ---
      startClickValidation: () ->
      
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

member = (aKey, obj) ->
  # checks for element if array or key if object
  if Array.isArray(obj)
    for elem in obj
      return true if elem == aKey
  else
    for key, val of obj
      return true if key == aKey
  return false

parseMsg = (msg, params) ->
  if msg.indexOf('%s') == -1
    return msg
  else
    if typeof(params) is 'object'
      message = msg.split('%s')[0]
      for param, i in params
        message += param + msg.split('%s')[i+1]
      return message
    else
      return msg.split('%s')[0] + params + msg.split('%s')[1]
