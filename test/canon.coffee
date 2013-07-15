{deepEqual, notStrictEqual, strictEqual, throws} = require 'assert'
{parse, stringify} = require '../src/canon'


describe 'CANON', ->

  describe '.stringify', ->

    it 'serializes atomic values in the same manner as JSON.stringify', ->
      strictEqual stringify(true),      'true'
      strictEqual stringify(false),     'false'
      strictEqual stringify(null),      'null'
      strictEqual stringify(0),         '0'
      strictEqual stringify('foo bar'), '"foo bar"'

    it 'serializes negative zero', ->
      strictEqual stringify(-0),        '-0'

    it 'serializes nonfinite numbers', ->
      strictEqual stringify(Infinity),  '["Number","Infinity"]'
      strictEqual stringify(-Infinity), '["Number","-Infinity"]'
      strictEqual stringify(NaN),       '["Number","NaN"]'

    it 'serializes undefined', ->
      strictEqual stringify(undefined), '["Undefined"]'

    it 'serializes Date objects', ->
      strictEqual stringify(new Date 'Sun Oct 14 2012 13:27:37 GMT-0700 (PDT)'),
                  '["Date","2012-10-14T20:27:37.000Z"]'

    it 'serializes RegExp objects', ->
      strictEqual stringify(/^foo$/im), '["RegExp","/^foo$/im"]'

    it 'serializes arrays', ->
      strictEqual stringify([1, 2, 3]), '["Array",1,2,3]'

    it 'serializes objects as arrays sorted by property name', ->
      strictEqual stringify(foo:1, bar:2, baz:3),
                  '["Object","bar",2,"baz",3,"foo",1]'

    it 'serializes arbitrarily nested arrays and objects', ->
      strictEqual stringify([1, [2, [3, 4]]]),
                  '["Array",1,["Array",2,["Array",3,4]]]'
      strictEqual stringify(foo: bar: baz: 0),
                  '["Object","foo",["Object","bar",["Object","baz",0]]]'
      strictEqual stringify([1, foo: [2, 3]]),
                  '["Array",1,["Object","foo",["Array",2,3]]]'
      strictEqual stringify(foo: [1, bar: 2]),
                  '["Object","foo",["Array",1,["Object","bar",2]]]'

    it 'cannot serialize functions', ->
      test = (err) ->
        err instanceof TypeError and
        err.message is 'functions cannot be serialized'
      throws (-> stringify ->), test
      throws (-> stringify [-1, -2, ->]), test

  describe '.parse', ->

    it 'materializes atomic values in the same manner as JSON.parse', ->
      strictEqual parse('true'), true
      strictEqual parse('false'), false
      strictEqual parse('null'), null
      strictEqual parse('0'), 0
      strictEqual parse('"foo bar"'), 'foo bar'

    it 'materializes negative zero', ->
      strictEqual parse('-0'), 0
      strictEqual 1 / parse('-0'), -Infinity

    it 'materializes nonfinite numbers', ->
      strictEqual parse('["Number","Infinity"]'), Infinity
      strictEqual parse('["Number","-Infinity"]'), -Infinity
      notStrictEqual parse('["Number","NaN"]'), parse('["Number","NaN"]')

    it 'materializes undefined', ->
      strictEqual parse('["Undefined"]'), undefined

    it 'materializes Date objects', ->
      deepEqual parse('["Date","2012-10-14T20:27:37.000Z"]'),
                new Date 'Sun Oct 14 2012 13:27:37 GMT-0700 (PDT)'

    it 'materializes RegExp objects', ->
      deepEqual parse('["RegExp","/^foo$/im"]'), /^foo$/im

    it 'materializes arrays', ->
      deepEqual parse('["Array",1,2,3]'), [1, 2, 3]

    it 'materializes objects', ->
      deepEqual parse('["Object","bar",2,"baz",3,"foo",1]'),
                foo:1, bar:2, baz:3

    it 'materializes arbitrarily nested arrays and objects', ->
      deepEqual parse('["Array",1,["Array",2,["Array",3,4]]]'),
                [1, [2, [3, 4]]]
      deepEqual parse('["Object","foo",["Object","bar",["Object","baz",0]]]'),
                foo: bar: baz: 0
      deepEqual parse('["Array",1,["Object","foo",["Array",2,3]]]'),
                [1, foo: [2, 3]]
      deepEqual parse('["Object","foo",["Array",1,["Object","bar",2]]]'),
                foo: [1, bar: 2]
