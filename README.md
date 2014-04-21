# CANON

CANON is canonical object notation. It closely resembles JSON. In fact,
`CANON.stringify` and `CANON.parse` make use of their `JSON` counterparts
internally.

### What's wrong with JSON?

JSON is great for passing around serialized data. There's a second reason
one might wish to serialize data, though: to implement efficient sets and
dictionaries, two useful data structures JavaScript currently lacks.

In order to implements sets and dictionaries efficiently, one needs to be
able to hash values consistently. `JSON.stringify` does not guarantee the
order of object keys, so cannot be relied upon.

### Implementing sets with CANON

The only data structure JavaScript currently provides for dealing with unique
collections is the humble object. Only strings can be used as keys, though, so
it's necessary to serialize each value that's added to the set. This yields a
data structure mapping serialized values to the values themselves:

```text
CANON.stringify(value1) ➞ value1
CANON.stringify(value2) ➞ value2
...
CANON.stringify(valueN) ➞ valueN
```

To limit the length of the keys (and thus the memory footprint), a hashing
function can be used:

```text
sha256(CANON.stringify(value1)) ➞ value1
sha256(CANON.stringify(value2)) ➞ value2
...
sha256(CANON.stringify(valueN)) ➞ valueN
```

A simple set implementation might resemble the following:

```coffeescript
hash = (value) -> sha256 CANON.stringify value

class Set
  constructor: (values...) ->
    @values = {}
    @add values...
  contains: (value) ->
    Object::hasOwnProperty.call @values, hash value
  add: (values...) ->
    for value in values
      @values[hash value] = value
    return
  remove: (values...) ->
    for value in values
      delete @values[hash value]
    return
  each: (iterator) ->
    for own key, value of @values
      iterator value
    return
```

```coffeescript
coffee> points = new Set [1,2], [5,2], [3,6]
{ values:
   { '736e4ff990cbad3e9ed1b2d78abfea3bd73a5e773960f40fbbc42e490df999bf': [ 1, 2 ],
     '41cc5c39058d6626dfa57703740a21676229901e1a26f844fc96cb7462e05828': [ 5, 2 ],
     'cd326a88a511fc5ca7831944f0f2a3091273faf7e5fbec3f8e482ace48392657': [ 3, 6 ] } }
coffee> points.contains [4,4]
false
coffee> points.contains [5,2]
true
coffee> points.each (point) -> console.log point
[ 1, 2 ]
[ 5, 2 ]
[ 3, 6 ]
undefined
```

### Differences between CANON and JSON

```javascript
> CANON.stringify(-0)                       > JSON.stringify(-0)
'-0'                                        '0'
> CANON.stringify([1, 2, 3])                > JSON.stringify([1, 2, 3])
'["Array",1,2,3]'                           '[1,2,3]'
> CANON.stringify(new Date(1350246457000))  > JSON.stringify(new Date(1350246457000))
'["Date","2012-10-14T20:27:37.000Z"]'       '"2012-10-14T20:27:37.000Z"'
> CANON.stringify(Infinity)                 > JSON.stringify(Infinity)
'["Number","Infinity"]'                     'null'
> CANON.stringify(-Infinity)                > JSON.stringify(-Infinity)
'["Number","-Infinity"]'                    'null'
> CANON.stringify(NaN)                      > JSON.stringify(NaN)
'["Number","NaN"]'                          'null'
> CANON.stringify({foo:1, bar:2})           > JSON.stringify({foo:1, bar:2})
'["Object","bar",2,"foo",1]'                '{"foo":1,"bar":2}'
> CANON.stringify(/foo/i)                   > JSON.stringify(/foo/i)
'["RegExp","/foo/i"]'                       '{}'
> CANON.stringify(undefined)                > JSON.stringify(undefined)
'["Undefined"]'                             undefined
> CANON.stringify(function(){})             > JSON.stringify(function(){})
TypeError: Functions cannot be serialized   undefined
```

From the output of `JSON.stringify` it's not always possible to determine the
input value:

```javascript
> JSON.stringify(new Date(1350246457000)) === JSON.stringify('2012-10-14T20:27:37.000Z')
true
```

Since `CANON.stringify` includes type information for most values, different
values with the same string representation (such as `/foo/i` and `'/foo/i'`)
are serialized differently. As a result, `CANON.parse` can materialize Date
and RegExp objects:

```javascript
> CANON.parse(CANON.stringify(new Date(1350246457000))) instanceof Date
true
> JSON.parse(JSON.stringify(new Date(1350246457000))) instanceof Date
false
```

### Installation

Browser:

```html
<script src="https://raw.github.com/davidchambers/CANON/master/lib/canon.js"></script>
```

Server:

```text
$ npm install canon
```

### Running the test suite

```text
$ make setup
$ make test
```

To run the test suite in a browser, open __test/index.html__.

### Related projects

  - [mirkokiefer/canonical-json](https://github.com/mirkokiefer/canonical-json)
