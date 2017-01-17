z = require 'zorium'
Rx = require 'rx-lite'
_filter = require 'lodash/filter'
FloatingActionButton = require 'zorium-paper/floating_action_button'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
GroupInfo = require '../../components/group_info'
GroupChat = require '../../components/group_chat'
GroupAnnouncements = require '../../components/group_announcements'
GroupMembers = require '../../components/group_members'
ProfileDialog = require '../../components/profile_dialog'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

TABS = ['chat', 'info', 'announcements', 'members']

module.exports = class GroupPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    selectedProfileDialogUser = new Rx.BehaviorSubject null
    selectedIndex = new Rx.BehaviorSubject 0

    overlay$ = new Rx.BehaviorSubject null

    groupId = requests.map ({route}) ->
      route.params.id

    conversationId = requests.map ({route}) ->
      route.params.conversationId

    group = groupId.flatMapLatest (groupId) =>
      @model.group.getById groupId

    me = @model.user.getMe()

    groupAndConversationIdAndMe = Rx.Observable.combineLatest(
      group
      conversationId
      me
      (vals...) -> vals
    )

    @$head = new Head({
      @model
      requests
      serverData
      # FIXME: doesn't currently work
      # https://github.com/claydotio/zorium/commit/42f5e05f109b9954f056fb2bab3dba48fd43e90c
      meta: null
      # group.map (group) ->
      #   title: group.name
      #   description: group.name
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$tabs = new Tabs {@model, selectedIndex}
    @$groupInfo = new GroupInfo {@model, @router, group}
    @$groupChat = new GroupChat {
      @model
      @router
      group
      selectedProfileDialogUser
      overlay$
      toggleIScroll: @$tabs.toggle
      isActive: selectedIndex.map (index) ->
        index is 1
      conversation: groupAndConversationIdAndMe
      .flatMapLatest ([group, conversationId, me]) =>
        hasMemberPermission = @model.group.hasPermission group, me
        conversationId ?= localStorage?['conversationId:' + group.id] or
                            group.conversations[0].id
        if hasMemberPermission
          @model.conversation.getById conversationId
        else
          Rx.Observable.just null
    }
    @$groupAnnouncements = new GroupAnnouncements {@model, @router, group}
    @$groupMembers = new GroupMembers {
      @model, @router, group, selectedProfileDialogUser
    }
    @$editIcon = new Icon()
    @$settingsIcon = new Icon()
    @$groupInfoIcon = new Icon()
    @$groupChatIcon = new Icon()
    @$groupAnnouncementsIcon = new Icon()
    @$groupMembersIcon = new Icon()
    @$fab = new FloatingActionButton()
    @$plusIcon = new Icon()
    @$profileDialog = new ProfileDialog {
      @model
      @router
      selectedProfileDialogUser
      group
    }

    @state = z.state
      group: group
      me: me
      overlay$: overlay$
      selectedProfileDialogUser: selectedProfileDialogUser
      windowSize: @model.window.getSize()
      selectedIndex: selectedIndex

  renderHead: => @$head

  render: =>
    {group, me, overlay$, selectedProfileDialogUser, selectedIndex,
      windowSize} = @state.getValue()

    hasMemberPermission = @model.group.hasPermission group, me
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.p-group', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: group?.name
        bgColor: colors.$tertiary700
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
        $topRightButton:
          z '.p-group_top-right',
            z '.icon',
              if hasAdminPermission
                z @$editIcon,
                  icon: 'edit'
                  color: colors.$primary500
                  onclick: =>
                    @router.go "/group/#{group?.id}/edit"
            z '.icon',
              z @$settingsIcon,
                icon: 'settings'
                color: colors.$primary500
                onclick: =>
                  @router.go "/group/#{group?.id}/settings"

      }
      # don't load prematurely, or 4 tabs will go to 2 and break vDomKey
      if group and me
        z @$tabs,
          isBarFixed: false
          isBarFlat: true
          barBgColor: colors.$tertiary700
          barInactiveColor: colors.$white
          tabs: _filter [
            if hasMemberPermission
              {
                $menuIcon: @$groupChatIcon
                menuIconName: 'hashtag'
                $menuText: 'Chat'
                $el: @$groupChat
              }
            {
              $menuIcon: @$groupInfoIcon
              menuIconName: 'info'
              $menuText: 'Info'
              $el: @$groupInfo
            }
            if hasMemberPermission
              {
                $menuIcon: @$groupAnnouncementsIcon
                menuIconName: 'notes'
                $menuText: 'Announcements'
                $el: @$groupAnnouncements
              }
            {
              $menuIcon: @$groupMembersIcon
              menuIconName: 'friends'
              $menuText: 'Members'
              $el: @$groupMembers
            }
          ]
      if TABS[selectedIndex] is 'members' and hasAdminPermission
        z '.fab',
          z @$fab,
            colors:
              c500: colors.$primary500
            $icon: z @$plusIcon, {
              icon: 'add'
              isTouchTarget: false
              color: colors.$white
            }
            onclick: =>
              tab = TABS[selectedIndex]
              if tab is 'members' and hasAdminPermission
                @router.go "/group/#{group?.id}/invite"
      if overlay$
        z '.overlay',
          overlay$

      if selectedProfileDialogUser
        z @$profileDialog
