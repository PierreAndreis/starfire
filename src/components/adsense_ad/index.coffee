z = require 'zorium'

colors = require '../../colors'

CLIENT = 'ca-pub-9043203456638369'
slots =
  desktop728x90:
    slot: '3445650539'
    width: 728
    height: 90
  mobile320x50:
    slot: '3284200136'
    width: 320
    height: 50
  desktop336x280:
    slot: '2577692937'
    width: 336
    height: 280
  mobile300x250:
    slot: '4972756133'
    width: 300
    height: 250

module.exports = class AdsenseAd
  constructor: ->
    @unique = Math.random()

  afterMount: ->
    console.log 'mount ad'
    if window?
      setTimeout ->
        (window.adsbygoogle = window.adsbygoogle or []).push({})
      , 500

  render: ({slot} = {}) =>
    slotInfo = slots[slot]

    unless slotInfo
      return

    z '.z-adsense-ad', {
      key: "adsense-#{@unique}"
    },
      z 'ins',
        key: "adsense-#{@unique}-ins"
        className: 'adsbygoogle'
        style:
          display: 'block'
          width: "#{slotInfo.width}px"
          height: "#{slotInfo.height}px"
          margin: '0 auto'
          backgroundColor: colors.$tertiary700
        attributes:
          'data-ad-client': CLIENT
          'data-ad-slot': slotInfo.slot
          # 'data-ad-format': format