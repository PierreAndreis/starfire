_camelCase = require 'lodash/camelCase'

module.exports = class ClashRoyaleCard
  namespace: 'clashRoyaleCards'

  constructor: ({@auth, @l}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getByKey: (key) =>
    @auth.stream "#{@namespace}.getByKey", {key}

  getTop: ({gameType}) =>
    @auth.stream "#{@namespace}.getTop", {gameType}

  getChestCards: ({arena, chest}) =>
    @auth.call "#{@namespace}.getChestCards", {arena, chest}

  getNameTranslation: (key, language) =>
    unless key
      return ''
    @l.get "crCard.#{_camelCase key.replace(/\./, '')}", {file: 'cards'}
