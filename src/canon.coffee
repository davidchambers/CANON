CANON = version: '0.1.1'
if typeof module isnt 'undefined' then module.exports = CANON
else window.CANON = CANON

CANON.stringify = do ->
  canonicalize = (value) ->
    switch Object::toString.call value
      when '[object Array]'
        ['Array', map(value, canonicalize)...]
      when '[object Date]'
        ['Date'].concat \
          if isFinite +value
            value.getUTCFullYear() +
            '-' + pad(value.getUTCMonth() + 1) +
            '-' + pad(value.getUTCDate()) +
            'T' + pad(value.getUTCHours()) +
            ':' + pad(value.getUTCMinutes()) +
            ':' + pad(value.getUTCSeconds()) +
            '.' + pad(value.getUTCMilliseconds(), 3) +
            'Z'
          else null
      when '[object Function]'
        throw new TypeError 'functions cannot be serialized'
      when '[object Number]'
        if isFinite(value) then value else ['Number', "#{value}"]
      when '[object Object]'
        pair = (key) -> [key, canonicalize value[key]]
        ['Object'].concat map(keys(value).sort(), pair)...
      when '[object RegExp]'
        ['RegExp', "#{value}"]
      when '[object Undefined]'
        ['Undefined']
      else value
  (value) ->
    if value is 0 and 1 / value is -Infinity then '-0'
    else JSON.stringify canonicalize value

CANON.parse = do ->
  canonicalize = (value) ->
    return value unless Object::toString.call(value) is '[object Array]'
    [what, elements...] = value
    [element] = elements
    switch what
      when 'Array'
        map elements, canonicalize
      when 'Date'
        new Date element
      when 'Number'
        +element
      when 'Object'
        object = {}
        for idx in [0...elements.length] by 2
          object[elements[idx]] = canonicalize elements[idx + 1]
        object
      when 'RegExp'
        new RegExp /^[/](.+)[/]([gimy]*)$/.exec(element)[1..]...
      when 'Undefined'
        undefined
      else throw new Error 'invalid input'
  (string) -> canonicalize JSON.parse string

nativeMap = Array::map
map = (array, iterator) ->
  if nativeMap and array.map is nativeMap then array.map iterator
  else (iterator el for el in array)

keys = Object.keys or (object) -> (key for own key of object)

pad = (n, min = 2) -> "#{1000 + n}".substr 4 - min
