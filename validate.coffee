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
      onFocusOutValidationSuccess: (elem, valrule) ->
      onFocusOutValidationError: (elem, valrule) ->

      valrules: 
        fullname: 
          valfun: (str) ->
            exp = /^[a-zA-ZÖÜÄßöüäøñ]{2,}(\s[a-zA-ZÖÜÄßöüäøñ]{2,}){1,3}$/ # Two words with two or more characters (Umlauts and some other crazy letters are allowed)
            if(str.match(exp) != null)
              return true
            else
              return false
          successmsg: 'We got a full name! Awesome!'
          errormsg: 'You have to provide a full name, asshole!'
        #email:
        #  valfun:


    # Merge default settings with options.
    settings = $.extend settings, options

    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    # _Insert magic here._
    return @each ()->
      
      watchForm = (elem) ->
        # start event listeners?
        # here
        # input form fields
        if (!elem.is('select'))
          valrule = settings.valrules[elem.data('valrule')]
          minval = elem.data('minval')
          if valrule?
            # if keyup validation is activated
            elem.on 'keyup', (e) ->
              if (e.which == 13)
                e.preventDefault() # TODO: this does not work!
              else 
                if minval?
                  if (elem.val().length >= parseInt(minval))
                  # startValidation
                    # factor out the following (e.g. applyRule())
                    if(valrule.valfun((elem.val()))) # TODO: validate more than one rule at once
                      settings.onKeyupValidationSuccess(elem, valrule)
                      console.log('success triggered')
                    else
                      settings.onKeyupValidationError(elem, valrule)
                      console.log('error triggered')
                else
                  # validateAnyway
                  if(valrule.valfun((elem.val())))
                    settings.onKeyupValidationSuccess(elem, valrule)
                  else
                    settings.onKeyupValidationError(elem, valrule)

      # on: keyup: just change class (red, green border)
      # on focus out: do a popup if validation fails

      log "Preparing magic show."
      
      $(this).find('input, select, textarea').each((i) ->
        watchForm($(this))
      )
      
      # You can use your settings in here now.
      # log "Option 1 value: #{settings.option1}"