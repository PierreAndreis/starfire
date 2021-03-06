z = require 'zorium'
Rx = require 'rxjs'
_defaults = require 'lodash/defaults'

allColors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Input
  constructor: ({@value, @valueStreams, @error, @isFocused} = {}) ->
    @value ?= new Rx.BehaviorSubject ''
    @error ?= new Rx.BehaviorSubject null

    @isFocused ?= new Rx.BehaviorSubject false

    @state = z.state {
      isFocused: @isFocused
      value: @valueStreams?.switch() or @value
      error: @error
    }

  render: (props) =>
    {colors, hintText, type, isFloating, isDisabled,
      isDark, isCentered} = props

    {value, error, isFocused} = @state.getValue()

    colors = _defaults colors, {
      c500: allColors.$black
      background: allColors.$white12
      underline: allColors.$primary500
    }
    hintText ?= ''
    type ?= 'text'
    isFloating ?= false
    isDisabled ?= false

    z '.z-input',
      className: z.classKebab {
        isDark
        isFloating
        hasValue: value isnt ''
        isFocused
        isDisabled
        isCentered
        isError: error?
      }
      style:
        backgroundColor: colors.background
      z '.hint', {
        # style:
        #   color: if isFocused and not error? \
        #          then colors.c500 else null
      },
        hintText
      z 'input.input',
        attributes:
          disabled: if isDisabled then true else undefined
          type: type
        value: value
        oninput: z.ev (e, $$el) =>
          if @valueStreams
            @valueStreams.next Rx.Observable.of $$el.value
          else
            @value.next $$el.value
        onfocus: z.ev (e, $$el) =>
          @isFocused.next true
        onblur: z.ev (e, $$el) =>
          @isFocused.next false
      z '.underline-wrapper',
        z '.underline',
          style:
            backgroundColor: if isFocused and not error? \
                             then colors.underline or colors.c500 else null
      if error?
        z '.error', error
