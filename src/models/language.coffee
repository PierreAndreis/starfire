_reduce = require 'lodash/reduce'
_defaultsDeep = require 'lodash/defaultsDeep'
Rx = require 'rxjs'
moment = require 'moment'
_mapValues = require 'lodash/mapValues'
_keys = require 'lodash/keys'
_reduce = require 'lodash/reduce'
_findKey = require 'lodash/findKey'
_filter = require 'lodash/filter'

config = require '../config'

# missing: card_info, channel picker, edit group, edit group change badge
# events 'participants', 'begins', 'ends'
# group list 'members'
# thread points
# friendspage
# profile page share

files = {
  strings: null
  cards: null
  addons: null
  paths: null
  languages: null
  items: null
}

# also update gulpfile ContextReplacementPlugin for moment
files = _mapValues files, (val, file) ->
  en: try require "../lang/en/#{file}_en" catch e then null
  es: try require "../lang/es/#{file}_es" catch e then null
  it: try require "../lang/it/#{file}_it" catch e then null
  fr: try require "../lang/fr/#{file}_fr" catch e then null
  zh: try require "../lang/zh/#{file}_zh" catch e then null
  ja: try require "../lang/ja/#{file}_ja" catch e then null
  ko: try require "../lang/ko/#{file}_ko" catch e then null
  de: try require "../lang/de/#{file}_de" catch e then null
  pt: try require "../lang/pt/#{file}_pt" catch e then null
  pl: try require "../lang/pl/#{file}_pl" catch e then null

relativeTimeFormats =
  en:
    future: 'in %s'
    past: '%s'
    s: '1s'
    ss: '%ss'
    m: '1m'
    mm: '%dm'
    h: '1h'
    hh: '%dh'
    d: '1d'
    dd: '%dd'
    M: '1M'
    MM: '%dM'
    y: '1Y'
    yy: '%dY'
  es:
    future: 'in %s'
    past: '%s'
    s: '1s'
    ss: '%ss'
    m: '1m'
    mm: '%dm'
    h: '1h'
    hh: '%dh'
    d: '1d'
    dd: '%dd'
    M: '1S'
    MM: '%dS'
    y: '1A'
    yy: '%dA'

class Language
  constructor: ({language}) ->
    @language = new Rx.BehaviorSubject language
    @setLanguage language

  setLanguage: (language) =>
    @language.next language
    localStorage?['language'] = language
    relativeTime = relativeTimeFormats[language]
    moment.locale language, if relativeTime then {relativeTime} else undefined

    # change from 'a few seconds ago'
    justNowStr = @get 'time.justNow'

    moment.fn.fromNowModified = (a) ->
      if Math.abs(moment().diff(this)) < 30000
        # 1000 milliseconds
        return justNowStr
      @fromNow a

  getLanguage: => @language

  getLanguageStr: => @language.getValue()

  getAll: ->
    _keys files.paths

  getAllUrlLanguages: ->
    ['en', 'es', 'pt']

  # some of this would probably make more sense in router...
  getNonGamePages: ->
    [
      'policies', 'privacy', 'termsOfService'
    ]

  getRouteKeyByValue: (routeValue) =>
    language = @language.getValue()
    _findKey(files['paths'][language], (route) ->
      route is routeValue) or _findKey(files['paths']['en'], (route) ->
        route is routeValue)

  getAllPathsByRouteKey: (routeKey, isGamePath) =>
    languages = @getAllUrlLanguages()
    _reduce languages, (paths, language) ->
      path = files['paths'][language]?[routeKey]
      if path
        paths[language] = path
      paths
    , {}

  get: (strKey, {replacements, file, language} = {}) =>
    file ?= 'strings'
    language ?= @language.getValue()
    baseResponse = files[file][language]?[strKey] or
                    files[file]['en']?[strKey] or ''

    unless baseResponse
      console.log 'missing', file, strKey

    if typeof baseResponse is 'object'
      # some languages (czech) have many plural forms
      pluralityCount = replacements[baseResponse.pluralityCheck]
      baseResponse = baseResponse.plurality[pluralityCount] or
                      baseResponse.plurality.other or ''

    _reduce replacements, (str, replace, key) ->
      find = ///{#{key}}///g
      str.replace find, replace
    , baseResponse


module.exports = Language
