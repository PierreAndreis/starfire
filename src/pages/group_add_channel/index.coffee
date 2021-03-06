z = require 'zorium'

Head = require '../../components/head'
GroupEditChannel = require '../../components/group_edit_channel'

if window?
  require './index.styl'

module.exports = class GroupAddChannelPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) ->
      model.group.getById route.params.id

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'groupAddChannelPage.title'
        description: model.l.get 'groupAddChannelPage.title'
      }
    })
    @$groupEditChannel = new GroupEditChannel {
      model, @router, serverData, group, gameKey
    }

    @state = z.state
      group: group
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {group, windowSize} = @state.getValue()

    z '.p-group-add-channel', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$groupEditChannel, {isNewChannel: true}
