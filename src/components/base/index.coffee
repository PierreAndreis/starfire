module.exports = class Base
  getCached$: (id, component, args...) =>
    @cachedComponents or= []

    if @cachedComponents[id]
      return @cachedComponents[id]
    else
      $component = new component args...
      @cachedComponents[id] = $component
      return $component

  beforeUnmount: =>
    @cachedComponents = []
