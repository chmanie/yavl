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
      onKeyupValidationSuccess: (elem, valrule) ->
      onKeyupValidationError: (elem, valrule) ->
      onBlurValidationSuccess: (elem, valrule) ->
        console.log('blur succ!')
      onBlurValidationError: (elem, valrule) ->
        console.log('blur err!')

      valrules: 
        fullname: 
          valfun: (str) ->
            # dash ( - ) !!!
            exp = /^[a-zA-ZÖÜÄßöüäøñ]{2,}(\s[a-zA-ZÖÜÄßöüäøñ]{2,}){1,3}$/ # Two words with two or more characters (Umlauts and some other crazy letters are allowed)
            if(str.match(exp) != null)
              return true
            else
              return false
          successmsg: 'We got a full name! Awesome!'
          errormsg: 'You have to provide a full name, asshole!'
        #minchars: 
        #   valfun
        #email:
        #  valfun:
      validateOnKeyUp: false
      validateOnBlur: true
      validateOnSubmit: true


    # Merge default settings with options.
    settings = $.extend settings, options

    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    # _Insert magic here._
    return @each ()->
      
      watchForm = (elem) ->
        # input form fields
        valrule = settings.valrules[elem.data('valrule')]
        if valrule?
          # if keyup validation is activated
          if settings.validateOnKeyUp
            minval = elem.data('minval')
            elem.on 'keyup', (e) ->
              if (e.which == 13)
                e.preventDefault() # TODO: this does not work!
              else 
                if minval?
                  if (elem.val().length >= parseInt(minval))
                    applyRule(elem, valrule, 'onKeyupValidation')
                else
                  applyRule(elem, valrule, 'onKeyupValidation')

          # if blur validation is activated
          if settings.validateOnBlur
            elem.on 'blur', (e) ->
              applyRule(elem, valrule, 'onBlurValidation')

      applyRule = (elem, valrule, eventFunc) ->
        if(valrule.valfun((elem.val())))
          settings[eventFunc + 'Success'](elem, valrule)
        else
          settings[eventFunc + 'Error'](elem, valrule)

      # on: keyup: just change class (red, green border)
      # on focus out: do a popup if validation fails

      log "Preparing magic show."
      
      $(this).find('input, select, textarea').each((i) ->
        watchForm($(this))
      )
      
      # You can use your settings in here now.
      # log "Option 1 value: #{settings.option1}"