z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
_ = require 'lodash'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Conversations
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()
      conversations: @model.conversation.getAll().map (conversations) ->
        _.map conversations, (conversation) ->
          {conversation, $icon: new Icon()}

  render: =>
    {me, conversations} = @state.getValue()

    z '.z-conversations',
      z '.g-grid',
        if conversations and _.isEmpty conversations
          z '.no-conversations',
            'No conversations found'
        else if conversations
          _.map conversations, ({conversation, $icon}) =>

            @router.link z 'a.conversation', {
              href: "/conversation/#{conversation.id}"
            },
              z '.left',
                z '.name', conversation.name
                z '.games', _.map(conversation.gameKeys, _.startCase).join ' · '
                z '.info', 'test'
              z '.right',
                z $icon,
                  icon: conversation.platform
                  isTouchTarget: false
                  color: colors["$#{conversation.platform}"]

        else
          @$spinner
