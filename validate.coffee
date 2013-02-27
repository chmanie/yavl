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
      onEmpty: (elem) ->
        console.log('emptied')

      valrules: 
        fullname: 
          valfun: (str) ->
            # dash ( - ) !!!
            exp = /^[a-zA-ZÖÜÄßöüäøñ]{2,}(\s[a-zA-ZÖÜÄßöüäøñ]{2,}){1,3}$/ # Two words with two or more characters (Umlauts and some other crazy letters are allowed)
            if(str.match(exp) != null) # TODO: abkürzen ? :
              return true
            else
              return false
          successmsg: 'We got a full name! Awesome!'
          errormsg: 'You have to provide a full name, asshole!'
        required:
          valfun: (str) ->
            if str.length < 1 # TODO: abkürzen ? :
              return false
            else
              return true
          successmsg: 'You were right, this is fuckin required'
          errormsg: 'You have to fill this, man!'
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
        # TODO: remove errors if field is empty
        valrules = elem.data('valrules')
        if valrules?
          valrules = elem.data('valrules').split(' ')
          # if keyup validation is activated
          if settings.validateOnKeyUp
            minval = elem.data('minval')
            elem.on 'keyup', (e) ->
              if elem.val() == ''
                settings.onEmpty(elem)
              else
                if (e.which == 13)
                  e.preventDefault() # TODO: this does not work!
                else 
                  if minval?
                    if (elem.val().length >= parseInt(minval))
                      applyRules(elem, valrules, 'onKeyupValidation')
                  else
                    applyRules(elem, valrules, 'onKeyupValidation')

          # if blur validation is activated
          if settings.validateOnBlur
            elem.on 'blur', (e) ->
              console.log('blur fired')
              if elem.val() != ''
                applyRules(elem, valrules, 'onBlurValidation')

      applyRules = (elem, valrules, eventFunc) ->
        valrules = valrules.map (valrule) -> settings.valrules[valrule]
        failed = failedFuncs(valrules, elem.val())
        if(failed.length == 0)
          settings[eventFunc + 'Success'](elem, valrules)
        else
          # es müssen die errors übermittelt werden
          settings[eventFunc + 'Error'](elem, failed)

      failedFuncs = (valrules, param) ->
        failed = []
        for valrule in valrules
          if valrule.valfun(param) is false
            failed.push(valrule) #evtl nur die msg?
        console.log(failed)
        return failed

      # on: keyup: just change class (red, green border)
      # on focus out: do a popup if validation fails

      log "Preparing magic show."
      
      $(this).find('input, select, textarea').each((i) ->
        watchForm($(this))
      )
      
      # You can use your settings in here now.
      # log "Option 1 value: #{settings.option1}"