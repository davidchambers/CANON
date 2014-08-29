(function() {

  var assert, suite, test, _, CANON;
  if (typeof module !== 'undefined' && 'exports' in module) {
    assert = require('assert');
    suite  = global.suite;
    test   = global.test;
    _      = require('underscore');
    CANON  = require('..');
  } else {
    assert = window;
    suite  = window.module;
    test   = window.test;
    _      = window._;
    CANON  = window.CANON;
  }

  suite('CANON.stringify');

  test('serializes atomic values identically to JSON.stringify', function() {
    assert.strictEqual(CANON.stringify(true), 'true');
    assert.strictEqual(CANON.stringify(false), 'false');
    assert.strictEqual(CANON.stringify(null), 'null');
    assert.strictEqual(CANON.stringify(0), '0');
    assert.strictEqual(CANON.stringify('foo bar'), '"foo bar"');
  });

  test('serializes negative zero', function() {
    assert.strictEqual(CANON.stringify(-0), '-0');
  });

  test('serializes nonfinite numbers', function() {
    assert.strictEqual(CANON.stringify(Infinity), '["Number","Infinity"]');
    assert.strictEqual(CANON.stringify(-Infinity), '["Number","-Infinity"]');
    assert.strictEqual(CANON.stringify(NaN), '["Number","NaN"]');
  });

  test('serializes undefined', function() {
    assert.strictEqual(CANON.stringify(undefined), '["Undefined"]');
  });

  test('serializes Arguments objects', function() {
    assert.strictEqual(
      CANON.stringify((function() { return arguments; }('x', 'y'))),
      '["Arguments","x","y"]'
    );
  });

  test('serializes Date objects', function() {
    assert.strictEqual(
      CANON.stringify(new Date('Sun Oct 14 2012 13:27:37 GMT-0700 (PDT)')),
      '["Date","2012-10-14T20:27:37.000Z"]'
    );
  });

  test('serializes RegExp objects', function() {
    assert.strictEqual(CANON.stringify(/^foo$/im), '["RegExp","/^foo$/im"]');
  });

  test('serializes arrays', function() {
    assert.strictEqual(CANON.stringify([1, 2, 3]), '["Array",1,2,3]');
  });

  test('serializes objects as arrays sorted by property name', function() {
    assert.strictEqual(CANON.stringify({foo: 1, bar: 2, baz: 3}),
                       '["Object","bar",2,"baz",3,"foo",1]');
  });

  test('serializes arbitrarily nested arrays and objects', function() {
    assert.strictEqual(
      CANON.stringify([1, [2, [3, 4]]]),
      '["Array",1,["Array",2,["Array",3,4]]]'
    );
    assert.strictEqual(
      CANON.stringify({foo: {bar: {baz: 0}}}),
      '["Object","foo",["Object","bar",["Object","baz",0]]]'
    );
    assert.strictEqual(
      CANON.stringify([1, {foo: [2, 3]}]),
      '["Array",1,["Object","foo",["Array",2,3]]]'
    );
    assert.strictEqual(
      CANON.stringify({foo: [1, {bar: 2}]}),
      '["Object","foo",["Array",1,["Object","bar",2]]]'
    );
  });

  test('cannot serialize functions', function() {
    assert.throws(function() {
      CANON.stringify(CANON.stringify);
    }, function(err) {
      return (err instanceof TypeError &&
              err.message === 'Functions cannot be serialized');
    });
    assert.throws(function() {
      CANON.stringify([-1, -2, CANON.stringify]);
    }, function(err) {
      return (err instanceof TypeError &&
              err.message === 'Functions cannot be serialized');
    });
  });

  test('serializes objects with millions of keys (#7)', function() {
    for (var obj = {}, idx = 0; idx < 1e6; idx += 1) obj[idx] = idx;
    assert.strictEqual(CANON.stringify(obj).length, 15777790);
  });

  suite('CANON.parse');

  test('materializes atomic values identically to JSON.parse', function() {
    assert.strictEqual(CANON.parse('true'), true);
    assert.strictEqual(CANON.parse('false'), false);
    assert.strictEqual(CANON.parse('null'), null);
    assert.strictEqual(CANON.parse('0'), 0);
    assert.strictEqual(CANON.parse('"foo bar"'), 'foo bar');
  });

  test('materializes negative zero', function() {
    assert.strictEqual(CANON.parse('-0'), 0);
    assert.strictEqual(1 / CANON.parse('-0'), -Infinity);
  });

  test('materializes nonfinite numbers', function() {
    assert.strictEqual(CANON.parse('["Number","Infinity"]'), Infinity);
    assert.strictEqual(CANON.parse('["Number","-Infinity"]'), -Infinity);
    assert.notStrictEqual(CANON.parse('["Number","NaN"]'),
                          CANON.parse('["Number","NaN"]'));
  });

  test('materializes undefined', function() {
    assert.strictEqual(CANON.parse('["Undefined"]'), undefined);
  });

  test('materializes Arguments objects', function() {
    var value = CANON.parse('["Arguments","x","y"]');
    assert.strictEqual(_.isArguments(value), true);
    assert.strictEqual(value.length, 2);
    assert.strictEqual(value[0], 'x');
    assert.strictEqual(value[1], 'y');
  });

  test('materializes Date objects', function() {
    assert.deepEqual(CANON.parse('["Date","2012-10-14T20:27:37.000Z"]'),
                     new Date('Sun Oct 14 2012 13:27:37 GMT-0700 (PDT)'));
  });

  test('materializes RegExp objects', function() {
    assert.deepEqual(CANON.parse('["RegExp","/^foo$/im"]'), /^foo$/im);
  });

  test('materializes arrays', function() {
    assert.deepEqual(CANON.parse('["Array",1,2,3]'), [1, 2, 3]);
  });

  test('materializes objects', function() {
    assert.deepEqual(CANON.parse('["Object","bar",2,"baz",3,"foo",1]'),
                     {foo: 1, bar: 2, baz: 3});
  });

  test('materializes arbitrarily nested arrays and objects', function() {
    assert.deepEqual(
      CANON.parse('["Array",1,["Array",2,["Array",3,4]]]'),
      [1, [2, [3, 4]]]
    );
    assert.deepEqual(
      CANON.parse('["Object","foo",["Object","bar",["Object","baz",0]]]'),
      {foo: {bar: {baz: 0}}}
    );
    assert.deepEqual(
      CANON.parse('["Array",1,["Object","foo",["Array",2,3]]]'),
      [1, {foo: [2, 3]}]
    );
    assert.deepEqual(
      CANON.parse('["Object","foo",["Array",1,["Object","bar",2]]]'),
      {foo: [1, {bar: 2}]}
    );
  });

}());
