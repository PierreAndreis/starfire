z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
Rx = require 'rx-lite'
Environment = require 'clay-environment'

AdsenseAd = require '../adsense_ad'
PrimaryButton = require '../primary_button'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileChests
  constructor: ({@model, @router, player}) ->
    @$adsenseAd = new AdsenseAd()
    @$shareButton = new PrimaryButton()

    @state = z.state {
      me: @model.user.getMe()
      player: player
    }

  render: =>
    {player, me} = @state.getValue()

    isNative = Environment.isGameApp config.GAME_KEY
    isVerified = player?.isVerified

    z '.z-profile-chests',
      z '.g-grid',
        z '.title', @model.l.get 'profileChests.chestsTitle'
        z '.chests', {
          ontouchstart: (e) ->
            e?.stopPropagation()
        },
          _map player?.data.chestCycle.chests, (chest, i) ->
            if i is player?.data.chestCycle.countUntil.superMagical
              chest = 'super_magical'
            else if i is player?.data.chestCycle.countUntil.legendary
              chest = 'legendary'
            else if i is player?.data.chestCycle.countUntil.epic
              chest = 'epic'
            z '.chest',
              z 'img',
                src: "#{config.CDN_URL}/chests/#{chest}_chest.png"
                width: 90
                height: 90
              z '.count',
                if i is 0 then 'Next' else "+#{i + 1}"
        z '.title', @model.l.get 'profileChests.chestsUntilTitle'
        z '.chests-until',
          z '.chest',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/super_magical_chest.png)"
            z '.info',
              z '.name', 'Super Magical'
              z '.count',
                "+#{player?.data.chestCycle.countUntil.superMagical + 1}"

          if player?.data.chestCycle.countUntil.legendary
            z '.chest',
              z '.image',
                style:
                  backgroundImage:
                    "url(#{config.CDN_URL}/chests/legendary_chest.png)"
              z '.info',
                z '.name', 'Legendary'
                z '.count',
                  "+#{player?.data.chestCycle.countUntil.legendary + 1}"

          if player?.data.chestCycle.countUntil.epic
            z '.chest',
              z '.image',
                style:
                  backgroundImage:
                    "url(#{config.CDN_URL}/chests/epic_chest.png)"
              z '.info',
                z '.name', 'Epic'
                z '.count',
                  "+#{player?.data.chestCycle.countUntil.epic + 1}"

        z @$shareButton,
          text: @model.l.get 'general.share'
          onclick: =>
            @model.portal.call 'share.any', {
              text: ''
              image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{me?.id}.png"
              path: if me?.username \
                    then "/user/#{me.username}/chests"
                    else "/user/id/#{me?.id}/chests"
            }

        if Environment.isMobile() and not Environment.isGameApp(config.GAME_KEY)
          z '.ad',
            z @$adsenseAd, {
              slot: 'mobile320x50'
            }
        else if not Environment.isMobile()
          z '.ad',
            z @$adsenseAd, {
              slot: 'desktop728x90'
            }