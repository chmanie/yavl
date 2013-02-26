# invoke:
# $("form").validate
#   debug: true

# Reference jQuery
$ = jQuery

# Adds plugin object to jQuery
$.fn.extend
  # Change pluginName to your plugin's name.
  validate: (options) ->
    # Default settings
    settings =
      debug: false

    # Merge default settings with options.
    settings = $.extend settings, options

    # Simple logger.
    log = (msg) ->
      console?.log msg if settings.debug

    # _Insert magic here._
    return @each ()->

      valrules = 
        fullname: (str) ->
          exp = /[a-zA-ZÖÜÄßöüäø]{2,}\s[a-zA-ZÖÜÄßöüäø]{2,}/ # Two words with two or more characters (Umlauts and some other crazy letters are allowed)
          if(str.match(exp) != null)
            return true
          else
            return false
      
      watchForm = (elem) ->
        # input form fields
        if (!elem.is('select'))
          # TODO factor out start
          elem.on 'keyup', (e) ->
            if (e.which == 13)
              e.preventDefault() # TODO does not work!
            if (e.which != 8)
          # factor out end
              if (elem.val().length > parseInt(elem.data('minval')))
                # startValidation
                if(valrules[elem.data('valrule')](elem.val()))
                  alert('we got a Full name!!! this is awesome')

      # on: keyup: just change class (red, green border)
      # on focus out: do a popup if validation fails

      log "Preparing magic show."
      
      $(this).children('input, select, textarea').each((i) ->
        watchForm($(this))
      )
      
      # You can use your settings in here now.
      # log "Option 1 value: #{settings.option1}"