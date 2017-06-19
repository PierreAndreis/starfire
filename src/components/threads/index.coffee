z = require 'zorium'
moment = require 'moment'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_chunk = require 'lodash/chunk'
_filter = require 'lodash/filter'
_range = require 'lodash/range'
_find = require 'lodash/find'
_flatten = require 'lodash/flatten'
_isEmpty = require 'lodash/isEmpty'
_find = require 'lodash/find'

colors = require '../../colors'
Icon = require '../icon'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Threads
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()

    threads = Rx.Observable.combineLatest(
      @model.thread.getAll()
      @model.thread.getAll({sort: 'new', limit: 3})
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      chunkedThreads: threads.map ([popularThreads, newThreads]) ->
        # TODO: json file with these vars, stylus uses this
        if window?.matchMedia('(min-width: 768px)').matches
          cols = 2
        else
          cols = 1

        threads = popularThreads
        _map newThreads, (thread, i) ->
          unless _find threads, {id: thread.id}
            threads.splice (i + 1) * 2, 0, thread

        threads = _map threads, (thread) ->
          {
            thread
            $pointsIcon: new Icon()
            $commentsIcon: new Icon()
          }
        return _map _range(cols), (colIndex) ->
          _filter threads, (thread, i) -> i % cols is colIndex

  render: =>
    {me, chunkedThreads} = @state.getValue()

    z '.z-threads', [
      if chunkedThreads and _isEmpty chunkedThreads[0]
        z '.no-threads',
          'No threads found'
      else if chunkedThreads
        z '.g-grid',
          z '.columns',
            _map chunkedThreads, (threads) =>
              z '.column',
                _map threads, (properties) =>
                  {thread, $pointsIcon, $commentsIcon} = properties
                  imageAttachment = _find thread.attachments, {type: 'image'}
                  @router.link z 'a.thread', {
                    href: "/thread/#{thread.id}"
                  },
                    if imageAttachment
                      z '.image',
                        style:
                          backgroundImage: "url(#{imageAttachment.src})"
                    z '.content',
                      z '.title', thread.title
                      z '.info',
                        z '.author',
                          z '.name', @model.user.getDisplayName thread.creator
                          z '.middot',
                            innerHTML: '&middot;'
                          z '.time',
                            if thread.addTime
                            then moment(thread.addTime).fromNowModified()
                            else '...'
                          z '.comments',
                            thread.commentCount or 0
                            z '.icon',
                              z $commentsIcon,
                                icon: 'comment'
                                isTouchTarget: false
                                color: colors.$tertiary300
                                size: '14px'
                          z '.points',
                            (thread.upvotes - thread.downvotes) or 0
                            z '.icon',
                              z $pointsIcon,
                                icon: 'add-circle'
                                isTouchTarget: false
                                color: colors.$tertiary300
                                size: '14px'
      else
        @$spinner
    ]
