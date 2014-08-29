CANON = version: '0.3.0'
if typeof module isnt 'undefined' and 'exports' of module
  module.exports = CANON
else
  window.CANON = CANON


CANON.stringify = do ->
  canonicalize = (value) ->
    if value is null
      null
    else if value is undefined
      ['Undefined']
    else if isArguments value
      ['Arguments', map(value, canonicalize)...]
    else switch toString.call value
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
        throw new TypeError 'Functions cannot be serialized'
      when '[object Number]'
        if isFinite(value) then value else ['Number', "#{value}"]
      when '[object Object]'
        list = ['Object']
        list.push key, canonicalize value[key] for key in keys(value).sort()
        list
      when '[object RegExp]'
        ['RegExp', "#{value}"]
      else value
  (value) ->
    if value is 0 and 1 / value is -Infinity then '-0'
    else JSON.stringify canonicalize value


CANON.parse = do ->
  canonicalize = (value) ->
    return value unless toString.call(value) is '[object Array]'
    [what, elements...] = value
    [element] = elements
    switch what
      when 'Arguments'
        (-> arguments) map(elements, canonicalize)...
      when 'Array'
        map elements, canonicalize
      when 'Date'
        [year, month, rest...] = map element.match(/\d+/g), Number
        new Date Date.UTC year, month - 1, rest...
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
      else throw new Error 'Invalid input'
  (string) ->
    if string is '-0' then -0 else canonicalize JSON.parse string


{hasOwnProperty, toString} = Object.prototype

# Support runtimes without an inspectable Arguments type.
isArguments = do ->
  if toString.call(arguments) is '[object Arguments]'
    (value) -> toString.call(value) is '[object Arguments]'
  else
    (value) -> value? and hasOwnProperty.call value, 'callee'


nativeMap = Array::map
map = (array, iterator) ->
  if nativeMap and array.map is nativeMap then array.map iterator
  else (iterator el for el in array)


keys = Object.keys or (object) -> (key for own key of object)


pad = (n, min = 2) -> "#{1000 + n}".substr 4 - min
