z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
_ = require 'lodash'
log = require 'loga'
Environment = require 'clay-environment'

config = require '../../config'
colors = require '../../colors'
DeckCards = require '../deck_cards'
Base = require '../base'
Icon = require '../icon'
Spinner = require '../spinner'

if window?
  require './index.styl'

CARDS_PER_ROW = 4
PADDING = 16

module.exports = class Decks extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    decksAndMe = Rx.Observable.combineLatest(
      @model.clashRoyaleDeck.getAll({sort, filter})
      me
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      filter: filter
      decks: decksAndMe.map ([decks, me]) =>
        _.map decks, (deck) =>
          hasDeck =  me.data.clashRoyaleDeckIds and
            me.data.clashRoyaleDeckIds.indexOf(deck.id) isnt -1

          $el = @getCached$ deck.id, DeckCards, {@model, @router, deck}
          {
            deck
            hasDeck
            $deck: $el
            $starIcon: new Icon()
            $chevronIcon: new Icon()
          }

  afterMount: (@$$el) => null

  render: =>
    {me, decks, filter} = @state.getValue()

    cardWidth = (@$$el?.children?[0]?.offsetWidth - (PADDING * 2)) /
                  CARDS_PER_ROW

    z '.z-decks',
      z '.decks', {
        # force scrollbar initially
        style:
          minHeight: "#{window?.innerHeight * 1.2}px"
      },
        if decks and _.isEmpty decks
          z '.no-decks',
            'No decks found. '
            if filter is 'mine'
              'Select a popular deck to add it, or create a new deck.'
        else if decks
          _.map decks, ({deck, hasDeck, $deck, $starIcon, $chevronIcon}) =>
            [
              @router.link z 'a.deck', {
                href: "/decks/#{deck.id}"
              },
                z '.g-grid',
                  z '.info',
                    z '.star',
                      z $starIcon,
                        icon: if hasDeck then 'star' else 'star-outline'
                        isAlignedLeft: true
                        color: if hasDeck \
                               then colors.$primary500
                               else colors.$white12
                        onclick: (e) =>
                          e?.stopPropagation()
                          e?.preventDefault()
                          if hasDeck
                            @model.clashRoyaleUserDeck.unfavorite {
                              deckId: deck.id
                            }
                          else
                            @model.clashRoyaleUserDeck.favorite {
                              deckId: deck.id
                            }
                    z '.name', deck.name or 'Nameless'
                    z '.chevron',
                      z $chevronIcon,
                        icon: 'chevron-right'
                        color: colors.$primary500
                        isTouchTarget: false
                  z '.cards',
                    $deck
              z '.divider'
            ]
        else
          @$spinner
