z = require 'zorium'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Tabs = require '../../components/tabs'
EarnFire = require '../../components/earn_fire'
SpendFire = require '../../components/spend_fire'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class FirePage
  constructor: ({@model, requests, @router, serverData, @overlay$}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'firePage.title'
        description: @model.l.get 'firePage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$tabs = new Tabs {@model}

    @$earnFire = new EarnFire {@model, @router, gameKey, @overlay$}
    @$spendFire = new SpendFire {@model, @router, gameKey, @overlay$}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-fire', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'firePage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
        z @$tabs,
          isBarFixed: false
          hasAppBar: true
          tabs: [
            {
              $menuText: @model.l.get 'general.earn'
              $el: z @$earnFire
            }
            {
              $menuText: @model.l.get 'general.spend'
              $el: z @$spendFire
            }
          ]
